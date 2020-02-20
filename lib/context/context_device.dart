/// @nodoc
library context_device;

import 'dart:io' show Platform;
import 'package:device_info/device_info.dart' show DeviceInfoPlugin;
import '../debug/debug.dart' show Debug;

/// @nodoc
Future<Map<String, dynamic>> contextDevice() async {
  try {
    return Platform.isAndroid ? _androidDevice() : _iosDevice();
  } catch (e, s) {
    Debug().error(e, s);

    return <String, dynamic>{};
  }
}

Future<Map<String, dynamic>> _androidDevice() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;

  return <String, dynamic>{
    'id': androidInfo.androidId,
    'manufacturer': androidInfo.manufacturer ?? androidInfo.brand,
    'model': androidInfo.model ?? androidInfo.product,
    'name': 'n/a',
    'type': androidInfo.type
  };
}

Future<Map<String, dynamic>> _iosDevice() async {
  final iosInfo = await DeviceInfoPlugin().iosInfo;

  return <String, dynamic>{
    'id': iosInfo.identifierForVendor,
    'manufacturer': 'apple',
    'model': iosInfo.model,
    'name': iosInfo.name,
    'type': iosInfo.utsname.machine
  };
}
