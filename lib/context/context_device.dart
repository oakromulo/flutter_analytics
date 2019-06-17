/// @nodoc
library context_device;

import 'dart:io' show Platform;

import 'package:device_info/device_info.dart' show DeviceInfoPlugin;

import '../util/util.dart' show debugError;

/// @nodoc
Future<Map<String, dynamic>> contextDevice() async {
  try {
    return Platform.isAndroid ? _androidDevice() : _iosDevice();
  } catch (e, s) {
    debugError(e, s);

    return {};
  }
}

Future<Map<String, dynamic>> _androidDevice() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;

  return {
    'id': androidInfo.androidId,
    'manufacturer': androidInfo.manufacturer ?? androidInfo.brand,
    'model': androidInfo.model ?? androidInfo.product,
    'name': 'n/a',
    'type': androidInfo.type
  };
}

Future<Map<String, dynamic>> _iosDevice() async {
  final iosInfo = await DeviceInfoPlugin().iosInfo;

  return {
    'id': iosInfo.identifierForVendor,
    'manufacturer': 'apple',
    'model': iosInfo.model,
    'name': iosInfo.name,
    'type': iosInfo.utsname.machine
  };
}
