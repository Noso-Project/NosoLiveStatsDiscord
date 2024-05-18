import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:noso_live_stats_discord_bot/api_requests.dart';
import 'package:noso_live_stats_discord_bot/bot_handler.dart';
import 'package:noso_live_stats_discord_bot/config.dart';
import 'package:noso_rest_api/api_service.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final int botPriv = 3088;

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

  /// First connection run
  botHandler.responseAllInfo();

  /// Timer Runner All info
  Timer.periodic(Duration(minutes: 5), (Timer timer) async {
    botHandler.responseAllInfo();

    print("Update all headers");
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
