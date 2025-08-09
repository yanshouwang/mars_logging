import 'package:mars_logging_platform_interface/mars_logging_platform_interface.dart';

import 'mars_logging_api.g.dart';

final class XLogImpl extends XLogApi {
  final XLogHostApi _api;

  XLogImpl.internal(this._api) : super.impl();

  factory XLogImpl() {
    final api = XLogHostApi();
    return XLogImpl.internal(api);
  }

  @override
  Future<void> open(
    AppenderMode mode,
    String logsDir,
    String cacheDir,
    int cacheDays,
    String nameprefix,
    bool useConsole,
    XLogLevel level,
  ) async {
    await _api.open(
      mode.api,
      logsDir,
      cacheDir,
      cacheDays,
      nameprefix,
      useConsole,
      level.api,
    );
  }

  @override
  Future<void> flush(bool isSync) async {
    await _api.flush(isSync);
  }

  @override
  Future<void> close() async {
    await _api.close();
  }

  @override
  Future<void> verbose(String tag, String message) async {
    await _api.verbose(tag, message);
  }

  @override
  Future<void> debug(String tag, String message) async {
    await _api.debug(tag, message);
  }

  @override
  Future<void> info(String tag, String message) async {
    await _api.info(tag, message);
  }

  @override
  Future<void> warning(String tag, String message) async {
    await _api.warning(tag, message);
  }

  @override
  Future<void> error(String tag, String message) async {
    await _api.error(tag, message);
  }

  @override
  Future<void> fatal(String tag, String message) async {
    await _api.fatal(tag, message);
  }
}

extension on AppenderMode {
  AppenderModeApi get api => AppenderModeApi.values[index];
}

extension on XLogLevel {
  XLogLevelApi get api => XLogLevelApi.values[index];
}
