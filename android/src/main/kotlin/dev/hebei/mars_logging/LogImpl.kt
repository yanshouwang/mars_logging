package dev.hebei.mars_logging

import com.tencent.mars.xlog.Log
import com.tencent.mars.xlog.Xlog

class LogImpl(registrar: MarsLoggingPigeonProxyApiRegistrar) : PigeonApiLog(registrar) {
    override fun setLogImp(imp: Log.LogImp) {
        Log.setLogImp(imp)
    }

    override fun appenderOpen(
        level: LogLevel, mode: AppenderMode, cacheDir: String, logDir: String, nameprefix: String, cacheDays: Long
    ) {
        Log.appenderOpen(level.obj, mode.obj, cacheDir, logDir, nameprefix, cacheDays.toInt())
    }

    override fun appenderClose() {
        Log.appenderClose()
    }

    override fun appenderFlush() {
        Log.appenderFlush()
    }

    override fun appenderFlushSync(isSync: Boolean) {
        Log.appenderFlushSync(isSync)
    }

    override fun getLogLevel(): LogLevel {
        return Log.getLogLevel().logLevelArgs
    }

    override fun setLevel(level: LogLevel, jni: Boolean) {
        Log.setLevel(level.obj, jni)
    }

    override fun setConsoleLogOpen(isOpen: Boolean) {
        Log.setConsoleLogOpen(isOpen)
    }

    override fun f(tag: String, msg: String) {
        Log.f(tag, msg)
    }

    override fun e(tag: String, msg: String) {
        Log.e(tag, msg)
    }

    override fun w(tag: String, msg: String) {
        Log.w(tag, msg)
    }

    override fun i(tag: String, msg: String) {
        Log.i(tag, msg)
    }

    override fun d(tag: String, msg: String) {
        Log.d(tag, msg)
    }

    override fun v(tag: String, msg: String) {
        Log.v(tag, msg)
    }
}

val AppenderMode.obj: Int
    get() = when (this) {
        AppenderMode.ASYNC -> Xlog.AppednerModeAsync
        AppenderMode.SYNC -> Xlog.AppednerModeSync
    }

val LogLevel.obj: Int
    get() = when (this) {
        LogLevel.VERBOSE -> Log.LEVEL_VERBOSE
        LogLevel.DEBUG -> Log.LEVEL_DEBUG
        LogLevel.INFO -> Log.LEVEL_INFO
        LogLevel.WARNING -> Log.LEVEL_WARNING
        LogLevel.ERROR -> Log.LEVEL_ERROR
        LogLevel.FATAL -> Log.LEVEL_FATAL
        LogLevel.NONE -> Log.LEVEL_NONE
    }

val Int.logLevelArgs: LogLevel
    get() = when (this) {
        Log.LEVEL_VERBOSE -> LogLevel.VERBOSE
        Log.LEVEL_DEBUG -> LogLevel.DEBUG
        Log.LEVEL_INFO -> LogLevel.INFO
        Log.LEVEL_WARNING -> LogLevel.WARNING
        Log.LEVEL_ERROR -> LogLevel.ERROR
        Log.LEVEL_FATAL -> LogLevel.FATAL
        Log.LEVEL_NONE -> LogLevel.NONE
        else -> throw IllegalArgumentException()
    }