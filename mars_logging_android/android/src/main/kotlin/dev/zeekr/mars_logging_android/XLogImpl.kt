package dev.zeekr.mars_logging_android

class XLogImpl : XLogHostApi {
    override fun open(
        mode: AppenderModeApi,
        level: XLogLevelApi,
        logsDir: String,
        cacheDir: String,
        cacheDays: Long,
        namePrefix: String,
        compressMode: CompressModeApi,
        compressLevel: CompressLevelApi,
        pubKey: String,
        useConsole: Boolean,
        maxFileSize: Long,
        maxAliveDuration: Long
    ) {
        XLog.open(
            mode.impl,
            level.impl,
            logsDir,
            cacheDir,
            cacheDays.toInt(),
            namePrefix,
            compressMode.impl,
            compressLevel.impl,
            pubKey,
            useConsole,
            maxFileSize,
            maxAliveDuration,
        )
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

val AppenderModeApi.impl: AppenderMode
    get() = when (this) {
        AppenderModeApi.ASYNC -> AppenderMode.ASYNC
        AppenderModeApi.SYNC -> AppenderMode.SYNC
    }

val XLogLevelApi.impl: XLogLevel
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

val CompressModeApi.impl: CompressMode
    get() = when (this) {
        CompressModeApi.ZLIB -> CompressMode.ZLIB
        CompressModeApi.ZSTD -> CompressMode.ZSTD
    }

val CompressLevelApi.impl: CompressLevel
    get() = when (this) {
        CompressLevelApi.LEVEL1 -> CompressLevel.LEVEL1
        CompressLevelApi.LEVEL2 -> CompressLevel.LEVEL2
        CompressLevelApi.LEVEL3 -> CompressLevel.LEVEL3
        CompressLevelApi.LEVEL4 -> CompressLevel.LEVEL4
        CompressLevelApi.LEVEL5 -> CompressLevel.LEVEL5
        CompressLevelApi.LEVEL6 -> CompressLevel.LEVEL6
        CompressLevelApi.LEVEL7 -> CompressLevel.LEVEL7
        CompressLevelApi.LEVEL8 -> CompressLevel.LEVEL8
        CompressLevelApi.LEVEL9 -> CompressLevel.LEVEL9
    }