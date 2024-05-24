import 'package:dotenv/dotenv.dart';

class Config {
  final String? token;
  final int supplyChannel;
  final int lockedChannel;
  final int activeNodesChannel;
  final int currentPriceChannel;
  final int lastUpdateChannel;
  final int marketCapChannel;
  final int rewardDayChannel;
  final int halvingChanel;
  final int blockChanel;

  Config({
    required this.token,
    required this.supplyChannel,
    required this.lockedChannel,
    required this.activeNodesChannel,
    required this.currentPriceChannel,
    required this.lastUpdateChannel,
    required this.marketCapChannel,
    required this.rewardDayChannel,
    required this.halvingChanel,
    required this.blockChanel,
  });

  factory Config.fromEnv(DotEnv env) {
    return Config(
      token: env['DISCORD_TOKEN'],
      supplyChannel: int.parse(env['SUPPLY_CHANNEL'] ?? "0"),
      lockedChannel: int.parse(env['LOCKED_CHANNEL'] ?? "0"),
      activeNodesChannel: int.parse(env['ACTIVE_NODES_CHANNEL'] ?? "0"),
      currentPriceChannel: int.parse(env['CURRENT_PRICE_CHANNEL'] ?? "0"),
      lastUpdateChannel: int.parse(env['LAST_UPDATE_CHANNEL'] ?? "0"),
      marketCapChannel: int.parse(env['MARKETCAP_CHANNEL'] ?? "0"),
      rewardDayChannel: int.parse(env['REWARD_DAY_CHANNEL'] ?? "0"),
      halvingChanel: int.parse(env['HALVING_CHANEL'] ?? "0"),
      blockChanel: int.parse(env['BLOCK_CHANEL'] ?? "0"),
    );
  }

  bool validate() {
    if (token == null) {
      print('DISCORD_TOKEN not found in the .env file');
      return false;
    }
    if (marketCapChannel == 0) {
      print('MARKETCAP_CHANNEL not found in the .env file');
      return false;
    }
    if (rewardDayChannel == 0) {
      print('REWARD_DAY_CHANNEL not found in the .env file');
      return false;
    }
    if (supplyChannel == 0) {
      print('SUPPLY_CHANNEL not found in the .env file');
      return false;
    }
    if (lockedChannel == 0) {
      print('LOCKED_CHANNEL not found in the .env file');
      return false;
    }
    if (activeNodesChannel == 0) {
      print('ACTIVE_NODES_CHANNEL not found in the .env file');
      return false;
    }
    if (currentPriceChannel == 0) {
      print('CURRENT_PRICE_CHANNEL not found in the .env file');
      return false;
    }
    if (lastUpdateChannel == 0) {
      print('LAST_UPDATE_CHANNEL not found in the .env file');
      return false;
    }

    if (halvingChanel == 0) {
      print('HALVING_CHANEL not found in the .env file');
      return false;
    }
    if (blockChanel == 0) {
      print('BLOCK_CHANEL not found in the .env file');
      return false;
    }
    return true;
  }
}
