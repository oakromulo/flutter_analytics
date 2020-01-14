/// @nodoc
library util;

import 'dart:async' show StreamController, StreamSubscription;

import 'package:flutter/foundation.dart' show debugPrint;

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

void _debug(void Function() exec) {
  if (!bool.fromEnvironment('dart.vm.product')) {
    exec();
  }
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
