// Run with `dart run pigeon --input api.dart`.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/mars_logging_api.g.dart',
    swiftOut: 'darwin/Classes/MarsLoggingApi.g.swift',
    swiftOptions: SwiftOptions(errorClassName: 'MarsLoggingError'),
  ),
)
enum AppenderModeApi { async, sync }

enum XLogLevelApi { all, verbose, debug, info, warning, error, fatal, none }

enum CompressModeApi { zlib, zstd }

enum CompressLevelApi {
  level1,
  level2,
  level3,
  level4,
  level5,
  level6,
  level7,
  level8,
  level9,
}

@HostApi()
abstract class XLogHostApi {
  void open(
    AppenderModeApi mode,
    XLogLevelApi level,
    String logsDir,
    String cacheDir,
    int cacheDays,
    String namePrefix,
    CompressModeApi compressMode,
    CompressLevelApi compressLevel,
    String pubKey,
    bool useConsole,
    int maxFileSize,
    int maxAliveDuration,
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
