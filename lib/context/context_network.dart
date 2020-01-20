/// @nodoc
library context_network;

import 'package:connectivity/connectivity.dart'
    show Connectivity, ConnectivityResult;

import '../util/util.dart' as util show debugError;

/// @nodoc
Future<Map<String, dynamic>> contextNetwork() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();

    return {
      'cellular': connectivityResult == ConnectivityResult.mobile,
      'wifi': connectivityResult == ConnectivityResult.wifi
    };
  } catch (e, s) {
    util.debugError(e, s);

    return <String, dynamic>{};
  }
}
