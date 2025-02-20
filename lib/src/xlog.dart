import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'appender_mode.dart';
import 'decode_mars_nocrypt_log_file.dart';
import 'mars_logging_plugin.dart';
import 'xlog_channel.dart';
import 'xlog_level.dart';

abstract interface class Xlog {
  static XlogChannel get _channel => MarsLoggingPlugin.instance.xlogChannel;

  static XlogLevel get logLevel => _channel.getLogLevel();
  static set logLevel(XlogLevel value) => _channel.setLevel(value, false);

  static set useConsole(bool value) => _channel.setConsoleLogOpen(value);

  static void open({
    XlogLevel level = XlogLevel.verbose,
    AppenderMode mode = AppenderMode.async,
    required String cacheDir,
    required String logDir,
    String nameprefix = '',
    int cacheDays = 0,
  }) {
    _channel.appenderOpen(level, mode, cacheDir, logDir, nameprefix, cacheDays);
  }

  static void close() {
    _channel.appenderClose();
  }

  static void flush() {
    _channel.appenderFlush();
  }

  static void onRecord(LogRecord record) {
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
      _channel.f(tag, message);
    } else if (level >= Level.SEVERE) {
      _channel.e(tag, message);
    } else if (level >= Level.WARNING) {
      _channel.w(tag, message);
    } else if (level >= Level.INFO) {
      _channel.i(tag, message);
    } else if (level >= Level.CONFIG) {
      _channel.d(tag, message);
    } else {
      _channel.v(tag, message);
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
