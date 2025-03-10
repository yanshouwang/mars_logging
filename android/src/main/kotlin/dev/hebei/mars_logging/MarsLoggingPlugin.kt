package dev.hebei.mars_logging

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** MarsLoggingPlugin */
class MarsLoggingPlugin : FlutterPlugin {
    private lateinit var registrar: MarsLoggingPigeonProxyApiRegistrar

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        registrar = MarsLoggingRegistrarImpl(binding.binaryMessenger)
        registrar.setUp()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        registrar.tearDown()
        registrar.instanceManager.stopFinalizationListener()
    }
}
