// Run with `dart run pigeon --input api.dart`.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/mars_logging.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/hebei/mars_logging/MarsLogging.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.hebei.mars_logging',
      errorClassName: 'MarsLoggingError',
    ),
  ),
)
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.content.Context',
  ),
)
abstract class Context {
  File? getExternalFilesDir(DirecotryType? type);
  List<File> getExternalFilesDirs(DirecotryType? type);
  File getFilesDir();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.os.Environment',
  ),
)
abstract class Environment {
  @static
  File getExternalStorageDirectory();
  @static
  File getExternalStoragePublicDirectory(DirecotryType type);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'java.io.File',
  ),
)
abstract class File {
  String getAbsolutePath();
  String getPath();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.tencent.mars.xlog.Xlog',
  ),
)
abstract class Xlog extends LogImp {
  Xlog();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.tencent.mars.xlog.Log.LogImp',
  ),
)
abstract class LogImp {}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.tencent.mars.xlog.Log',
  ),
)
abstract class Log {
  @static
  void setLogImp(LogImp imp);
  @static
  void appenderOpen(LogLevel level, AppenderMode mode, String cacheDir,
      String logDir, String nameprefix, int cacheDays);
  @static
  void appenderClose();
  @static
  void appenderFlush();
  @static
  void appenderFlushSync(bool isSync);
  @static
  LogLevel getLogLevel();
  @static
  void setLevel(LogLevel level, bool jni);
  @static
  void setConsoleLogOpen(bool isOpen);
  @static
  void f(String tag, String msg);
  @static
  void e(String tag, String msg);
  @static
  void w(String tag, String msg);
  @static
  void i(String tag, String msg);
  @static
  void d(String tag, String msg);
  @static
  void v(String tag, String msg);
}

enum DirecotryType {
  alarms,
  dcim,
  documents,
  downloads,
  movies,
  music,
  notifications,
  pictures,
  podcasts,
  ringtones,
}

enum AppenderMode {
  async,
  sync,
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  fatal,
  none,
}
