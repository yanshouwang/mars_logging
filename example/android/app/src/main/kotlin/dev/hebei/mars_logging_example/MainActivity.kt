package dev.hebei.mars_logging_example

import android.os.Bundle
import com.tencent.mars.xlog.Log
import com.tencent.mars.xlog.Xlog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.util.PathUtils

class MainActivity : FlutterActivity() {
    companion object {
        init {
            System.loadLibrary("c++_shared")
            System.loadLibrary("marsxlog")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Init xlog
        val imp = Xlog()
        Log.setLogImp(imp)
        // Set up xlog
        val mode = Xlog.AppednerModeAsync
        val filesDir = PathUtils.getFilesDir(applicationContext)
        val cacheDir = "$filesDir/logs/cache"
        val logDir = "$filesDir/logs"
        val nameprefix = "log"
        val cacheDays = 0
        if (BuildConfig.DEBUG) {
            Log.setConsoleLogOpen(true)
            Log.appenderOpen(Log.LEVEL_DEBUG, mode, cacheDir, logDir, nameprefix, cacheDays)
        } else {
            Log.setConsoleLogOpen(false)
            Log.appenderOpen(Log.LEVEL_INFO, mode, cacheDir, logDir, nameprefix, cacheDays)
        }
    }

    override fun onDestroy() {
        Log.appenderClose()
        super.onDestroy()
    }
}
