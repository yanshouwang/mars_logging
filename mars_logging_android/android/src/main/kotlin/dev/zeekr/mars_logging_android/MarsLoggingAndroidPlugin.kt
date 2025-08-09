package dev.zeekr.mars_logging_android

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** MarsLoggingAndroidPlugin */
class MarsLoggingAndroidPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val binaryMessenger = binding.binaryMessenger
        val api = XLogImpl()
        XLogHostApi.setUp(binaryMessenger, api)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val binaryMessenger = binding.binaryMessenger
        XLogHostApi.setUp(binaryMessenger, null)
    }
}
