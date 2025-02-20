import 'package:jni/jni.dart' as jni;

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
  List<String> get externalFilesDirs {
    final jType = jni.JString.fromReference(jni.jNullReference);
    final jDirs = jni.context.getExternalFilesDirs(jType);
    final dirs = <String>[];
    for (var i = 0; i < jDirs.length; i++) {
      final jDir = jDirs[i];
      if (jDir.isNull) {
        continue;
      }
      final dir = jDir.getAbsolutePath().toDartString(
            releaseOriginal: true,
          );
      dirs.add(dir);
    }
    return dirs;
  }

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
  String get filesDir {
    return jni.context.getFilesDir().getAbsolutePath().toDartString(
          releaseOriginal: true,
        );
  }

  @override
  String get storageDir =>
      jni.Environment.getStorageDirectory().getAbsolutePath().toDartString(
            releaseOriginal: true,
          );
}

final class XlogChannelImpl implements XlogChannel {
  static XlogChannelImpl? _instance;

  factory XlogChannelImpl() {
    var instance = _instance;
    if (instance == null) {
      // init xlog
      final logImpl = jni.Xlog().as(jni.Log_LogImp.type);
      jni.Log.setLogImp(logImpl);
      _instance = instance = XlogChannelImpl._();
    }
    return instance;
  }

  XlogChannelImpl._();

  @override
  void appenderOpen(XlogLevel level, AppenderMode mode, String cacheDir,
      String logDir, String nameprefix, int cacheDays) {
    final jLevel = level.toJLogLevel();
    final jMode = mode.toJAppenderMode();
    final jCacheDir = cacheDir.toJString();
    final jLogDir = logDir.toJString();
    final jNameprefix = nameprefix.toJString();
    final jCacheDays = cacheDays;
    jni.Log.appenderOpen(
        jLevel, jMode, jCacheDir, jLogDir, jNameprefix, jCacheDays);
  }

  @override
  void appenderClose() {
    jni.Log.appenderClose();
  }

  @override
  void appenderFlush() {
    jni.Log.appenderFlush();
  }

  @override
  void appenderFlushSync(bool isSync) {
    jni.Log.appenderFlushSync(isSync);
  }

  @override
  XlogLevel getLogLevel() {
    final jLevel = jni.Log.getLogLevel();
    return jLevel.toXlogLevel();
  }

  @override
  void setLevel(XlogLevel level, bool $jni) {
    final jLevel = level.toJLogLevel();
    jni.Log.setLevel(jLevel, $jni);
  }

  @override
  void setConsoleLogOpen(bool isOpen) {
    jni.Log.setConsoleLogOpen(isOpen);
  }

  @override
  void d(String tag, String msg) {
    final jTag = tag.toJString();
    final jMsg = msg.toJString();
    jni.Log.d(jTag, jMsg);
  }

  @override
  void e(String tag, String msg) {
    final jTag = tag.toJString();
    final jMsg = msg.toJString();
    jni.Log.e(jTag, jMsg);
  }

  @override
  void f(String tag, String msg) {
    final jTag = tag.toJString();
    final jMsg = msg.toJString();
    jni.Log.f(jTag, jMsg);
  }

  @override
  void i(String tag, String msg) {
    final jTag = tag.toJString();
    final jMsg = msg.toJString();
    jni.Log.i(jTag, jMsg);
  }

  @override
  void v(String tag, String msg) {
    final jTag = tag.toJString();
    final jMsg = msg.toJString();
    jni.Log.v(jTag, jMsg);
  }

  @override
  void w(String tag, String msg) {
    final jTag = tag.toJString();
    final jMsg = msg.toJString();
    jni.Log.w(jTag, jMsg);
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
  int toJLogLevel() {
    switch (this) {
      case XlogLevel.verbose:
        return jni.Log.LEVEL_VERBOSE;
      case XlogLevel.debug:
        return jni.Log.LEVEL_DEBUG;
      case XlogLevel.info:
        return jni.Log.LEVEL_INFO;
      case XlogLevel.warning:
        return jni.Log.LEVEL_WARNING;
      case XlogLevel.error:
        return jni.Log.LEVEL_ERROR;
      case XlogLevel.fatal:
        return jni.Log.LEVEL_FATAL;
      case XlogLevel.none:
        return jni.Log.LEVEL_NONE;
    }
  }
}

extension on int {
  XlogLevel toXlogLevel() {
    switch (this) {
      case jni.Log.LEVEL_VERBOSE:
        return XlogLevel.verbose;
      case jni.Log.LEVEL_DEBUG:
        return XlogLevel.debug;
      case jni.Log.LEVEL_INFO:
        return XlogLevel.info;
      case jni.Log.LEVEL_WARNING:
        return XlogLevel.warning;
      case jni.Log.LEVEL_ERROR:
        return XlogLevel.error;
      case jni.Log.LEVEL_FATAL:
        return XlogLevel.fatal;
      case jni.Log.LEVEL_NONE:
        return XlogLevel.none;
      default:
        throw ArgumentError.value(this);
    }
  }
}
