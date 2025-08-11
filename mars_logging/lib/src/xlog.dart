import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mars_logging_platform_interface/mars_logging_platform_interface.dart';

import 'decode_mars_nocrypt_log_file.dart';

abstract base class XLog {
  static XLogApi get _api => XLogApi.instance;

  static Future<void> open({
    AppenderMode mode = AppenderMode.async,
    required String logsDir,
    required String cacheDir,
    int cacheDays = 0,
    String nameprefix = '',
    bool useConsole = kDebugMode,
    XLogLevel level = XLogLevel.all,
  }) => _api.open(
    mode,
    logsDir,
    cacheDir,
    cacheDays,
    nameprefix,
    useConsole,
    level,
  );

  static Future<void> flush(bool isSync) => _api.flush(isSync);

  static Future<void> close() => _api.close();

  static Future<void> verbose(String tag, String message) =>
      _api.verbose(tag, message);

  static Future<void> debug(String tag, String message) =>
      _api.debug(tag, message);

  static Future<void> info(String tag, String message) =>
      _api.info(tag, message);

  static Future<void> warning(String tag, String message) =>
      _api.warning(tag, message);

  static Future<void> error(String tag, String message) =>
      _api.error(tag, message);

  static Future<void> fatal(String tag, String message) =>
      _api.fatal(tag, message);

  static void onRecord(LogRecord record) async {
    final level = record.level;
    final tag = record.loggerName;
    final messageBuilder = StringBuffer();
    messageBuilder.write(record.message);
    final error = record.error;
    if (error != null) {
      messageBuilder.writeln();
      messageBuilder.write(error);
    }
    final stackTrace = record.stackTrace;
    if (stackTrace != null) {
      messageBuilder.writeln();
      messageBuilder.write(stackTrace);
    }
    final message = messageBuilder.toString();
    if (level >= Level.SHOUT) {
      await XLog.fatal(tag, message);
    } else if (level >= Level.SEVERE) {
      await XLog.error(tag, message);
    } else if (level >= Level.WARNING) {
      await XLog.warning(tag, message);
    } else if (level >= Level.INFO) {
      await XLog.info(tag, message);
    } else if (level >= Level.CONFIG) {
      await XLog.debug(tag, message);
    } else {
      await XLog.verbose(tag, message);
    }
  }

  static Future<Uint8List> decode(Uint8List buffer) {
    return Isolate.run(() {
      final startPos = getLogStartPos(buffer, 2);
      if (startPos == -1) {
        throw ArgumentError.notNull('startPos');
      }
      final outBuffer = <int>[];
      var currentPos = startPos;
      while (true) {
        currentPos = decodeBuffer(buffer, currentPos, outBuffer);
        if (currentPos == -1) {
          break;
        }
      }
      return Uint8List.fromList(outBuffer);
    });
  }
}
