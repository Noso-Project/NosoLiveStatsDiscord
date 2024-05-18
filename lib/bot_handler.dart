import 'package:noso_live_stats_discord_bot/config.dart';
import 'package:noso_live_stats_discord_bot/values.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

import 'api_requests.dart';
import 'chat_comands.dart';

class BotHandler {
  double currentPriceH = 0;
  List<String> infoNodeH = ["0", "0", "0"];
  int supplyH = 0;
  int lockedH = 0;
  final String _technicalStop =
      "⛔ Please wait, the bot is being initiated or undergoing maintenance!";

  final ApiRequests api;
  late NyxxGateway _client;
  final Config config;
  final ChatCommands chatCommands = ChatCommands();

  BotHandler(this.api, this.config);

  setClient(NyxxGateway client) {
    _client = client;
  }

  getStatusCommand() {
    return ChatCommand(
      chatCommands.status[0],
      chatCommands.status[1],
      (ChatContext context) async {
        try {
          var response =
              '${Value<String>(infoNodeH[2], TypeMessage.block).getValue()}\n'
              '${Value<int>(supplyH, TypeMessage.supply).getValue()}\n'
              '${Value<int>(lockedH, TypeMessage.locked).getValue()}\n'
              '${Value<double>((currentPriceH * supplyH), TypeMessage.marketcap).getValue()}\n'
              '${Value<String>(infoNodeH[0], TypeMessage.activeNodes).getValue()}\n'
              '${Value<double>((double.parse(infoNodeH[1]) * 144), TypeMessage.rewarDay).getValue()}\n'
              '${Value<String>(api.getUpdateTime(), TypeMessage.lastUpdate).getValue()}\n';
          return await context.respond(MessageBuilder(
              content:
                  supplyH == 0 && lockedH == 0 ? _technicalStop : response));
        } catch (e) {
          print(e);
          await context.respond(MessageBuilder(content: _technicalStop));
        }
      },
    );
  }

  responseAllInfo() async {
    var currentPrice = await api.getCurrentPrice();
    List<String> infoNode = await api.infoNode();
    var supply = await api.getSupplyNoso();
    var locked = await api.getLockedNoso();
    var marketcap = currentPrice * supply;
    var rewardDay = double.parse(infoNode[1]) * 144;

    /// UPDATE REWARD DAY
    if (infoNodeH != infoNode) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, config.marketCapChannel,
          Value<double>(rewardDay, TypeMessage.rewarDay));
    }

    /// UPDATE MARKETCAP
    if (currentPrice != currentPrice) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, config.rewardDayChannel,
          Value<double>(marketcap, TypeMessage.marketcap));
    }

    /// UPDATE LOCKED
    if (locked != lockedH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, config.lockedChannel,
          Value<int>(locked, TypeMessage.locked));
    }

    /// UPDATE SUPPLY
    if (supply != supplyH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, config.supplyChannel,
          Value<int>(supply, TypeMessage.supply));
    }

    /// UPDATE ACTIVE NODES

    if (infoNode != infoNodeH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, config.activeNodesChannel,
          Value<String>(infoNode[0], TypeMessage.activeNodes));
    }

    /// UPDATE PRICE

    if (currentPrice != currentPriceH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, config.currentPriceChannel,
          Value<double>(currentPrice, TypeMessage.price));
    }

    /// LAST UPDATE
    await Future.delayed(Duration(seconds: 5));
    await _updateInfo(_client, config.lastUpdateChannel,
        Value<String>(api.getUpdateTime(), TypeMessage.lastUpdate));

    /// SAVE HISTORY

    currentPriceH = currentPrice;
    infoNodeH = infoNode;
    supplyH = supply;
    lockedH = locked;
  }

  _updateInfo(NyxxGateway client, int channelId, Value value) async {
    try {
      var ch = await client.channels.get(Snowflake(channelId));

      ch.manager.update(
          Snowflake(channelId),
          GuildChannelUpdateBuilder(
            name: value.getValue(),
          ));
    } catch (e) {
      print(e);
    }
  }
}
