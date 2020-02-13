/// @nodoc
library context_location;

import 'package:location/location.dart' show Location, LocationAccuracy;

import '../config/config.dart' show Config;
import '../lifecycle/lifecycle.dart' show AppLifecycle, AppLifecycleState;
import '../timers/timers.dart' show PeriodicTimer;

/// @nodoc
class ContextLocation {
  /// @nodoc
  factory ContextLocation() => _contextLocation;

  ContextLocation._internal() : _location = Location() {
    _timer = PeriodicTimer(Config().locationRefreshInterval, () => _refresh());

    AppLifecycle().subscribe(_onAppLifecycleState);

    _location
        .changeSettings(accuracy: LocationAccuracy.POWERSAVE)
        .then((_) => _timer.enable());
  }

  static final _contextLocation = ContextLocation._internal();

  final Location _location;

  double _latitude;
  double _longitude;
  String _time;

  PeriodicTimer _timer;

  /// @nodoc
  Future<bool> requestPermission() => _location.requestPermission();

  /// @nodoc
  Map<String, dynamic> toJson() => <String, dynamic>{
        'latitude': _latitude,
        'longitude': _longitude,
        ..._time == null ? {} : {'time': _time}
      };

  void _onAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        return _timer.disable();

      case AppLifecycleState.resumed:
        return _timer.enable();

      default:
        return;
    }
  }

  Future<void> _refresh() async {
    try {
      if (!(await _location.hasPermission())) {
        return;
      }

      final location = await _location.getLocation();

      if (location == null) {
        return;
      }

      _latitude = location.latitude;
      _longitude = location.longitude;

      if (location.time != null && location.time > 1577896536000) {
        _time = DateTime.fromMillisecondsSinceEpoch(location.time.toInt())
            .toUtc()
            .toIso8601String();
      }
    } catch (_) {
      return;
    }
  }
}
