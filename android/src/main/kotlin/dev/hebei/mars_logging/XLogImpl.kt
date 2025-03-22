package dev.hebei.mars_logging

class XLogImpl : XLogApi {
    override fun open(
        mode: AppenderModeApi,
        logsDir: String,
        cacheDir: String,
        cacheDays: Long,
        nameprefix: String,
        useConsole: Boolean,
        level: XLogLevelApi
    ) {
        XLog.open(mode.obj, logsDir, cacheDir, cacheDays.toInt(), nameprefix, useConsole, level.obj)
    }

    override fun flush(isSync: Boolean) {
        XLog.flush(isSync)
    }

    override fun close() {
        XLog.close()
    }

    override fun verbose(tag: String, message: String) {
        XLog.verbose(tag, message)
    }

    override fun debug(tag: String, message: String) {
        XLog.debug(tag, message)
    }

    override fun info(tag: String, message: String) {
        XLog.info(tag, message)
    }

    override fun warning(tag: String, message: String) {
        XLog.warning(tag, message)
    }

    override fun error(tag: String, message: String) {
        XLog.error(tag, message)
    }

    override fun fatal(tag: String, message: String) {
        XLog.fatal(tag, message)
    }
}

val AppenderModeApi.obj: AppenderMode
    get() = when (this) {
        AppenderModeApi.ASYNC -> AppenderMode.ASYNC
        AppenderModeApi.SYNC -> AppenderMode.SYNC
    }

val XLogLevelApi.obj: XLogLevel
    get() = when (this) {
        XLogLevelApi.ALL -> XLogLevel.ALL
        XLogLevelApi.VERBOSE -> XLogLevel.VERBOSE
        XLogLevelApi.DEBUG -> XLogLevel.DEBUG
        XLogLevelApi.INFO -> XLogLevel.INFO
        XLogLevelApi.WARNING -> XLogLevel.WARNING
        XLogLevelApi.ERROR -> XLogLevel.ERROR
        XLogLevelApi.FATAL -> XLogLevel.FATAL
        XLogLevelApi.NONE -> XLogLevel.NONE
    }
