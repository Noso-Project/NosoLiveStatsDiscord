import 'dart:async';

import 'package:dotenv/dotenv.dart';
import 'package:noso_live_stats_discord_bot/api_requests.dart';
import 'package:noso_live_stats_discord_bot/bot_handler.dart';
import 'package:noso_live_stats_discord_bot/config.dart';
import 'package:noso_live_stats_discord_bot/pen.dart';
import 'package:noso_rest_api/api_service.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final int botPriv = 3088;
final int timeDelayHeadChannels = 5; //minutes

Future<void> main(List<String> arguments) async {
  /// Init ENV
  var config = Config.fromEnv(DotEnv(includePlatformEnvironment: true)..load());

  /// Check config
  if (!config.validate()) {
    return;
  }

  /// Init Bot
  var api = ApiRequests(NosoApiService());
  var botHandler = BotHandler(api, config);

  /// Init chat commands
  final commands = CommandsPlugin(prefix: mentionOr((_) => '!'));
  commands.addCommand(botHandler.getStatusCommand());

  final client = await Nyxx.connectGateway(
    config.token ?? "",
    GatewayIntents(botPriv),
    options: GatewayClientOptions(
        plugins: [Logging(logLevel: Level.INFO), cliIntegration, commands],
        channelCacheConfig: CacheConfig(maxSize: 0, shouldCache: (x) => false)),
  );

  /// Add client to bot handler
  botHandler.setClient(client);

  print("initialization... please wait");
  await Future.delayed(Duration(seconds: 10));

  /// First connection run
  botHandler.responseAllInfo();
  print(Pen().greenText("Bot init success"));

  /// Timer Runner All info
  Timer.periodic(Duration(minutes: timeDelayHeadChannels), (Timer timer) async {
    botHandler.responseAllInfo();

    print(Pen().greenText(
        "Information in channel headers is updated every $timeDelayHeadChannels minutes"));
  });
}
