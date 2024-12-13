// import 'package:flutter/foundation.dart';
import 'package:clover/clover.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mars_logging/mars_logging.dart';

import 'view_models.dart';
import 'views.dart';
// import 'package:path/path.dart' as path;

void main() {
  // final filesDir = Dirs.filesDir;
  // final externalFilesDir = Dirs.externalFilesDir ?? filesDir;
  // final cacheDir = path.join(filesDir.path, 'xlog');
  // final logDir = path.join(externalFilesDir.path, 'log');
  // const nameprefix = 'log';
  // if (kDebugMode) {
  //   Xlog.setConsoleLogOpen(true);
  //   Xlog.appenderOpen(
  //     level: XlogLevel.debug,
  //     cacheDir: cacheDir,
  //     logDir: logDir,
  //     nameprefix: nameprefix,
  //   );
  // } else {
  //   Xlog.setConsoleLogOpen(false);
  //   Xlog.appenderOpen(
  //     level: XlogLevel.info,
  //     cacheDir: cacheDir,
  //     logDir: logDir,
  //     nameprefix: nameprefix,
  //   );
  // }
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(Xlog.onRecord);
  runApp(MyApp());
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
          builder: (context, state) => ViewModelBinding(
            viewBuilder: (context) => const HomeView(),
            viewModelBuilder: (context) => HomeViewModel(),
          ),
          routes: [
            GoRoute(
              path: 'logs',
              builder: (context, state) => ViewModelBinding(
                viewBuilder: (context) => const LogsView(),
                viewModelBuilder: (context) => LogsViewModel(),
              ),
              routes: [
                GoRoute(
                  path: ':logName',
                  builder: (context, state) => ViewModelBinding(
                    viewBuilder: (context) => const LogView(),
                    viewModelBuilder: (context) {
                      final logName = state.pathParameters['logName'];
                      if (logName == null) {
                        throw ArgumentError.notNull();
                      }
                      return LogViewModel(logName);
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: routerConfig,
    );
  }
}
