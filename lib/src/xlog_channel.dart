import 'package:logging/logging.dart';

import 'appender_mode.dart';
import 'xlog_level.dart';

abstract interface class XlogChannel {
  void setLogLevel(XlogLevel logLevel);
  void setAppenderMode(AppenderMode mode);
  void setConsoleLogOpen(bool isOpen);
  void setErrLogOpen(bool isOpen);
  void setMaxFileSize(int size);
  void setMaxAliveTime(int duration);

  void appenderOpen({
    required XlogLevel level,
    required AppenderMode mode,
    required String cacheDir,
    required String logDir,
    required String nameprefix,
    required int cacheDays,
    required String pubKey,
  });

  void appenderFlush(bool isSync);

  void appenderClose();

  void onRecord(LogRecord record);
}
