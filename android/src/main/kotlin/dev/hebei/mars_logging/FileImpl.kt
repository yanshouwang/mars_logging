package dev.hebei.mars_logging

import java.io.File

class FileImpl(registrar: MarsLoggingPigeonProxyApiRegistrar) : PigeonApiFile(registrar) {
    override fun getAbsolutePath(pigeon_instance: File): String {
        return pigeon_instance.absolutePath
    }

    override fun getPath(pigeon_instance: File): String {
        return pigeon_instance.path
    }
}