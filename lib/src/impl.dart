import 'package:jni/jni.dart' as jni;
import 'package:logging/logging.dart';

import 'appender_mode.dart';
import 'dirs_channel.dart';
import 'jni.dart' as jni;
import 'mars_logging_plugin.dart';
import 'xlog_channel.dart';
import 'xlog_level.dart';

final class MarsLoggingPluginImpl extends MarsLoggingPlugin {
  @override
  DirsChannel get dirsChannel => DirsChannelImpl();
  @override
  XlogChannel get xlogChannel => XlogChannelImpl();
}

final class DirsChannelImpl implements DirsChannel {
  static DirsChannelImpl? _instance;

  factory DirsChannelImpl() {
    var instance = _instance;
    if (instance == null) {
      _instance = instance = DirsChannelImpl._();
    }
    return instance;
  }

  DirsChannelImpl._();

  @override
  String? get externalFilesDir {
    final jType = jni.JString.fromReference(jni.jNullReference);
    final jDir = jni.context.getExternalFilesDir(jType);
    return jDir.isNull
        ? null
        : jDir.getAbsolutePath().toDartString(
              releaseOriginal: true,
            );
  }

  @override
  String get filesDir =>
      jni.context.getFilesDir().getAbsolutePath().toDartString(
            releaseOriginal: true,
          );
}

final class XlogChannelImpl implements XlogChannel {
  static XlogChannelImpl? _instance;

  factory XlogChannelImpl() {
    var instance = _instance;
    if (instance == null) {
      _instance = instance = XlogChannelImpl._();
    }
    return instance;
  }

  XlogChannelImpl._();

  @override
  void setLogLevel(XlogLevel logLevel) {
    final jLogLevel = logLevel.toJXlogLevel();
    jni.Xlog.setLogLevel(jLogLevel);
  }

  @override
  void appenderClose() {
    jni.Log.appenderClose();
  }

  @override
  void appenderFlush(bool isSync) {
    jni.Log.appenderFlush(isSync);
  }

  @override
  void setAppenderMode(AppenderMode mode) {
    final jMode = mode.toJAppenderMode();
    jni.Xlog.setAppenderMode(jMode);
  }

  @override
  void appenderOpen({
    required XlogLevel level,
    required AppenderMode mode,
    required String cacheDir,
    required String logDir,
    required String nameprefix,
    required int cacheDays,
    required String pubKey,
  }) {
    jni.Xlog.appenderOpen(
      level.toJXlogLevel(),
      mode.toJAppenderMode(),
      cacheDir.toJString(),
      logDir.toJString(),
      nameprefix.toJString(),
      cacheDays,
      pubKey.toJString(),
    );
    // init xlog
    final logImpl = jni.Xlog().as(jni.Log_LogImp.type);
    jni.Log.setLogImp(logImpl);
  }

  @override
  void setConsoleLogOpen(bool isOpen) {
    jni.Xlog.setConsoleLogOpen(isOpen);
  }

  @override
  void setErrLogOpen(bool isOpen) {
    jni.Xlog.setErrLogOpen(isOpen);
  }

  @override
  void setMaxAliveTime(int duration) {
    jni.Xlog.setMaxAliveTime(duration);
  }

  @override
  void setMaxFileSize(int size) {
    jni.Xlog.setMaxFileSize(size);
  }

  @override
  void onRecord(LogRecord record) {
    final level = record.level;
    final loggerName = record.loggerName;
    final message = record.message;
    final error = record.error;
    final stackTrace = record.stackTrace;
    final jName = loggerName.toJString();
    final valueBuilder = StringBuffer();
    valueBuilder.write(message);
    if (error != null) {
      valueBuilder.writeln();
      valueBuilder.write(error);
    }
    if (stackTrace != null) {
      valueBuilder.writeln();
      valueBuilder.write(stackTrace);
    }
    final jValue = valueBuilder.toString().toJString();
    if (level >= Level.SHOUT) {
      jni.Log.f(jName, jValue);
    } else if (level >= Level.SEVERE) {
      jni.Log.e(jName, jValue);
    } else if (level >= Level.WARNING) {
      jni.Log.w(jName, jValue);
    } else if (level >= Level.INFO) {
      jni.Log.i(jName, jValue);
    } else if (level >= Level.CONFIG) {
      jni.Log.d(jName, jValue);
    } else {
      jni.Log.v(jName, jValue);
    }
  }
}

extension on AppenderMode {
  int toJAppenderMode() {
    switch (this) {
      case AppenderMode.async:
        return jni.Xlog.AppednerModeAsync;
      case AppenderMode.sync:
        return jni.Xlog.AppednerModeSync;
    }
  }
}

extension on XlogLevel {
  int toJXlogLevel() {
    switch (this) {
      case XlogLevel.all:
        return jni.Xlog.LEVEL_ALL;
      case XlogLevel.verbose:
        return jni.Xlog.LEVEL_VERBOSE;
      case XlogLevel.debug:
        return jni.Xlog.LEVEL_DEBUG;
      case XlogLevel.info:
        return jni.Xlog.LEVEL_INFO;
      case XlogLevel.warning:
        return jni.Xlog.LEVEL_WARNING;
      case XlogLevel.error:
        return jni.Xlog.LEVEL_ERROR;
      case XlogLevel.fatal:
        return jni.Xlog.LEVEL_FATAL;
      case XlogLevel.none:
        return jni.Xlog.LEVEL_NONE;
    }
  }
}
