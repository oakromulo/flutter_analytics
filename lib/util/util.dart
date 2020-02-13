/// @nodoc
library util;

import 'dart:async' show StreamController, StreamSubscription, Timer;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:recase/recase.dart' show ReCase;

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
String camelCase(String s) => _toCase(s, (s) => ReCase(s).camelCase);

/// @nodoc
String titleCase(String s) => _toCase(s, (s) => ReCase(s).titleCase);

String _toCase(String string, String Function(String) recaseFunction) {
  try {
    if (string == null || string.isEmpty) {
      return null;
    }

    return recaseFunction(string);
  } catch (_) {
    return null;
  }
}

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
class PeriodicTimer {
  /// @nodoc
  PeriodicTimer(this._interval, this._onTick, [this._immediate = true]);

  final Duration _interval;
  final Function _onTick;
  final bool _immediate;

  Timer _timer;

  /// @nodoc
  void disable() {
    if (_timer == null) {
      return;
    }

    _timer.cancel();
    _timer = null;
  }

  /// @nodoc
  void enable() {
    if (_timer != null) {
      return;
    }

    _timer = Timer.periodic(_interval, (_) => _onTick());

    if (_immediate) {
      _onTick();
    }
  }
}

/// @nodoc
typedef OnEvent<T> = Future<void> Function(T);
