package dev.hebei.mars_logging

import com.tencent.mars.xlog.Xlog

class XlogImpl(registrar: MarsLoggingPigeonProxyApiRegistrar) : PigeonApiXlog(registrar) {
    override fun pigeon_defaultConstructor(): Xlog {
        return Xlog()
    }
}