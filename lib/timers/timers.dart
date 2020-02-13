/// @nodoc
library timers;

import 'dart:async' show Timer;

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
