/// @nodoc
library config;

import 'dart:convert' show json;
import 'package:http/http.dart' show get;
import '../debug/debug.dart' show Debug;
import '../settings/settings.dart' show AnalyticsSettings;

/// @nodoc
class Config {
  /// @nodoc
  factory Config() => _config;

  Config._internal() : _settings = AnalyticsSettings();

  static final Config _config = Config._internal();

  AnalyticsSettings _settings;
  Map<String, dynamic> _remoteSettings;

  /// SDK-wide maximum [Duration] to await for e.g. HTTPS requests.
  Duration get defaultTimeout => Duration(
      seconds: _getRemoteSetting<int>('defaultTimeoutSecs') ??
          _settings.defaultTimeoutSecs);

  /// Array of POST-ready [HTTPS] URIs that should have analytics event batches
  /// forwarded to them. Each one of them gets its own segregated persistent
  /// device buffer to hold events until they can be sent/received.
  List<String> get destinations {
    try {
      return _getRemoteSetting<List<dynamic>>('destinations').cast<String>();
    } catch (_) {
      return <String>[];
    }
  }

  /// Target # of events, a.k.a. `batchSize` for triggering an auto `flush`.
  int get flushAtLength =>
      _getRemoteSetting<int>('flushAtLength') ?? _settings.flushAtLength;

  /// Target max. [Duration] to store an event locally from trigger to flush.
  Duration get flushAtDuration => Duration(
      seconds: _getRemoteSetting<int>('flushAtSecs') ?? _settings.flushAtSecs);

  /// Interval between requests of device location.
  Duration get locationRefreshInterval => Duration(
      seconds: _getRemoteSetting<int>('locationRefreshIntervalSecs') ??
          _settings.locationRefreshIntervalSecs);

  /// Max. events that can be buffered locally per destination until data loss.
  int get maxQueueLength =>
      _getRemoteSetting<int>('maxQueueLength') ?? _settings.maxQueueLength;

  /// Maximum [Duration] before a `sessionId` expires.
  Duration get sessionTimeout => Duration(
      seconds: _getRemoteSetting<int>('sessionTimeoutSecs') ??
          _settings.sessionTimeoutSecs);

  /// Allows local fine-tuning of [Analytics] parameters.
  AnalyticsSettings get settings => _settings;
  set settings(AnalyticsSettings analyticsSettings) {
    if (analyticsSettings != null) {
      _settings = analyticsSettings;
    }
  }

  T _getRemoteSetting<T>(String key) {
    try {
      return _remoteSettings[key] as T;
    } catch (_) {
      return null;
    }
  }

  /// Downloads remote OTA settings from the specified [url].
  Future<void> download(String url) async {
    try {
      if (url == null || url.isEmpty) {
        return;
      }

      final remoteJsonString = (await get(url).timeout(defaultTimeout)).body;
      _remoteSettings = json.decode(remoteJsonString) as Map<String, dynamic>;
    } catch (e) {
      Debug().error(e);
    }
  }

  @override
  String toString() => '''settings:
  flush every: $flushAtLength events
  location refreshes every: ${locationRefreshInterval.inSeconds} seconds
  max capacity before data loss: $maxQueueLength events
  max local TTL: ${flushAtDuration.inSeconds} seconds
  max session TTL: ${sessionTimeout.inSeconds} seconds
  request timeout: ${defaultTimeout.inSeconds} seconds\n   ''';
}
