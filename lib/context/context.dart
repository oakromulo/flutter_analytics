/// @nodoc
library context;

import '../version_control.dart' show sdkPackage;

import './context_app.dart' show contextApp;
import './context_device.dart' show contextDevice;
import './context_locale.dart' show contextLocale;
import './context_location.dart' show ContextLocation;
import './context_network.dart' show contextNetwork;
import './context_os.dart' show contextOS;

/// @nodoc
class Context {
  static final Future<Map<String, dynamic>> _base = _baseSetup();

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async => {
        ...await _base,
        'locale': await contextLocale(),
        'location': ContextLocation().toJson(),
        'network': await contextNetwork()
      };

  static Future<Map<String, dynamic>> _baseSetup() async => {
        'app': await contextApp(),
        'device': await contextDevice(),
        'library': sdkPackage,
        'os': await contextOS()
      };
}
