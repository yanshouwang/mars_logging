package dev.hebei.mars_logging_example

import android.os.Bundle
import com.tencent.mars.xlog.Log
import com.tencent.mars.xlog.Xlog
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    companion object {
        init {
            System.loadLibrary("c++_shared");
            System.loadLibrary("marsxlog");
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // init xlog
        val xlog = Xlog()
        Log.setLogImp(xlog)

        // set up xlog
        val filesDir = this.filesDir
        val externalFilesDir = getExternalFilesDir(null) ?: filesDir

        val cacheDir = filesDir.absolutePath + "/xlog"
        val logDir = externalFilesDir.absolutePath + "/log"
        val nameprefix = "log"
        if (BuildConfig.DEBUG) {
            Log.setConsoleLogOpen(true)
            Log.appenderOpen(
                Xlog.LEVEL_DEBUG, Xlog.AppednerModeAsync, cacheDir, logDir, nameprefix, 0
            )
        } else {
            Log.setConsoleLogOpen(false)
            Log.appenderOpen(
                Xlog.LEVEL_INFO, Xlog.AppednerModeAsync, cacheDir, logDir, nameprefix, 0
            )
        }

        Log.d("MainActivity", "Hello World!")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.appenderClose()
    }
}
