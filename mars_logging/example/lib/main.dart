import 'dart:async';

import 'package:clover/clover.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mars_logging/mars_logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import 'view_models.dart';
import 'views.dart';

void main() {
  runZonedGuarded(onStartUp, onUncaughtError);
}

void onStartUp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mode = AppenderMode.async;
  final level = kDebugMode ? XLogLevel.debug : XLogLevel.info;
  final filesDir = await path.getApplicationSupportDirectory();
  final logsDir = path.join(filesDir.path, 'logs');
  final cacheDir = path.join(filesDir.path, 'cache');
  final cacheDays = 0;
  final namePrefix = 'log';
  final compressMode = CompressMode.zstd;
  final compressLevel = CompressLevel.level6;
  final pubKey =
      'f3d382d0bd7e33356d8dc497e1f4b3f93f8d4f96d0fdddda66e4eaf9abb50564ce356990d7af20a47cccfb8c3e4b9070c9a56fad0ffd07d0114238b950a36abc';
  final useConsole = kDebugMode;
  final maxFileSize = 10 * 1024 * 1024;
  final maxAliveDuration = 30 * 24 * 60 * 60;
  await XLog.open(
    mode: mode,
    level: level,
    logsDir: logsDir,
    cacheDir: cacheDir,
    cacheDays: cacheDays,
    namePrefix: namePrefix,
    compressMode: compressMode,
    compressLevel: compressLevel,
    pubKey: pubKey,
    useConsole: useConsole,
    maxFileSize: maxFileSize,
    maxAliveDuration: maxAliveDuration,
  );
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(XLog.onRecord);
  runApp(MyApp());
}

void onUncaughtError(Object error, StackTrace stack) {
  Logger.root.shout('Uncaught error', error, stack);
}

class MyApp extends StatefulWidget {
  final Logger logger;

  MyApp({super.key}) : logger = Logger('MyApp');

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter routerConfig;

  @override
  void initState() {
    super.initState();
    routerConfig = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) => ViewModelBinding(
                viewBuilder: () => const HomeView(),
                viewModelBuilder: () => HomeViewModel(),
              ),
          routes: [
            GoRoute(
              path: 'logs',
              builder:
                  (context, state) => ViewModelBinding(
                    viewBuilder: () => const LogsView(),
                    viewModelBuilder: () => LogsViewModel(),
                  ),
              routes: [
                GoRoute(
                  path: ':logPath',
                  builder:
                      (context, state) => ViewModelBinding(
                        viewBuilder: () => const LogView(),
                        viewModelBuilder: () {
                          final encodedPath = state.pathParameters['logPath'];
                          if (encodedPath == null) {
                            throw ArgumentError.notNull();
                          }
                          final logPath = Uri.decodeComponent(encodedPath);
                          return LogViewModel(logPath);
                        },
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(routerConfig: routerConfig);
  }

  @override
  void dispose() {
    routerConfig.dispose();
    super.dispose();
  }
}
