import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'appender_mode.dart';
import 'mars_logging_plugin.dart';
import 'xlog_level.dart';

abstract base class XLogApi extends PlatformInterface {
  static final _token = Object();

  XLogApi.impl() : super(token: _token);

  factory XLogApi() => MarsLoggingPlugin.instance.newXLogApi();

  Future<void> open(AppenderMode mode, String logsDir, String cacheDir,
      int cacheDays, String nameprefix, bool useConsole, XLogLevel level);
  Future<void> flush(bool isSync);
  Future<void> close();
  Future<void> verbose(String tag, String message);
  Future<void> debug(String tag, String message);
  Future<void> info(String tag, String message);
  Future<void> warning(String tag, String message);
  Future<void> error(String tag, String message);
  Future<void> fatal(String tag, String message);
}
