// Run with `dart run pigeon --input api.dart`.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/mars_logging_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/zeekr/mars_logging_android/MarsLoggingApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.zeekr.mars_logging_android',
      errorClassName: 'MarsLoggingError',
    ),
  ),
)
enum AppenderModeApi { async, sync }

enum XLogLevelApi { all, verbose, debug, info, warning, error, fatal, none }

@HostApi()
abstract class XLogHostApi {
  void open(
    AppenderModeApi mode,
    String logsDir,
    String cacheDir,
    int cacheDays,
    String nameprefix,
    bool useConsole,
    XLogLevelApi level,
  );
  void flush(bool isSync);
  void close();
  void verbose(String tag, String message);
  void debug(String tag, String message);
  void info(String tag, String message);
  void warning(String tag, String message);
  void error(String tag, String message);
  void fatal(String tag, String message);
}
