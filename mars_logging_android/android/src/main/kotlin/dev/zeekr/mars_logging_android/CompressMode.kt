package dev.zeekr.mars_logging_android

import com.tencent.mars.xlog.Xlog

enum class CompressMode(internal val value: Int) {
    ZLIB(Xlog.ZLIB_MODE), ZSTD(Xlog.ZSTD_MODE),
}