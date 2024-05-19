import 'package:noso_live_stats_discord_bot/config.dart';
import 'package:noso_live_stats_discord_bot/pen.dart';
import 'package:noso_live_stats_discord_bot/values.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

import 'api_requests.dart';

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

  BotHandler(this._api, this._config);

  setClient(NyxxGateway client) {
    _client = client;
  }

  getStatusCommand() {
    return ChatCommand(
        "status",
        "Get latest coin information",
      id(
        "status",
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
                  '${Value<double>(_currentPriceH, TypeMessage.price).getValue()}\n'
                  '${Value<String>(_api.getUpdateTime(), TypeMessage.lastUpdate).getValue()}\n';
            }
            await context.respond(MessageBuilder(content: response));
          } catch (e) {
            print(Pen().red("Exception: $e"));
            context.respond(MessageBuilder(content: _technicalStop));
          }
        },
      )
    );
  }

  responseAllInfo({bool isSendRequestDiscord = true}) async {
    var currentPrice = await _api.getCurrentPrice();
    List<String> infoNode = await _api.infoNode();
    var supply = await _api.getSupplyNoso();
    var locked = await _api.getLockedNoso();
    var marketcap = currentPrice * supply;
    var rewardDay = double.parse(infoNode[1]) * 144;

    /// UPDATE REWARD DAY
    if (_infoNodeH != infoNode && isSendRequestDiscord) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.marketCapChannel,
          Value<double>(rewardDay, TypeMessage.rewarDay));
    }

    /// UPDATE MARKETCAP
    if (currentPrice != currentPrice && isSendRequestDiscord) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.rewardDayChannel,
          Value<double>(marketcap, TypeMessage.marketcap));
    }

    /// UPDATE LOCKED
    if (locked != _lockedH && isSendRequestDiscord) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.lockedChannel,
          Value<int>(locked, TypeMessage.locked));
    }

    /// UPDATE SUPPLY
    if (supply != _supplyH && isSendRequestDiscord) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.supplyChannel,
          Value<int>(supply, TypeMessage.supply));
    }

    /// UPDATE ACTIVE NODES
    if (infoNode != _infoNodeH && isSendRequestDiscord) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.activeNodesChannel,
          Value<String>(infoNode[0], TypeMessage.activeNodes));
    }

    /// UPDATE PRICE
    if (currentPrice != _currentPriceH && isSendRequestDiscord) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.currentPriceChannel,
          Value<double>(currentPrice, TypeMessage.price));
    }

    /// LAST UPDATE
    if (isSendRequestDiscord) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(_client, _config.lastUpdateChannel,
          Value<String>(_api.getUpdateTime(), TypeMessage.lastUpdate));
    }

    /// SAVE HISTORY
    _currentPriceH = currentPrice;
    _infoNodeH = infoNode;
    _supplyH = supply;
    _lockedH = locked;
  }

  _updateInfo(NyxxGateway client, int channelId, Value value) async {
    try {
      var channel = await client.channels.get(Snowflake(channelId));

      channel.manager.update(
          Snowflake(channelId),
          GuildChannelUpdateBuilder(
            name: value.getValue(),
          ));
    } catch (e) {
      print(Pen().red("Exception: $e"));
    }
  }
}
