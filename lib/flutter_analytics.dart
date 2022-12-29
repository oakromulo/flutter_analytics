/// A barebones Analytics SDK to collect anonymous metadata from flutter apps.
///
/// Basically the SDK provides static event calls for four macro events to be
/// collected: Groups & Identifies (along with group/user traits) as well as
/// Screens & Trackings (along with custom properties).
///
/// Data is buffered locally for each target destination to receive the
/// analytics. The list of destinations to be served via batched HTTPS POST
/// requests is defined OTA, as well as a few other settings.
library flutter_analytics;

import 'dart:async' show FutureOr;

import './context/context_location.dart' show ContextLocation;
import './debug/debug.dart' show Debug;
import './event/event.dart' show EventBuffer;
import './lifecycle/lifecycle.dart' show AppLifecycle, AppLifecycleState;
import './segment/segment.dart' show Group, Identify, Screen, Segment, Track;
import './settings/settings.dart' show AnalyticsSettings;
import './setup/setup.dart' show Setup, SetupParams, OnBatchFlush;

export './parser/parser.dart' show AnalyticsParser;
export './settings/settings.dart' show AnalyticsSettings;

/// Static singleton class for single-ended app-wide datalogging.
class Analytics {
  /// Returns a global singleton instance of [Analytics].
  factory Analytics() => _analytics;

  Analytics._internal()
      : enabled = true,
        _actionBuffer = EventBuffer(),
        _logBuffer = EventBuffer() {
    AppLifecycle().subscribe(_onAppLifecycleState);
  }

  /// Disables data collection entirely when `false`. Default is `true`.
  bool enabled;

  static final _analytics = Analytics._internal();

  final EventBuffer _actionBuffer;
  final EventBuffer _logBuffer;

  Setup? _setup;

  /// Prints informative [Analytics] messages if not `false`. Default is `true`.
  bool get debug => Debug().enabled;
  set debug(bool enableDebugging) => Debug().enabled = enableDebugging;

  /// Indicates data collection readiness after a successful [setup].
  ///
  /// An `AnalyticsNotReady` exception gets thrown if [group], [identify],
  /// [screen] and [track] calls are made before a successful [setup].
  bool get ready => _setup != null;

  /// Triggers a manual flush operation to clear all local buffers.
  ///
  /// An optional [onFlush] handler may be provided to send batched
  /// events to custom destinations for debugging purposes. The elements are
  /// dequeued once [onFlush] completes as long as it does not return `false`.
  ///
  /// p.s. for normal SDK usage flush] calls may hardly be needed - one use case
  /// could be to force the SDK to immediately dispatch special events that just
  /// got fired
  ///
  /// p.s.2 flushing might not start immediately as the flush operation (just as
  /// all other public methods) gets scheduled to occur sequentially after all
  /// previous logging calls go through on the action buffer.
  Future<void> flush([
    FutureOr Function(List)? onFlush,
  ]) =>
      _actionBuffer
          .defer(
            () => _flush(onFlush),
          )
          .catchError(
            Debug().error,
          );

  /// Groups users into groups. A [groupId] (channelId) must be provided.
  Future<void> group(
    String groupId, [
    dynamic traits,
  ]) =>
      _log((_) => Group(groupId, traits));

  /// Identifies registered users. A nullable [userId] must be provided.
  Future<void> identify(
    String userId, [
    dynamic traits,
  ]) =>
      _log((_) => Identify(userId, traits));

  /// Requests authorization to fetch device location.
  Future<bool?> requestPermission() => ContextLocation().requestPermission();

  /// Logs the current screen [name].
  Future<void> screen(
    String name, [
    dynamic properties,
  ]) =>
      _log((_) => Screen(name, properties));

  /// Instantiates analytics engine with basic information before logging.
  ///
  /// It is *not* required to `await` for [setup] to finish before doing
  /// anything else. The analytics engine has its own isolated producer X
  /// consumer action buffer so that every method call is executed sequentially
  /// one at a time (chronological order is STRICTLY) respected. For example:
  /// an unawaited [group] may be immediately after a [setup] call but if for
  /// whatever reason [setup] fails then a `AnalyticsNotReady` exception gets
  /// thrown just as if [group] preceded the initial [setup].
  ///
  /// Params:
  /// - [bucket]: optional post-processing server-side bucket to store analytics
  /// - [configUrl]: remote url to load OTA settings for analytics
  /// - [debug]: disable all [Analytics] debug messages when `false`
  /// - [destinations]: list of POST endpoints able to receive analytics
  /// - [onFlush]: callback to be called after every event batch being flushed
  /// - [orgId]: unique identifier for the top-level org in analytics events
  /// - [settings]: additional/optional [AnalyticsSettings] for fine-tune params
  Future<void> setup({
    String? bucket,
    String? configUrl,
    List<String>? destinations,
    OnBatchFlush? onFlush,
    String? orgId,
    AnalyticsSettings? settings,
  }) {
    final setupParams = SetupParams(
      bucket,
      configUrl,
      destinations,
      onFlush,
      orgId,
      settings,
    );

    return _actionBuffer
        .defer(
          () => _init(setupParams),
        )
        .catchError(
          Debug().error,
        );
  }

  /// Logs an [event] and its respective [properties].
  Future<void> track(
    String event, [
    dynamic properties,
  ]) =>
      _log((_) => Track(event, properties));

  /// Informs [Analytics] of caller [AppLifecycleState] changes.
  ///
  /// p.s. this is required for correct [Analytics] behavior on background.
  void updateAppLifecycleState(AppLifecycleState state) {
    AppLifecycle().state = state;
  }

  Future<void> _flush(FutureOr Function(List)? onFlush) async {
    if (!enabled || _setup == null) {
      return;
    }
    final queues = await _setup!.queues;
    if (queues != null) {
      for (final queue in queues) {
        await queue.flush(onFlush).catchError(Debug().error);
      }
    }
  }

  Future<void> _init(SetupParams setupParams) async {
    final setup = Setup(setupParams);
    await setup.ready;

    _setup = setup;
    Debug().log('successful setup');
  }

  Future<void> _log(Segment Function(void) log) => _logBuffer
      .defer(() => Future<void>.delayed(Duration(milliseconds: 1)).then(log))
      .then((segment) => _actionBuffer.defer(() => _push(segment)))
      .catchError(Debug().error);

  void _onAppLifecycleState(AppLifecycleState state) {
    if (_setup == null) {
      return;
    } else if (state == AppLifecycleState.paused) {
      flush();
    } else if (state == AppLifecycleState.resumed) {
      setup(
          bucket: _setup!.params.bucket,
          configUrl: _setup!.params.configUrl,
          destinations: _setup!.params.destinations,
          onFlush: _setup!.params.onFlush,
          orgId: _setup!.params.orgId,
          settings: _setup!.params.settings);
    }
  }

  Future<void> _push(Segment? segment) async {
    if (_setup == null) {
      throw Exception('AnalyticsNotReady');
    }

    if (!enabled) {
      return;
    }

    final payload = await segment?.toMap();
    final queues = await _setup!.queues;
    if (queues != null) {
      for (final queue in queues) {
        await queue.push(payload).catchError(Debug().error);
      }
    }
  }
}
