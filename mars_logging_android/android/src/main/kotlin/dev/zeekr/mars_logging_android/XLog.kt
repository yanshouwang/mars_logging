package dev.zeekr.mars_logging_android

import com.tencent.mars.xlog.Log
import com.tencent.mars.xlog.Xlog

object XLog {
    fun open(
        mode: AppenderMode,
        logsDir: String,
        cacheDir: String,
        cacheDays: Int,
        nameprefix: String,
        useConsole: Boolean,
        level: XLogLevel
    ) {
        System.loadLibrary("c++_shared")
        System.loadLibrary("marsxlog")

        val imp = Xlog()
        Log.setLogImp(imp)

        Log.appenderOpen(level.value, mode.value, cacheDir, logsDir, nameprefix, cacheDays)
        Log.setConsoleLogOpen(useConsole)
    }

    fun flush(isSync: Boolean) {
        Log.appenderFlushSync(isSync)
    }

    fun close() {
        Log.appenderClose()
    }

    fun verbose(tag: String, message: String) {
        Log.v(tag, message)
    }

    fun debug(tag: String, message: String) {
        Log.d(tag, message)
    }

    fun info(tag: String, message: String) {
        Log.i(tag, message)
    }

    fun warning(tag: String, message: String) {
        Log.w(tag, message)
    }

    fun error(tag: String, message: String) {
        Log.e(tag, message)
    }

    fun fatal(tag: String, message: String) {
        Log.f(tag, message)
    }
}