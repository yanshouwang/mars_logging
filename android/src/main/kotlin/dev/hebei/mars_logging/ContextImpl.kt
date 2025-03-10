package dev.hebei.mars_logging

import android.content.Context
import android.os.Environment
import java.io.File

class ContextImpl(registrar: MarsLoggingPigeonProxyApiRegistrar) : PigeonApiContext(registrar) {
    override fun getExternalFilesDir(pigeon_instance: Context, type: DirecotryType?): File? {
        return pigeon_instance.getExternalFilesDir(type?.obj)
    }

    override fun getExternalFilesDirs(pigeon_instance: Context, type: DirecotryType?): List<File> {
        return pigeon_instance.getExternalFilesDirs(type?.obj).toList()
    }

    override fun getFilesDir(pigeon_instance: Context): File {
        return pigeon_instance.filesDir
    }
}

val DirecotryType.obj: String
    get() = when (this) {
        DirecotryType.ALARMS -> Environment.DIRECTORY_ALARMS
        DirecotryType.DCIM -> Environment.DIRECTORY_DCIM
        DirecotryType.DOCUMENTS -> Environment.DIRECTORY_DOCUMENTS
        DirecotryType.DOWNLOADS -> Environment.DIRECTORY_DOWNLOADS
        DirecotryType.MOVIES -> Environment.DIRECTORY_MOVIES
        DirecotryType.MUSIC -> Environment.DIRECTORY_MUSIC
        DirecotryType.NOTIFICATIONS -> Environment.DIRECTORY_NOTIFICATIONS
        DirecotryType.PICTURES -> Environment.DIRECTORY_PICTURES
        DirecotryType.PODCASTS -> Environment.DIRECTORY_PODCASTS
        DirecotryType.RINGTONES -> Environment.DIRECTORY_RINGTONES
    }