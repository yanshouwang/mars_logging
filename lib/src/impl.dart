import 'appender_mode.dart';
import 'mars_logging.api.dart' as api;
import 'mars_logging_plugin.dart';
import 'xlog_api.dart';
import 'xlog_level.dart';

final class MarsLoggingPluginImpl extends MarsLoggingPlugin {
  @override
  XLogApi newXLogApi() => _XLogApi();
}

final class _XLogApi extends XLogApi {
  final api.XLogApi _obj;

  _XLogApi.impl(this._obj) : super.impl();

  factory _XLogApi() {
    final obj = api.XLogApi();
    return _XLogApi.impl(obj);
  }

  @override
  Future<void> open(
      AppenderMode mode,
      String logsDir,
      String cacheDir,
      int cacheDays,
      String nameprefix,
      bool useConsole,
      XLogLevel level) async {
    await _obj.open(
        mode, logsDir, cacheDir, cacheDays, nameprefix, useConsole, level);
  }

  @override
  Future<void> flush(bool isSync) async {
    await _obj.flush(isSync);
  }

  @override
  Future<void> close() async {
    await _obj.close();
  }

  @override
  Future<void> verbose(String tag, String message) async {
    await _obj.verbose(tag, message);
  }

  @override
  Future<void> debug(String tag, String message) async {
    await _obj.debug(tag, message);
  }

  @override
  Future<void> info(String tag, String message) async {
    await _obj.info(tag, message);
  }

  @override
  Future<void> warning(String tag, String message) async {
    await _obj.warning(tag, message);
  }

  @override
  Future<void> error(String tag, String message) async {
    await _obj.error(tag, message);
  }

  @override
  Future<void> fatal(String tag, String message) async {
    await _obj.fatal(tag, message);
  }
}
