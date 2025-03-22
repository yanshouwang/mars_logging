package dev.hebei.mars_logging_example

import android.os.Bundle
import dev.hebei.mars_logging.AppenderMode
import dev.hebei.mars_logging.XLog
import dev.hebei.mars_logging.XLogLevel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.util.PathUtils

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val mode = AppenderMode.ASYNC
        val filesDir = PathUtils.getFilesDir(applicationContext)
        val logsDir = "$filesDir/logs"
        val cacheDir = "$filesDir/cache"
        val cacheDays = 0
        val nameprefix = "log"
        if (BuildConfig.DEBUG) {
            XLog.open(mode, logsDir, cacheDir, cacheDays, nameprefix, true, XLogLevel.DEBUG)
        } else {
            XLog.open(mode, logsDir, cacheDir, cacheDays, nameprefix, false, XLogLevel.INFO)
        }
    }

    override fun onDestroy() {
        XLog.close()
        super.onDestroy()
    }
}
