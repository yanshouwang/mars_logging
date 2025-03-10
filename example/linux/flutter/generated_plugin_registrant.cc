//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <mars_logging/mars_logging_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) mars_logging_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MarsLoggingPlugin");
  mars_logging_plugin_register_with_registrar(mars_logging_registrar);
}
