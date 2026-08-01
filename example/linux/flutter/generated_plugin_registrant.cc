//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <hornbill/hornbill_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) hornbill_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HornbillPlugin");
  hornbill_plugin_register_with_registrar(hornbill_registrar);
}
