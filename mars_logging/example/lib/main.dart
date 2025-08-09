import 'dart:async';

import 'package:clover/clover.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  final filesDir = await path.getApplicationSupportDirectory();
  final logsDir = path.join(filesDir.path, 'logs');
  final cacheDir = path.join(filesDir.path, 'cache');
  final cacheDays = 0;
  final nameprefix = 'log';
  final useConsole = kDebugMode;
  final level = kDebugMode ? XLogLevel.debug : XLogLevel.info;
  await XLog.open(
    mode: mode,
    logsDir: logsDir,
    cacheDir: cacheDir,
    cacheDays: cacheDays,
    nameprefix: nameprefix,
    useConsole: useConsole,
    level: level,
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
                  path: ':logName',
                  builder:
                      (context, state) => ViewModelBinding(
                        viewBuilder: () => const LogView(),
                        viewModelBuilder: () {
                          final logName = state.pathParameters['logName'];
                          if (logName == null) {
                            throw ArgumentError.notNull();
                          }
                          return LogViewModel(logName);
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
    return MaterialApp.router(routerConfig: routerConfig);
  }

  @override
  void dispose() {
    routerConfig.dispose();
    super.dispose();
  }
}
