import 'dart:isolate';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'appender_mode.dart';
import 'decode_mars_nocrypt_log_file.dart';
import 'log_imp.dart';
import 'mars_logging_plugin.dart';
import 'log_level.dart';

abstract base class Log extends PlatformInterface {
  static final _token = Object();

  Log.impl() : super(token: _token);

  static final _instance = MarsLoggingPlugin.instance.newLog();

  Future<void> $setLogImp(LogImp imp);
  Future<void> $appenderOpen(LogLevel level, AppenderMode mode, String cacheDir,
      String logDir, String nameprefix, int cacheDays);
  Future<void> $appenderClose();
  Future<void> $appenderFlush();
  Future<void> $appenderFlushSync(bool isSync);
  Future<LogLevel> $getLogLevel();
  Future<void> $setLevel(LogLevel level, bool jni);
  Future<void> $setConsoleLogOpen(bool isOpen);
  Future<void> $f(String tag, String msg);
  Future<void> $e(String tag, String msg);
  Future<void> $w(String tag, String msg);
  Future<void> $i(String tag, String msg);
  Future<void> $d(String tag, String msg);
  Future<void> $v(String tag, String msg);

  static Future<void> setLogImp(LogImp imp) => _instance.$setLogImp(imp);
  static Future<void> appenderOpen({
    LogLevel level = LogLevel.verbose,
    AppenderMode mode = AppenderMode.async,
    required String cacheDir,
    required String logDir,
    String nameprefix = '',
    int cacheDays = 0,
  }) =>
      _instance.$appenderOpen(
          level, mode, cacheDir, logDir, nameprefix, cacheDays);
  static Future<void> appenderClose() => _instance.$appenderClose();
  static Future<void> appenderFlush() => _instance.$appenderFlush();
  static Future<void> appenderFlushSync(bool isSync) =>
      _instance.$appenderFlushSync(isSync);
  static Future<LogLevel> getLogLevel() => _instance.$getLogLevel();
  static Future<void> setLevel(LogLevel level, bool jni) =>
      _instance.$setLevel(level, jni);
  static Future<void> setConsoleLogOpen(bool isOpen) =>
      _instance.$setConsoleLogOpen(isOpen);
  static Future<void> f(String tag, String msg) => _instance.$f(tag, msg);
  static Future<void> e(String tag, String msg) => _instance.$e(tag, msg);
  static Future<void> w(String tag, String msg) => _instance.$w(tag, msg);
  static Future<void> i(String tag, String msg) => _instance.$i(tag, msg);
  static Future<void> d(String tag, String msg) => _instance.$d(tag, msg);
  static Future<void> v(String tag, String msg) => _instance.$v(tag, msg);

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
      await Log.f(tag, message);
    } else if (level >= Level.SEVERE) {
      await Log.e(tag, message);
    } else if (level >= Level.WARNING) {
      await Log.w(tag, message);
    } else if (level >= Level.INFO) {
      await Log.i(tag, message);
    } else if (level >= Level.CONFIG) {
      await Log.d(tag, message);
    } else {
      await Log.v(tag, message);
    }
  }

  static Future<Uint8List> decode(Uint8List buffer) {
    return Isolate.run(() {
      final startPos = getLogStartPos(buffer, 2);
      if (startPos == -1) {
        throw ArgumentError.value(startPos);
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
