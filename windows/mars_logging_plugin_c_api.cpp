#include "include/mars_logging/mars_logging_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "mars_logging_plugin.h"

void MarsLoggingPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  mars_logging::MarsLoggingPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
