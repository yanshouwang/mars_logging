// Run with `dart run pigeon --input api.dart`.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/mars_logging.api.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/hebei/mars_logging/MarsLogging.api.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.hebei.mars_logging',
      errorClassName: 'MarsLoggingError',
    ),
    // swiftOut: 'ios/Classes/MarsLogging.g.swift',
    swiftOut: 'macos/Classes/MarsLogging.api.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MarsLoggingError',
    ),
  ),
)
@HostApi()
abstract class XLogApi {
  void open(AppenderModeApi mode, String logsDir, String cacheDir,
      int cacheDays, String nameprefix, bool useConsole, XLogLevelApi level);
  void flush(bool isSync);
  void close();
  void verbose(String tag, String message);
  void debug(String tag, String message);
  void info(String tag, String message);
  void warning(String tag, String message);
  void error(String tag, String message);
  void fatal(String tag, String message);
}

enum AppenderModeApi {
  async,
  sync,
}

enum XLogLevelApi {
  all,
  verbose,
  debug,
  info,
  warning,
  error,
  fatal,
  none,
}
