/// @nodoc
library settings;

/// Allows fine customization of [Analytics] constants at `Setup` time.
class AnalyticsSettings {
  /// Pass additional parameters to [Analytics].
  AnalyticsSettings(
      {this.defaultTimeoutSecs = 60,
      this.flushAtLength = 100,
      this.flushAtSecs = 300,
      this.locationRefreshIntervalSecs = 15,
      this.maxQueueLength = 10000,
      this.sessionTimeoutSecs = 1800});

  /// SDK-wide default timeout in seconds to await for e.g. HTTPS requests.
  final int defaultTimeoutSecs;

  /// Target # of events, a.k.a. `batchSize` for triggering an auto `flush`.
  final int flushAtLength;

  /// Target max. seconds to store an event locally from trigger to flush.
  final int flushAtSecs;

  /// Period in seconds between requests of device location.
  final int locationRefreshIntervalSecs;

  /// Max. events that can be buffered locally per destination until data loss.
  final int maxQueueLength;

  /// Max. seconds until a `sessionId` expires.
  final int sessionTimeoutSecs;
}
