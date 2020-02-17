/// @nodoc
library debug;

import 'package:flutter/foundation.dart' show debugPrint;

/// @nodoc
class Debug {
  /// @nodoc
  factory Debug() => _debug;

  Debug._internal() : enabled = true;

  /// @nodoc
  bool enabled;

  static final Debug _debug = Debug._internal();

  String get _isoNow => DateTime.now().toUtc().toIso8601String();

  /// @nodoc
  void error(dynamic e, [dynamic s]) {
    if (e == null || e.runtimeType == IgnoreException) {
      return;
    }

    _print('flutter_analytics ➲ ERROR:\n$e${s == null ? '' : '\n$s'}\n');
  }

  /// @nodoc
  void log(dynamic msg) =>
      _print('flutter_analytics ➲ ${msg.toString()} @ $_isoNow\n');

  void _print(String msg) {
    if (!bool.fromEnvironment('dart.vm.product') && enabled) {
      debugPrint(msg);
    }
  }
}

/// @nodoc
class IgnoreException implements Exception {}
