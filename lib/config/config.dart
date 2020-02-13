/// @nodoc
library config;

import 'dart:convert' show json;

import 'package:http/http.dart' show get;

import './config_defaults.dart' show defaults;

/// @nodoc
class Config {
  /// @nodoc
  factory Config() => _config;

  Config._internal();

  static final Config _config = Config._internal();

  Map<String, dynamic> _remoteConfig;

  /// SDK-wide default maximum duration to await for HTTPS requests
  Duration get defaultTimeout =>
      Duration(seconds: _get('defaultTimeoutSecs') ?? 60);

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

  /// Target # of events, a.k.a. `batchSize`, on each [flush]
  ///
  /// When this amount is reached an automatic (implicit) flush operation gets
  /// to dispatch all locally-buffered events to the desired [destinations]
  ///
  /// p.s. this number is not hardly enforced - the actual number of events
  /// flushed manually triggered flushes, previously failed flush attempts
  /// and [flushAtDuration] attempts all affect the actual [flushAtLength]
  int get flushAtLength => _get('flushAtLength') ?? 100;

  /// Target max. [Duration] to store an event locally from trigger to flush.
  Duration get flushAtDuration => Duration(seconds: _get('flushAtSecs') ?? 300);

  /// Interval between requests of device location.
  Duration get locationRefreshInterval =>
      Duration(seconds: _get('locationRefreshIntervalSecs') ?? 30);

  /// Hard max. # of events to be stored locally for a given _destination_
  ///
  /// p.s. data loss occurs when [maxQueueLength] is reached
  int get maxQueueLength => _get('maxQueueLength') ?? 10000;

  /// Maximum session [Duration]
  Duration get sessionTimeout =>
      Duration(seconds: _get('sessionTimeoutSecs') ?? 1800);

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
    final timeout = Duration(seconds: defaults['defaultTimeoutSecs']);

    _remoteConfig = json.decode((await get(url).timeout(timeout)).body);
  }

  @override
  String toString() => '''config:
  destinations: ${(destinations ?? []).length}
  flush every: $flushAtLength events
  location refreshe4s every: ${locationRefreshInterval.inSeconds} seconds
  max capacity before data loss: $maxQueueLength events
  max local TTL: ${flushAtDuration.inSeconds} seconds
  max session TTL: ${sessionTimeout.inSeconds} seconds
  request timeout: ${defaultTimeout.inSeconds} seconds\n   ''';
}
