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

  static setLogLevel(XlogLevel logLevel) => _channel.setLogLevel(logLevel);
  static setAppenderMode(AppenderMode mode) => _channel.setAppenderMode(mode);
  static setConsoleLogOpen(bool isOpen) => _channel.setConsoleLogOpen(isOpen);
  static setErrLogOpen(bool isOpen) => _channel.setErrLogOpen(isOpen);
  static setMaxFileSize(int size) => _channel.setMaxFileSize(size);
  static setMaxAliveTime(int duration) => _channel.setMaxAliveTime(duration);

  static void appenderOpen({
    XlogLevel level = XlogLevel.all,
    AppenderMode mode = AppenderMode.async,
    required String cacheDir,
    required String logDir,
    String nameprefix = '',
    int cacheDays = 0,
    String pubKey = '',
  }) {
    _channel.appenderOpen(
      level: level,
      mode: mode,
      cacheDir: cacheDir,
      logDir: logDir,
      nameprefix: nameprefix,
      cacheDays: cacheDays,
      pubKey: pubKey,
    );
  }

  static void appenderClose() {
    _channel.appenderClose();
  }

  static void appenderFlush(bool isSync) {
    _channel.appenderFlush(isSync);
  }

  static void onRecord(LogRecord record) {
    _channel.onRecord(record);
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
