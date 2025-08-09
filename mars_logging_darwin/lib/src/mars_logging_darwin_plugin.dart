import 'package:mars_logging_platform_interface/mars_logging_platform_interface.dart';

import 'xlog_impl.dart';

abstract final class MarsLoggingDarwinPlugin {
  static void registerWith() {
    XLogApi.instance = XLogImpl();
  }
}
