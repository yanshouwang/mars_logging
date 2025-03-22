package dev.hebei.mars_logging

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** MarsLoggingPlugin */
class MarsLoggingPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val api = XLogImpl()
        XLogApi.setUp(binding.binaryMessenger, api)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        XLogApi.setUp(binding.binaryMessenger, null)
    }
}
