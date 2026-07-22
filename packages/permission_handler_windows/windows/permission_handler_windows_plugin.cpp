// Stub Windows implementation of permission_handler_windows.
//
// On Windows, camera/gallery/storage access does NOT require Android-style
// runtime permission requests. This stub reports every permission as GRANTED
// so the app compiles and runs on Windows without the deprecated
// <experimental/coroutine> header that permission_handler_windows 0.2.1
// pulls in via cppwinrt 2.0.210806.1 (broken on VS 2026).

#include "include/permission_handler_windows/permission_handler_windows_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/encodable_value.h>

#include <memory>
#include <string>

namespace {

using namespace flutter;

// Permission status constants (mirrors PermissionStatus in permission_handler)
static const int kGranted         = 1;
static const int kServiceEnabled  = 1;  // ServiceStatus.enabled
static const int kNotApplicable   = 5;  // ServiceStatus.notApplicable

class PermissionHandlerWindowsPlugin : public Plugin {
 public:
  static void RegisterWithRegistrar(PluginRegistrar* registrar);

  PermissionHandlerWindowsPlugin() = default;
  virtual ~PermissionHandlerWindowsPlugin() = default;

  // Disallow copy and move.
  PermissionHandlerWindowsPlugin(const PermissionHandlerWindowsPlugin&) = delete;
  PermissionHandlerWindowsPlugin& operator=(const PermissionHandlerWindowsPlugin&) = delete;

  void HandleMethodCall(const MethodCall<>& method_call,
                        std::unique_ptr<MethodResult<>> result);
};

// static
void PermissionHandlerWindowsPlugin::RegisterWithRegistrar(
    PluginRegistrar* registrar) {
  auto channel = std::make_unique<MethodChannel<>>(
      registrar->messenger(),
      "flutter.baseflow.com/permissions/methods",
      &StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<PermissionHandlerWindowsPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

void PermissionHandlerWindowsPlugin::HandleMethodCall(
    const MethodCall<>& method_call,
    std::unique_ptr<MethodResult<>> result) {

  const auto& name = method_call.method_name();

  if (name == "checkPermissionStatus") {
    // Always GRANTED on Windows
    result->Success(EncodableValue(kGranted));

  } else if (name == "requestPermissions") {
    // Return GRANTED for every requested permission
    const auto* args = std::get_if<EncodableList>(method_call.arguments());
    EncodableMap response;
    if (args) {
      for (const auto& item : *args) {
        response[item] = EncodableValue(kGranted);
      }
    }
    result->Success(EncodableValue(response));

  } else if (name == "checkServiceStatus") {
    // Report all services as enabled / not-applicable
    result->Success(EncodableValue(kNotApplicable));

  } else if (name == "shouldShowRequestPermissionRationale") {
    result->Success(EncodableValue(false));

  } else if (name == "openAppSettings") {
    result->Success(EncodableValue(true));

  } else {
    result->NotImplemented();
  }
}

}  // namespace

void PermissionHandlerWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  PermissionHandlerWindowsPlugin::RegisterWithRegistrar(
      PluginRegistrarManager::GetInstance()
          ->GetRegistrar<PluginRegistrarWindows>(registrar));
}
