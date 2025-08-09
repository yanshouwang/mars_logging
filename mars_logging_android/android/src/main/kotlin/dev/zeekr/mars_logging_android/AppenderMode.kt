package dev.zeekr.mars_logging_android

import com.tencent.mars.xlog.Xlog

enum class AppenderMode(internal val value: Int) {
    ASYNC(Xlog.AppednerModeAsync),
    SYNC(Xlog.AppednerModeSync),
}