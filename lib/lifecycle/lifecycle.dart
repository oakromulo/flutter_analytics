/// @nodoc
library lifecycle;

import 'dart:ui' show AppLifecycleState;
export 'dart:ui' show AppLifecycleState;

/// @nodoc
class AppLifecycle {
  /// @nodoc
  factory AppLifecycle() => _appLifecycle;

  AppLifecycle._internal()
      : _callbacks = [],
        _state = AppLifecycleState.resumed;

  /// @nodoc
  AppLifecycleState get state => _state;
  set state(AppLifecycleState state) {
    _state = state;

    for (final cb in _callbacks) {
      cb(state);
    }
  }

  static final _appLifecycle = AppLifecycle._internal();

  final List<void Function(AppLifecycleState state)> _callbacks;
  AppLifecycleState _state;

  /// @nodoc
  void addCallback(void Function(AppLifecycleState state) onLifecycleState) =>
      _callbacks.add(onLifecycleState);
}
