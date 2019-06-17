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

import 'dart:async' show Completer;
import 'dart:convert' show json;

import 'package:flutter_persistent_queue/flutter_persistent_queue.dart';
import 'package:flutter_persistent_queue/typedefs/typedefs.dart' show OnFlush;
import 'package:http/http.dart' show post;
import 'package:uuid/uuid.dart' show Uuid;

import './config/config.dart' show Config;
import './segment/segment.dart' show Group, Identify, Screen, Segment, Track;
import './store/store.dart' show Store;
import './util/util.dart' show base64GzipList, debugError, EventBuffer;

/// Static singleton class for single-ended app-wide datalogging.
class Analytics {
  /// No intantiation allowed.
  Analytics.private();

  static bool _ready = false;
  static bool _enabled = true;

  static Config _config;
  static List<PersistentQueue> _queues;

  static List<String> _destinations = [];
  static OnBatchFlush _onBatchFlush = (_) => null;
  static final EventBuffer<_BaseEvent> _buffer = EventBuffer(_onEvent);

  /// Data collection readiness: `true` after a successful [Analytics.setup].
  ///
  /// An `AnalyticsNotReady` exception gets thrown if [group], [identify],
  /// [screen] and [track] calls are made after an unsuccessful [setup].
  static bool get ready => _ready;

  /// SDK bypass: `false` bypasses logging and flushing entirely.
  ///
  /// It is only toggable via [Analytics.enable] and [Analytics.disable] and
  /// starts with `true` after [Analytics.setup].
  static bool get enabled => _enabled;

  /// Enables event logging and flushing
  static Future<void> enable() => _toggle(true);

  /// Completely disable all data logging and flushing.
  ///
  /// p.s. regulations might require that underage user activity is never logged
  static Future<void> disable() => _toggle(false);

  /// Instantiates analytics engine with basic information before logging.
  ///
  /// It is *not* required to `await` for [setup] to finish before doing
  /// anything else. The analytics engine has its own isolated producer X
  /// consumer action buffer so that every method call is executed sequentially
  /// one at a time (chronological order is STRICTLY) respected. For example:
  /// an unawaited [group] may be immediately after a [setup] call but if for
  /// whatever reason [setup] fails then a `AnalyticsNotReady` exception gets
  /// thrown just as if [group] preceded the initial [setup].
  static Future<void> setup([AnalyticsSetup settings]) =>
      _BaseEvent(_BaseEventType.SETUP, setup: settings).future(_buffer);

  /// Triggers a manual flush operation to clear all local buffers.
  ///
  /// An option [OnFlush] [debug] handler may be provided to send batched events
  /// to custom destinations for debugging purposes.
  ///
  /// p.s. for normal SDK usage flush] calls may hardly be needed - one use case
  /// could be to force the SDK to immediately dispatch special events that just
  /// got fired
  ///
  /// p.s.2 flushing might not start immediately as the flush operation (just as
  /// all other public methods) gets scheduled to occur sequentially after all
  /// previous logging calls go through on the action buffer.
  static Future<void> flush([OnFlush debug]) =>
      _BaseEvent(_BaseEventType.FLUSH, flush: debug).future(_buffer);

  /// Groups users into groups. A [groupId] (channelId) must be provided.
  ///
  /// Optional group [traits] may also be provided and they're particularly
  /// useful for event segmentation by industry verticals and the like. For
  /// example, a `createdAt` group trait helps us to _implictly_ distinguish
  /// between early-bird user events (more valuable) than the ones triggered
  /// by late-comers.
  static Future<void> group(String groupId, [Map<String, dynamic> traits]) =>
      _log(Group(groupId, traits));

  /// Identifies registered users. A nullable [userId] must be provided.
  ///
  /// Optional [traits] may also be provided and they're particularly useful
  /// for *ANONYMOUS* userbase segmentation. Personally identifiable user
  /// information *SHOULD NEVER EVER BE PROVIDED HERE UNDER ANY CIRCUNSTANCES*.
  /// Segmentable user metadata such as birth dates, registration dates and
  /// gender are still OK and acceptable/desirable. Anything else, including
  /// but not limited to avatar photos, emails and usernames should not go to
  /// transactional data.
  static Future<void> identify(String userId, [Map<String, dynamic> traits]) =>
      _log(Identify(userId, traits));

  /// Logs the current screen a user just jumped into on a mobile app.
  ///
  /// The [screen] [name] must be provided. Optional [properties] should also
  /// accompany it but they *MUST* be `Map<String, dynamic>` JSON-encodable,
  /// statically typed and consistent across at least the same minor mobile app
  /// release. For example, a `Login Screen` call must always have the same
  /// payload (even with lots of blank/null fields) on the same mobile app
  /// version.
  static Future<void> screen(String name, [Map<String, dynamic> properties]) =>
      _log(Screen(name, properties));

  /// Logs *any* meaningful mobile app [event] and its respective [properties].
  ///
  /// [properties] *MUST* be `Map<String, dynamic>` JSON-encodable, statically
  /// typed and consistent across at least the same minor mobile app
  /// release. For example, an `Application Backgrounded` call must always have
  /// the same payload, e.g. `{'url': 'app://deeplink.com/uri'} - new fields
  /// implicate on at least a *minor* mobile app version bump.
  static Future<void> track(String event, [Map<String, dynamic> properties]) =>
      _log(Track(event, properties));

  static Future<void> _log(Segment child) =>
      _BaseEvent(_BaseEventType.LOG, child: child).future(_buffer);

  static Future<void> _toggle(bool enabled) =>
      _BaseEvent(_BaseEventType.TOGGLE, enabled: enabled).future(_buffer);

  static Future<void> _onEvent(_BaseEvent event) {
    switch (event.type) {
      case _BaseEventType.FLUSH:
        return _onFlush(event);

      case _BaseEventType.LOG:
        return _onLog(event);

      case _BaseEventType.SETUP:
        return _onSetup(event);

      case _BaseEventType.TOGGLE:
        return _onToggle(event);

      default:
        return Future.value(null);
    }
  }

  static Future<void> _onFlush(_BaseEvent event) async {
    try {
      if (!_ready) {
        return event.completer.completeError('AnalyticsNotReady');
      }

      if (!_enabled) {
        return;
      }

      dynamic firstError;

      for (final pq in _queues) {
        try {
          await pq.flush(event.flush);
        } catch (e) {
          firstError ??= e;
        }
      }

      if (firstError != null) {
        throw firstError;
      }

      event.completer.complete();
    } catch (e) {
      debugError(e);
      event.completer.completeError(e);
    }
  }

  static Future<void> _onLog(_BaseEvent event) async {
    try {
      if (!_ready) {
        return event.completer.completeError('AnalyticsNotReady');
      }

      if (!_enabled) {
        return;
      }

      final payload = await event.child.toMap();

      for (final pq in _queues) {
        try {
          await pq.push(payload);
        } catch (e, s) {
          debugError(e, s);
        }
      }

      event.completer.complete();
    } catch (e, s) {
      event.completer.completeError(e, s);
    }
  }

  static Future<void> _onSetup(_BaseEvent event) async {
    try {
      _config = Config();

      if (event.setup != null) {
        if (event.setup.configUrl != null) {
          await _config.download(event.setup.configUrl);
        }

        final List<String> dupDestinations = [
          ..._config.destinations ?? [],
          ...event.setup.destinations ?? []
        ];

        if (dupDestinations.isEmpty) {
          throw Exception('Analytics setup failure: no destinations');
        }

        _destinations = Set<String>.of(dupDestinations).toList();
      }

      _onBatchFlush = event.setup.onFlush;

      final store = Store();

      store.orgId = Future.value(event.setup.orgId);
      await store.orgId;

      store.setupId = Future.value(Uuid().v4());
      await store.setupId;

      _queues = await _initQueues();

      _ready = true;
      event.completer.complete();
    } catch (e, s) {
      _ready = false;
      event.completer.completeError(e, s);
    }
  }

  static Future<void> _onToggle(_BaseEvent event) async {
    _enabled = event.enabled;
    event.completer.complete();
  }

  static Future<bool> _onQueueFlush(
      String url, List<Map<String, dynamic>> batch) async {
    try {
      _fillSentAt(batch);
      await _post(url, batch);

      _onBatchFlush(batch);

      return true;
    } catch (e, s) {
      debugError(e, s);

      return false;
    }
  }

  static void _fillSentAt(List<Map<String, dynamic>> batch) {
    final sentAt = DateTime.now().toUtc().toIso8601String();

    for (var event in batch) {
      event['sentAt'] = sentAt;
    }
  }

  static Future<void> _post(String url, List<Map<String, dynamic>> data) async {
    if (data.isEmpty) {
      return;
    }

    const headers = {'Content-Type': 'application/json'};
    final timeout = _config.defaultTimeout;

    final body = json.encode({'batch': base64GzipList(data)});

    final res = await post(url, headers: headers, body: body).timeout(timeout);

    if (!res.body.contains('success')) {
      throw Exception('AnalyticsPostRequestFailed');
    }
  }

  static Future<List<PersistentQueue>> _initQueues() async {
    final queues = <PersistentQueue>[];

    for (final url in _destinations) {
      final pq = PersistentQueue('__analytics_${queues.length}__',
          onFlush: (batch) => _onQueueFlush(url, batch),
          flushAt: _config.flushAtLength,
          flushTimeout: _config.flushAtDuration,
          maxLength: _config.maxQueueLength);

      await pq.ready;

      queues.add(pq);
    }

    return queues;
  }
}

class _BaseEvent {
  _BaseEvent(this.type, {this.child, this.enabled, this.flush, this.setup});

  final _BaseEventType type;

  final Segment child;
  final bool enabled;
  final OnFlush flush;
  final AnalyticsSetup setup;

  final Completer<void> completer = Completer();

  Future<void> future(EventBuffer<_BaseEvent> buffer) {
    buffer.push(this);

    return completer.future;
  }
}

/// [Analytics.setup] input params helper class for static typing.
class AnalyticsSetup {
  /// [Analytics.setup] input params.
  AnalyticsSetup({this.configUrl, this.destinations, this.onFlush, this.orgId});

  /// Optional remote url to load OTA settings for analytics.
  final String configUrl;

  /// Optional list of HTTP POST endpoints capable of ACKing analytics requests.
  final List<String> destinations;

  /// Optional callback to be called after every event batch being flushed.
  final OnBatchFlush onFlush;

  /// Unique identifier of current organization receiving analytics events.
  final String orgId;
}

enum _BaseEventType { FLUSH, LOG, SETUP, TOGGLE }

/// Type signature alias for the optional `onFlush` event handler.
typedef OnBatchFlush = void Function(List<Map<String, dynamic>>);
