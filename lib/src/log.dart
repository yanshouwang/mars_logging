import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'appender_mode.dart';
import 'log_imp.dart';
import 'mars_logging_plugin.dart';
import 'log_level.dart';

abstract base class Log extends PlatformInterface {
  static final _token = Object();

  Log.impl() : super(token: _token);

  factory Log() => MarsLoggingPlugin.instance.newLog();

  Future<void> setLogImp(LogImp imp);
  Future<void> appenderOpen({
    LogLevel level = LogLevel.verbose,
    AppenderMode mode = AppenderMode.async,
    required String cacheDir,
    required String logDir,
    String nameprefix = '',
    int cacheDays = 0,
  });
  Future<void> appenderClose();
  Future<void> appenderFlush();
  Future<void> appenderFlushSync(bool isSync);
  Future<LogLevel> getLogLevel();
  Future<void> setLevel(LogLevel level, bool jni);
  Future<void> setConsoleLogOpen(bool isOpen);
  Future<void> f(String tag, String msg);
  Future<void> e(String tag, String msg);
  Future<void> w(String tag, String msg);
  Future<void> i(String tag, String msg);
  Future<void> d(String tag, String msg);
  Future<void> v(String tag, String msg);
}
