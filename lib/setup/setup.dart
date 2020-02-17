library analytics_setup;

import 'dart:convert' show AsciiCodec;

import 'package:flutter_persistent_queue/flutter_persistent_queue.dart'
    show PersistentQueue;
import 'package:flutter_persistent_queue/typedefs/typedefs.dart' show OnFlush;
import 'package:http/http.dart' show post, Response;

import '../config/config.dart' show Config;
import '../debug/debug.dart' show Debug;
import '../encoder/encoder.dart' show Encoder;
import '../settings/settings.dart' show AnalyticsSettings;
import '../store/store.dart' show Store;

/// @nodoc
class Setup {
  /// @nodoc
  Setup(this.params) {
    ready = _setup(params);
  }

  /// @nodoc
  final SetupParams params;

  /// @nodoc
  Future<void> ready;

  List<String> _destinations;
  List<PersistentQueue> _queues;

  /// @nodoc
  List<String> get destinations => _destinations;

  /// @nodoc
  List<PersistentQueue> get queues => _queues;

  Future<void> _setup(SetupParams params) async {
    params.debug ? Debug().enable() : Debug().disable();

    Config().settings = params.settings;
    await _downloadConfig(params.configUrl);
    Debug().log(Config());

    _destinations = _dedup(Config().destinations, params.destinations);
    _validateDestinations(_destinations);
    Debug().log('destinations: $_destinations');

    final orgId = await _resetOrgId(params.orgId);
    Debug().log('orgId: $orgId');

    _queues = await _initQueues(_destinations, params.onFlush);
  }

  static List<String> _dedup(List<String> a, List<String> b) =>
      <String>{...a ?? [], ...b ?? []}.toList();

  static Future<void> _downloadConfig(String url) async {
    try {
      if (url == null || url.isEmpty) {
        return;
      }

      await Config().download(url);

      Debug().log('remote config fetched successfully');
    } catch (e, s) {
      Debug().log('remote config could not be downloaded this time');
      Debug().error(e, s);
    }
  }

  static Future<PersistentQueue> _initQueue(
      String url, OnBatchFlush onBatchFlush) async {
    final pq = PersistentQueue(url.hashCode.toString(),
        onFlush: _onFlush(url, onBatchFlush),
        flushAt: Config().flushAtLength,
        flushTimeout: Config().flushAtDuration,
        maxLength: Config().maxQueueLength);

    await pq.ready;

    Debug().log('local buffer created succesfully for destination:\n$url');

    return pq;
  }

  static Future<List<PersistentQueue>> _initQueues(
      List<String> destinations, OnBatchFlush onBatchFlush) async {
    final queues = <PersistentQueue>[];

    for (final url in destinations) {
      queues.add(await _initQueue(url, onBatchFlush));
    }

    return queues;
  }

  static OnFlush _onFlush(String url, OnBatchFlush onBatchFlush) =>
      (List<dynamic> input) async {
        try {
          final encoder = Encoder(input);

          if (encoder.batch.isNotEmpty) {
            _validatePost(await _post(url, encoder.toString()));
          }

          try {
            (onBatchFlush ?? (_) => null)(encoder.batch);
          } catch (_) {
            // completely ignore callback errors on this scope
          }

          Debug().log('an analytics batch got succesfully flushed to:\n$url');

          return true;
        } catch (e, s) {
          Debug().log('an analytics batch could not be flushed to:\n$url');
          Debug().error(e, s);

          return false;
        }
      };

  static Future<Response> _post(String url, String body,
          [Duration timeout = const Duration(seconds: 60)]) =>
      post(url, body: body, encoding: AsciiCodec()).timeout(timeout);

  static Future<String> _resetOrgId(String orgId) {
    Store().orgId = Future.value(orgId);
    return Store().orgId;
  }

  static void _validateDestinations(List<String> destinations) {
    if (destinations.isEmpty) {
      throw Exception('no destinations have been provided');
    }
  }

  static void _validatePost(Response res) {
    if (!res.body.contains('success')) {
      throw Exception('InvalidServerResponse');
    }
  }
}

/// @nodoc
class SetupParams {
  /// @nodoc
  SetupParams(
      [this.configUrl,
      this.debug,
      this.destinations,
      this.onFlush,
      this.orgId,
      this.settings]);

  /// @nodoc
  final String configUrl;

  /// @nodoc
  final bool debug;

  /// @nodoc
  final List<String> destinations;

  /// @nodoc
  final OnBatchFlush onFlush;

  /// @nodoc
  final String orgId;

  /// @nodoc
  final AnalyticsSettings settings;
}

/// Type signature alias for the optional `onFlush` event handler.
typedef OnBatchFlush = void Function(List<Map<String, dynamic>>);
