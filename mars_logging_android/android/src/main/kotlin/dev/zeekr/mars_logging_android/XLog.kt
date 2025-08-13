package dev.zeekr.mars_logging_android

import com.tencent.mars.xlog.Log
import com.tencent.mars.xlog.Xlog

object XLog {
    fun open(
        mode: AppenderMode,
        level: XLogLevel,
        logsDir: String,
        cacheDir: String,
        cacheDays: Int,
        namePrefix: String,
        compressMode: CompressMode,
        compressLevel: CompressLevel,
        pubKey: String,
        useConsole: Boolean,
        maxFileSize: Long,
        maxAliveDuration: Long,
    ) {
        System.loadLibrary("c++_shared")
        System.loadLibrary("marsxlog")

        val imp = Xlog()
        imp.setConsoleLogOpen(0, useConsole)
        imp.setMaxFileSize(0, maxFileSize)
        imp.setMaxAliveTime(0, maxAliveDuration)
        val config = Xlog.XLogConfig()
        config.mode = mode.value
        config.level = level.value
        config.logdir = logsDir
        config.cachedir = cacheDir
        config.cachedays = cacheDays
        config.nameprefix = namePrefix
        config.compressmode = compressMode.value
        config.compresslevel = compressLevel.value
        config.pubkey = pubKey
        appenderOpen(config)
        Log.setLogImp(imp)
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

    private external fun appenderOpen(config: Xlog.XLogConfig)
}