/// @nodoc
library config;

import 'dart:convert' show json;

import 'package:http/http.dart' show get;

import './config_defaults.dart' show defaults;

/// @nodoc
class Config {
  static Map<String, dynamic> _remoteConfig;

  /// SDK-wide default maximum duration to await for HTTPS requests
  ///
  /// used e.g. to determine how long until all flush operations times out
  Duration get defaultTimeout => Duration(seconds: _get('defaultTimeoutSecs'));

  /// Array of POST-ready [HTTPS] URIs that should have analytics event batches
  /// forwarded to them. Each one of them gets its own segregated persistent
  /// device buffer to hold events until they can be sent/received.
  List<String> get destinations {
    try {
      return _get('destinations').cast<String>();
    } catch (_) {
      return null;
    }
  }

  /// Target # of events, a.k.a. `batchSize`, on each [Analytics.flush].
  ///
  /// When this amount is reached an automatic (implicit) flush operation gets
  /// to dispatch all locally-buffered events to the desired [destinations].
  ///
  /// p.s. this number is not hardly enforced - the actual number of events
  /// flushed manually triggered flushes, previously failed flush attempts
  /// and [flushAtDuration] attempts all affect the actual [flushAtLength]
  int get flushAtLength => _get('flushAtLength') + 0;

  /// Target max. [Duration] to store an event locally from trigger to flush.
  Duration get flushAtDuration => Duration(seconds: _get('flushAtSecs'));

  /// Hard max. # of events to be stored locally for a given _destination_.
  ///
  /// p.s. data loss occurs when [maxQueueLength] is reached
  int get maxQueueLength => _get('maxQueueLength') + 0;

  /// Maximum session [Duration].
  Duration get sessionTimeout => Duration(seconds: _get('sessionTimeoutSecs'));

  dynamic _get(String key) {
    try {
      return _remoteConfig[key];
    } catch (_) {
      try {
        return defaults[key];
      } catch (_) {
        return null;
      }
    }
  }

  /// Downloads remote OTA settings from the specified URL.
  Future<void> download(String url) async {
    try {
      final timeout = Duration(seconds: defaults['defaultTimeoutSecs']);

      _remoteConfig = json.decode((await get(url).timeout(timeout)).body);
    } catch (_) {
      return;
    }
  }
}
