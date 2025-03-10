import 'package:clover/clover.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mars_logging/mars_logging.dart';

import 'view_models.dart';
import 'views.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(Mars.onRecord);
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
}
