/// @nodoc
library debug;

import 'package:flutter/foundation.dart' show debugPrint;

/// @nodoc
class Debug {
  /// @nodoc
  factory Debug() => _debug;

  Debug._internal() : _enabled = true;

  bool _enabled;

  static final Debug _debug = Debug._internal();

  String get _isoNow => DateTime.now().toUtc().toIso8601String();

  /// @nodoc
  void disable() => _enabled = false;

  /// @nodoc
  void enable() => _enabled = true;

  /// @nodoc
  void error(dynamic e, [dynamic s]) =>
      _print('flutter_analytics ➲ ERROR:\n$e${s == null ? '' : '\n$s'}\n');

  /// @nodoc
  void log(dynamic msg) =>
      _print('flutter_analytics ➲ ${msg.toString()} @ $_isoNow\n');

  void _print(String msg) {
    if (!bool.fromEnvironment('dart.vm.product') && _enabled) {
      debugPrint(msg);
    }
  }
}
