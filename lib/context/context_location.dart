/// @nodoc
library context_location;

import 'dart:async' show TimeoutException;
import 'package:location/location.dart'
    show Location, LocationAccuracy, PermissionStatus;
import '../config/config.dart' show Config;
import '../debug/debug.dart' show Debug, IgnoreException;
import '../event/event.dart' show EventBuffer;
import '../lifecycle/lifecycle.dart' show AppLifecycle, AppLifecycleState;
import '../timers/timers.dart' show PeriodicTimer;

/// @nodoc
class ContextLocation {
  /// @nodoc
  factory ContextLocation() => _contextLocation;

  ContextLocation._internal() : _buffer = EventBuffer() {
    _refreshInterval = Config().locationRefreshInterval;
    _timer = PeriodicTimer(_refreshInterval, _onTick)..enable();

    AppLifecycle().subscribe(_onAppLifecycleState);
  }

  static final _contextLocation = ContextLocation._internal();

  final EventBuffer _buffer;

  double _latitude;
  double _longitude;
  String _time;

  Location _location;
  Duration _refreshInterval;
  PeriodicTimer _timer;

  /// @nodoc
  Future<bool> requestPermission() => _buffer.defer(() async {
        try {
          await _verifySetup(skipPermissions: true);

          if (_location == null) {
            throw IgnoreException();
          }

          final result = await _location.requestPermission();

          return result == PermissionStatus.GRANTED;
        } catch (e, s) {
          Debug().error(e, s);

          return false;
        }
      });

  /// @nodoc
  Map<String, dynamic> toJson() => <String, dynamic>{
        'latitude': _latitude,
        'longitude': _longitude,
        'time': _time
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

  Future<void> _refreshLocation() async {
    try {
      await _verifySetup();

      final locationData =
          await _location.getLocation().timeout(_refreshInterval);

      if (locationData?.latitude == null || locationData?.longitude == null) {
        throw IgnoreException();
      }

      _latitude = locationData.latitude;
      _longitude = locationData.longitude;

      if (locationData.time != null) {
        _time = DateTime.fromMillisecondsSinceEpoch(locationData.time.toInt())
            .toUtc()
            .toIso8601String();
      }
    } on TimeoutException {
      return;
    } catch (e, s) {
      Debug().error(e, s);
    }
  }

  void _onTick() {
    final refreshInterval = Config().locationRefreshInterval;

    if (_refreshInterval.compareTo(refreshInterval) == 0) {
      _buffer.defer(_refreshLocation);
    } else {
      _refreshInterval = refreshInterval;
      _timer.disable();
      _timer = PeriodicTimer(_refreshInterval, _onTick)..enable();
    }
  }

  Future<void> _verifySetup({bool skipPermissions = false}) async {
    final location = _location ?? Location();

    if (!(await location.serviceEnabled())) {
      throw IgnoreException();
    }

    if (!skipPermissions) {
      if ((await location.hasPermission()) != PermissionStatus.GRANTED) {
        throw IgnoreException();
      }
    }

    if (_location != null) {
      return;
    }

    await location.changeSettings(accuracy: LocationAccuracy.POWERSAVE);
    _location = location;

    _timer.enable();
  }
}
