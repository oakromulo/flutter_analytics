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

import 'package:flutter_persistent_queue/typedefs/typedefs.dart' show OnFlush;

import './event/event.dart' show Event, EventType;
import './parser/parser.dart' show Parser;
import './segment/segment.dart' show Group, Identify, Screen, Segment, Track;
import './setup/setup.dart' show Setup, SetupParams, OnBatchFlush;
import './util/util.dart' show debugError, debugLog, EventBuffer;

/// Static singleton class for single-ended app-wide datalogging.
class Analytics {
  /// @nodoc
  Analytics.private();

  static final _buffer = EventBuffer(_onEvent);

  static bool _ready = false;
  static Setup _setup;

  /// Data collection readiness: `true` after a successful [Analytics.setup].
  ///
  /// An `AnalyticsNotReady` exception gets thrown if [group], [identify],
  /// [screen] and [track] calls are made after an unsuccessful [setup].
  static bool get ready => _ready;

  /// SDK bypass: `false` bypasses data collections entirely.
  static bool enabled = true;

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
  /// - [configUrl]: remote url to load OTA settings for analytics.
  /// - [destinations]: list of POST endpoints able to receive analytics
  /// - [onFlush]: callback to be called after every event batch being flushed
  /// - [orgId]: unique identifier for the top-level org in analytics events.
  static Future<void> setup(
      {String configUrl,
      List<String> destinations,
      OnBatchFlush onFlush,
      String orgId}) {
    final setup = SetupParams(configUrl, destinations, onFlush, orgId);

    return Event(EventType.SETUP, setup: setup).future(_buffer);
  }

  /// Triggers a manual flush operation to clear all local buffers.
  ///
  /// An optional  [OnFlush] [debug] handler may be provided to send batched
  /// events to custom destinations for debugging purposes. It must return
  /// `true` to properly dequeue the elements.
  ///
  /// p.s. for normal SDK usage flush] calls may hardly be needed - one use case
  /// could be to force the SDK to immediately dispatch special events that just
  /// got fired
  ///
  /// p.s.2 flushing might not start immediately as the flush operation (just as
  /// all other public methods) gets scheduled to occur sequentially after all
  /// previous logging calls go through on the action buffer.
  static Future<void> flush([OnFlush debug]) =>
      Event(EventType.FLUSH, flush: debug).future(_buffer);

  /// Groups users into groups. A [groupId] (channelId) must be provided.
  static Future<void> group(String groupId, [dynamic traits]) =>
      _log(Group(groupId, traits));

  /// Identifies registered users. A nullable [userId] must be provided.
  static Future<void> identify(String userId, [dynamic traits]) =>
      _log(Identify(userId, traits));

  /// Logs the current screen [name].
  static Future<void> screen(String name, [dynamic properties]) =>
      _log(Screen(name, properties));

  /// Logs an [event] and its respective [properties].
  static Future<void> track(String event, [dynamic properties]) =>
      _log(Track(event, properties));

  static Future<void> _onEvent(Event event) {
    switch (event.type) {
      case EventType.FLUSH:
        return _onFlushEvent(event);

      case EventType.LOG:
        return _onLogEvent(event);

      case EventType.SETUP:
        return _onSetupEvent(event);

      default:
        return Future.value(null);
    }
  }

  static Future<void> _onFlushEvent(Event event) async {
    if (!_ready) {
      return event.completer.completeError('AnalyticsNotReady');
    }

    if (!enabled) {
      return;
    }

    int i = _setup.queues.length;

    while (--i >= 0) {
      final destination = _setup.destinations[i];

      try {
        await _setup.queues[i].flush(event.flush);

        debugLog('successful manual flush attempt to:\n$destination');
      } catch (e, s) {
        debugLog('failed manual flush attempt to:\n$destination');
        debugError(e, s);
      }
    }

    event.completer.complete();
  }

  static Future<void> _onLogEvent(Event event) async {
    if (!_ready) {
      return event.completer.completeError('AnalyticsNotReady');
    }

    if (!enabled) {
      return;
    }

    int i = _setup.queues.length;

    while (--i >= 0) {
      final destination = _setup.destinations[i];

      try {
        await _setup.queues[i].push(Parser(await event.child.toMap()));
      } catch (e, s) {
        debugLog('a payload could not be buffered to: $destination');
        debugError(e, s);
      }
    }

    event.completer.complete();
  }

  static Future<void> _onSetupEvent(Event event) async {
    try {
      debugLog(_ready ? 'a previous setup will be overwritten' : 'first setup');

      _setup = Setup(event.setup);
      await _setup.ready;

      debugLog('successful setup');

      _ready = true;
      event.completer.complete();
    } catch (e, s) {
      debugLog('failed setup attempt');
      debugError(e, s);

      _ready = false;
      event.completer.completeError(e, s);
    }
  }

  static Future<void> _log(Segment child) =>
      Event(EventType.LOG, child: child).future(_buffer);
}
