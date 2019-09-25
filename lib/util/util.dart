/// @nodoc
library util;

import 'dart:async' show StreamController, StreamSubscription;
import 'dart:convert' show base64, base64Url, JsonUtf8Encoder;
import 'dart:io' show gzip;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show debugPrint;

/// @nodoc
String base64GzipList(List<Map<String, dynamic>> list) =>
    base64.encode(gzip.encode(JsonUtf8Encoder().convert(list)));

/// @nodoc
String dartEnv() =>
    bool.fromEnvironment('dart.vm.product') ? 'PRODUCTION' : 'DEVELOPMENT';

/// @nodoc
void debugError(dynamic e, [dynamic trace]) => _debug(() {
      debugPrint('AnalyticsError:\n$e${trace == null ? '' : '\n$trace'}');
    });

/// @nodoc
void debugLog(dynamic msg) => _debug(() {
      debugPrint('AnalyticsInfo: ${msg.toString()} @ ${_isoNow()}');
    });

void _debug(void Function() exec) {
  if (!bool.fromEnvironment('dart.vm.product')) {
    exec();
  }
}

String _isoNow() {
  return DateTime.now().toIso8601String();
}

/// @nodoc
String hexStringToBase64(String hexString) {
  final s = hexString.replaceAll('-', '');

  final bytes = Uint8List(s.length ~/ 2);

  int i = 0;
  while (i < s.length) {
    bytes[i ~/ 2] = int.parse('0x' + s.substring(i, i += 2));
  }

  return base64Url.encode(bytes);
}

/// @nodoc
class EventBuffer<T> {
  /// @nodoc
  EventBuffer(OnEvent<T> onEvent) : _ctlr = StreamController<T>() {
    _sub = _ctlr.stream.listen((T event) => _sub.pause(onEvent(event)));
  }

  final StreamController<T> _ctlr;
  StreamSubscription<T> _sub;

  /// @nodoc
  void push(T event) => _ctlr.add(event);
}

/// @nodoc
typedef OnEvent<T> = Future<void> Function(T);
