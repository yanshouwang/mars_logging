import 'appender_mode.dart';
import 'xlog_level.dart';

abstract interface class XlogChannel {
  void appenderOpen(XlogLevel level, AppenderMode mode, String cacheDir,
      String logDir, String nameprefix, int cacheDays);
  void appenderClose();
  void appenderFlush();
  void appenderFlushSync(bool isSync);
  XlogLevel getLogLevel();
  void setLevel(XlogLevel level, bool jni);
  void setConsoleLogOpen(bool isOpen);
  void f(String tag, String msg);
  void e(String tag, String msg);
  void w(String tag, String msg);
  void i(String tag, String msg);
  void d(String tag, String msg);
  void v(String tag, String msg);
}
