/// @nodoc
library util;

import 'dart:async' show StreamController, StreamSubscription;
import 'dart:convert' show base64, base64Url, JsonUtf8Encoder, json;
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
void debugError(dynamic e, [dynamic s]) => _debug(() {
      debugPrint('flutter_analytics ➲ ERROR:\n$e${s == null ? '' : '\n$s'}\n');
    });

/// @nodoc
void debugLog(dynamic msg) => _debug(() {
      debugPrint('flutter_analytics ➲ ${msg.toString()} @ ${_isoNow()}\n');
    });

/// @nodoc
List<dynamic> dedupLists(List<dynamic> a, List<dynamic> b) =>
    <String>{...a ?? [], ...b ?? []}.toList();

/// @nodoc
void fixEncoding(Map<String, dynamic> payload) {
  _fixDateTimeEncoding(payload ?? {});
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
Map<String, dynamic> toJson(dynamic input) {
  try {
    return json.decode(json.encode(input ?? {})) ?? {};
  } catch (e) {
    debugLog('a payload could not be json encoded:\n$input');

    return {};
  }
}

void _debug(void Function() exec) {
  if (!bool.fromEnvironment('dart.vm.product')) {
    exec();
  }
}

// FIXME: a very naïve and inneficient forceful encoding hack here \/
void _fixDateTimeEncoding(Map<String, dynamic> payload) {
  payload.forEach((key, value) {
    try {
      try {
        if (value.keys.length > -1) {
          return _fixDateTimeEncoding(value);
        }
      } catch (_) {}
      try {
        if (value.toUtc() != null) {
          try {
            payload[key] = value.toUtc().toIso8601String();
          } catch (_) {
            payload[key] = null;
          }
        }
      } catch (_) {}
    } catch (_) {}
  });
}

String _isoNow() {
  return DateTime.now().toUtc().toIso8601String();
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
