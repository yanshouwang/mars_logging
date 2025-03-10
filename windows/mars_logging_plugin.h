#ifndef FLUTTER_PLUGIN_MARS_LOGGING_PLUGIN_H_
#define FLUTTER_PLUGIN_MARS_LOGGING_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace mars_logging {

class MarsLoggingPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  MarsLoggingPlugin();

  virtual ~MarsLoggingPlugin();

  // Disallow copy and assign.
  MarsLoggingPlugin(const MarsLoggingPlugin&) = delete;
  MarsLoggingPlugin& operator=(const MarsLoggingPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace mars_logging

#endif  // FLUTTER_PLUGIN_MARS_LOGGING_PLUGIN_H_
