import 'dart:isolate';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import 'decode_mars_nocrypt_log_file.dart';
import 'log.dart';

abstract final class Mars {
  static Log get _log => Log();

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
      await _log.f(tag, message);
    } else if (level >= Level.SEVERE) {
      await _log.e(tag, message);
    } else if (level >= Level.WARNING) {
      await _log.w(tag, message);
    } else if (level >= Level.INFO) {
      await _log.i(tag, message);
    } else if (level >= Level.CONFIG) {
      await _log.d(tag, message);
    } else {
      await _log.v(tag, message);
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
