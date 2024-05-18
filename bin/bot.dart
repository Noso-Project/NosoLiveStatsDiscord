import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:noso_live_stats_discord_bot/values.dart';
import 'package:noso_rest_api/api_service.dart';
import 'package:noso_rest_api/enum/time_range.dart';
import 'package:noso_rest_api/models/set_price.dart';
import 'package:nyxx/nyxx.dart';

var restApi = NosoApiService();

double currentPriceH = 0;
List<String> infoNodeH = ["0", "0"];
int supplyH = 0;
int lockedH = 0;

Future<void> main(List<String> arguments) async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  var token = env['DISCORD_TOKEN'];
  int supplyChanel = int.parse(env['SUPPLY_CHANNEL'] ?? "0");
  int lockedChanel = int.parse(env['LOCKED_CHANNEL'] ?? "0");
  int activeNodesChanel = int.parse(env['ACTIVE_NODES_CHANNEL'] ?? "0");
  int currentPriceChannel = int.parse(env['CURRENT_PRICE_CHANNEL'] ?? "0");
  int lastUpdateChannel = int.parse(env['LAST_UPDATE_CHANNEL'] ?? "0");
  int marketCapChannel = int.parse(env['MARKETCAP_CHANNEL'] ?? "0");
  int rewardDayChannel = int.parse(env['REWARD_DAY_CHANNEL'] ?? "0");

  if (token == null) {
    print('DISCORD_TOKEN not found in the .env file');
    return;
  }
  if (marketCapChannel == 0) {
    print('MARKETCAP_CHANNEL not found in the .env file');
    return;
  }
  if (rewardDayChannel == 0) {
    print('REWARD_DAY_CHANNEL not found in the .env file');
    return;
  }
  if (supplyChanel == 0) {
    print('SUPPLY_CHANNEL not found in the .env file');
    return;
  }
  if (lockedChanel == 0) {
    print('LOCKED_CHANNEL not found in the .env file');
    return;
  }
  if (activeNodesChanel == 0) {
    print('ACTIVE_NODES_CHANNEL not found in the .env file');
    return;
  }
  if (currentPriceChannel == 0) {
    print('CURRENT_PRICE_CHANNEL not found in the .env file');
    return;
  }
  if (lastUpdateChannel == 0) {
    print('LAST_UPDATE_CHANNEL not found in the .env file');
    return;
  }

  final client = await Nyxx.connectGateway(
    token,
    GatewayIntents(16),
    options: GatewayClientOptions(
        plugins: [Logging(logLevel: Level.ALL)],
        channelCacheConfig: CacheConfig(maxSize: 0, shouldCache: (x) => false)),
  );

  Timer.periodic(Duration(minutes: 5), (Timer timer) async {
    var currentPrice = await _getCurrentPrice();
    List<String> infoNode = await _infoNode();
    var supply = await _getSupplyNoso();
    var locked = await _getLockedNoso();
    var marketcap = currentPrice * supply;
    var rewardDay = double.parse(infoNode[1]) * 144;

    /// UPDATE REWARD DAY
    if (infoNodeH != infoNode) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(client, marketCapChannel,
          Value<double>(rewardDay, TypeMessage.rewarDay));
    }

    /// UPDATE MARKETCAP
    if (currentPrice != currentPrice) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(client, rewardDayChannel,
          Value<double>(marketcap, TypeMessage.marketcap));
    }

    /// UPDATE LOCKED
    if (locked != lockedH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(
          client, lockedChanel, Value<int>(locked, TypeMessage.locked));
    }

    /// UPDATE SUPPLY
    if (supply != supplyH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(
          client, supplyChanel, Value<int>(supply, TypeMessage.supply));
    }

    /// UPDATE ACTIVE NODES

    if (infoNode != infoNodeH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(client, activeNodesChanel,
          Value<String>(infoNode[0], TypeMessage.activeNodes));
    }

    /// UPDATE PRICE

    if (currentPrice != currentPriceH) {
      await Future.delayed(Duration(seconds: 5));
      await _updateInfo(client, currentPriceChannel,
          Value<double>(currentPrice, TypeMessage.price));
    }

    /// LAST UPDATE
    await Future.delayed(Duration(seconds: 5));
    await _updateInfo(client, lastUpdateChannel,
        Value<String>(_getUpdateTime(), TypeMessage.lastUpdate));

    /// SAVE HISTORY

    currentPriceH = currentPrice;
    infoNodeH = infoNode;
    supplyH = supply;
    lockedH = locked;
  });

  stopApp() {
    stdout.write('\b\b  \b\b');
    stdout.writeln('BOT is stopped!');
    client.close();

    exit(0);
  }

  runZoned(() {
    ProcessSignal.sigint.watch().listen((_) async => stopApp());
    if (!Platform.isWindows) {
      ProcessSignal.sigterm.watch().listen((_) async => stopApp());
    }
  });
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

Future<int> _getLockedNoso() async {
  var response = await restApi.fetchLockedSupply();
  if (response.value != null && response.error == null) {
    return response.value ?? 0;
  }

  return 0;
}

Future<int> _getSupplyNoso() async {
  var response = await restApi.fetchCirculatingSupply();
  if (response.value != null && response.error == null) {
    return response.value ?? 0;
  }

  return 0;
}

Future<List<String>> _infoNode() async {
  var response = await restApi.fetchNodesInfo();
  if (response.value != null && response.error == null) {
    var countMN = response.value?.count ?? 0;
    var reward = response.value?.reward ?? 0;
    return [countMN.toString(), reward.toString()];
  }

  return ["0", "0"];
}

Future<double> _getCurrentPrice() async {
  var response =
      await restApi.fetchPrice(SetPriceRequest(TimeRange.minute, 10));
  if (response.value != null && response.error == null) {
    return response.value?.first.price ?? 0;
  }

  return 0;
}

_getUpdateTime() {
  DateTime now = DateTime.now().toUtc();
  return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
}
