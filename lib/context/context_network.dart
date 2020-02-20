/// @nodoc
library context_network;

import 'package:connectivity/connectivity.dart'
    show Connectivity, ConnectivityResult;
import 'package:sim_info/sim_info.dart' show SimInfo;

/// @nodoc
class ContextNetwork {
  /// @nodoc
  ContextNetwork();

  static final Future<String> _carrier =
      SimInfo.getCarrierName.catchError((dynamic _) => null);

  final _connectivityResult = Connectivity()
      .checkConnectivity()
      .catchError((dynamic _) => ConnectivityResult.none);

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async {
    try {
      final connectivityResult = await _connectivityResult;

      return <String, dynamic>{
        'carrier': await _carrier,
        'cellular': connectivityResult == ConnectivityResult.mobile,
        'wifi': connectivityResult == ConnectivityResult.wifi
      };
    } catch (_) {
      return <String, dynamic>{'carrier': null, 'cellular': null, 'wifi': null};
    }
  }
}
