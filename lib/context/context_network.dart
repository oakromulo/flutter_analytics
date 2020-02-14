/// @nodoc
library context_network;

import 'package:connectivity/connectivity.dart'
    show Connectivity, ConnectivityResult;

import '../debug/debug.dart' show Debug;

/// @nodoc
Future<Map<String, dynamic>> contextNetwork() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();

    return {
      'cellular': connectivityResult == ConnectivityResult.mobile,
      'wifi': connectivityResult == ConnectivityResult.wifi
    };
  } catch (e, s) {
    Debug().error(e, s);

    return <String, dynamic>{};
  }
}
