import 'package:mars_logging/src/log_imp.dart';

import 'appender_mode.dart';
import 'mars_logging.g.dart' as api;
import 'mars_logging_plugin.dart';
import 'log.dart';
import 'log_level.dart';
import 'xlog.dart';

final class MarsLoggingPluginImpl extends MarsLoggingPlugin {
  @override
  Log newLog() => LogImpl();
  @override
  Xlog newXlog() => XlogImpl();
}

final class LogImpl extends Log {
  static LogImpl? _instance;

  LogImpl.impl() : super.impl();

  factory LogImpl() {
    var instance = _instance;
    if (instance == null) {
      _instance = instance = LogImpl.impl();
    }
    return instance;
  }

  @override
  Future<void> $setLogImp(LogImp imp) async {
    if (imp is! LogImpImpl) {
      throw TypeError();
    }
    await api.Log.setLogImp(imp.args);
  }

  @override
  Future<void> $appenderOpen(LogLevel level, AppenderMode mode, String cacheDir,
      String logDir, String nameprefix, int cacheDays) async {
    await api.Log.appenderOpen(
        level, mode, cacheDir, logDir, nameprefix, cacheDays);
  }

  @override
  Future<void> $appenderClose() async {
    await api.Log.appenderClose();
  }

  @override
  Future<void> $appenderFlush() async {
    await api.Log.appenderFlush();
  }

  @override
  Future<void> $appenderFlushSync(bool isSync) async {
    await api.Log.appenderFlushSync(isSync);
  }

  @override
  Future<LogLevel> $getLogLevel() async {
    final value = await api.Log.getLogLevel();
    return value;
  }

  @override
  Future<void> $setLevel(LogLevel level, bool jni) async {
    await api.Log.setLevel(level, jni);
  }

  @override
  Future<void> $setConsoleLogOpen(bool isOpen) async {
    await api.Log.setConsoleLogOpen(isOpen);
  }

  @override
  Future<void> $d(String tag, String msg) async {
    await api.Log.d(tag, msg);
  }

  @override
  Future<void> $e(String tag, String msg) async {
    await api.Log.e(tag, msg);
  }

  @override
  Future<void> $f(String tag, String msg) async {
    await api.Log.f(tag, msg);
  }

  @override
  Future<void> $i(String tag, String msg) async {
    await api.Log.i(tag, msg);
  }

  @override
  Future<void> $v(String tag, String msg) async {
    await api.Log.v(tag, msg);
  }

  @override
  Future<void> $w(String tag, String msg) async {
    await api.Log.w(tag, msg);
  }
}

base mixin LogImpImpl on LogImp {
  api.LogImp get args;
}

final class XlogImpl extends Xlog with LogImpImpl {
  @override
  final api.Xlog args;

  XlogImpl.impl(this.args) : super.impl();

  factory XlogImpl() {
    final args = api.Xlog();
    return XlogImpl.impl(args);
  }
}
