import 'package:noso_live_stats_discord_bot/config.dart';
import 'package:noso_live_stats_discord_bot/values.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

import 'api_requests.dart';
import 'chat_comands.dart';

class BotHandler {
  double _currentPriceH = 0;
  List<String> _infoNodeH = ["0", "0", "0"];
  int _supplyH = 0;
  int _lockedH = 0;
  final String _technicalStop =
      "⛔ Please wait, the bot is being initiated or undergoing maintenance!";

  final ApiRequests _api;
  late NyxxGateway _client;
  final Config _config;
  final ChatCommands _chatCommands = ChatCommands();

  BotHandler(this._api, this._config);

  setClient(NyxxGateway client) {
    _client = client;
  }

  getStatusCommand() {
    return ChatCommand(
      _chatCommands.status[0],
      _chatCommands.status[1],
      (ChatContext context) async {
        try {
          var response = _technicalStop;
          if (_supplyH != 0 && _lockedH != 0) {
            response =
                '${Value<String>(_infoNodeH[2], TypeMessage.block).getValue()}\n'
                '${Value<int>(_supplyH, TypeMessage.supply).getValue()}\n'
                '${Value<int>(_lockedH, TypeMessage.locked).getValue()}\n'
                '${Value<double>((_currentPriceH * _supplyH), TypeMessage.marketcap).getValue()}\n'
                '${Value<String>(_infoNodeH[0], TypeMessage.activeNodes).getValue()}\n'
                '${Value<double>((double.parse(_infoNodeH[1]) * 144), TypeMessage.rewarDay).getValue()}\n'
                '${Value<String>(_api.getUpdateTime(), TypeMessage.lastUpdate).getValue()}\n';
          }
          return await context.respond(MessageBuilder(content: response));
        } catch (e) {
          print(e);
          await context.respond(MessageBuilder(content: _technicalStop));
        }
      },
    );
  }

  responseAllInfo() async {
    var currentPrice = await _api.getCurrentPrice();
    List<String> infoNode = await _api.infoNode();
    var supply = await _api.getSupplyNoso();
    var locked = await _api.getLockedNoso();
    var marketcap = currentPrice * supply;
    var rewardDay = double.parse(infoNode[1]) * 144;

    /// UPDATE REWARD DAY
    if (_infoNodeH != infoNode) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.marketCapChannel,
          Value<double>(rewardDay, TypeMessage.rewarDay));
    }

    /// UPDATE MARKETCAP
    if (currentPrice != currentPrice) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.rewardDayChannel,
          Value<double>(marketcap, TypeMessage.marketcap));
    }

    /// UPDATE LOCKED
    if (locked != _lockedH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.lockedChannel,
          Value<int>(locked, TypeMessage.locked));
    }

    /// UPDATE SUPPLY
    if (supply != _supplyH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.supplyChannel,
          Value<int>(supply, TypeMessage.supply));
    }

    /// UPDATE ACTIVE NODES

    if (infoNode != _infoNodeH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.activeNodesChannel,
          Value<String>(infoNode[0], TypeMessage.activeNodes));
    }

    /// UPDATE PRICE

    if (currentPrice != _currentPriceH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.currentPriceChannel,
          Value<double>(currentPrice, TypeMessage.price));
    }

    /// LAST UPDATE
    await Future.delayed(Duration(seconds: 5));
    await _updateInfo(_client, _config.lastUpdateChannel,
        Value<String>(_api.getUpdateTime(), TypeMessage.lastUpdate));

    /// SAVE HISTORY

    _currentPriceH = currentPrice;
    _infoNodeH = infoNode;
    _supplyH = supply;
    _lockedH = locked;
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
