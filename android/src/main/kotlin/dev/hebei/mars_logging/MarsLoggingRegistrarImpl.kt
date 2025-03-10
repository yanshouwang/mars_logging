package dev.hebei.mars_logging

import io.flutter.plugin.common.BinaryMessenger

class MarsLoggingRegistrarImpl(binaryMessenger: BinaryMessenger) : MarsLoggingPigeonProxyApiRegistrar(binaryMessenger) {
    override fun getPigeonApiContext(): PigeonApiContext {
        return ContextImpl(this)
    }

    override fun getPigeonApiEnvironment(): PigeonApiEnvironment {
        return EnvironmentImpl(this)
    }

    override fun getPigeonApiFile(): PigeonApiFile {
        return FileImpl(this)
    }

    override fun getPigeonApiXlog(): PigeonApiXlog {
        return XlogImpl(this)
    }

    override fun getPigeonApiLog(): PigeonApiLog {
        return LogImpl(this)
    }
}