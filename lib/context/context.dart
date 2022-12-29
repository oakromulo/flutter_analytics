/// @nodoc
library context;

import './context_app.dart' show contextApp;
import './context_device.dart' show contextDevice;
import './context_locale.dart' show contextLocale;
import './context_location.dart' show ContextLocation;
import './context_network.dart' show ContextNetwork;
import './context_os.dart' show contextOS;
import '../store/store.dart' show Store;
import '../version_control.dart' show sdkPackage;

/// @nodoc
class Context {
  static final Future<Map<String, dynamic>> _base = _baseSetup();

  /// @nodoc
  static Map<String, dynamic>? traits;

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async => <String, dynamic>{
        ...await _base,
        'groupId': await Store().groupId,
        'locale': await contextLocale(),
        'location': ContextLocation().toJson(),
        'network': await ContextNetwork().toMap(),
        'traits': traits ?? <String, dynamic>{}
      };

  static Future<Map<String, dynamic>> _baseSetup() async => <String, dynamic>{
        'app': await contextApp(),
        'device': await contextDevice(),
        'library': sdkPackage,
        'os': await contextOS()
      };
}
