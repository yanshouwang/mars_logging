package dev.hebei.mars_logging

import android.os.Environment
import java.io.File

class EnvironmentImpl(registrar: MarsLoggingPigeonProxyApiRegistrar) : PigeonApiEnvironment(registrar) {
    override fun getExternalStorageDirectory(): File {
        return Environment.getExternalStorageDirectory()
    }

    override fun getExternalStoragePublicDirectory(type: DirecotryType): File {
        return Environment.getExternalStoragePublicDirectory(type.obj)
    }
}