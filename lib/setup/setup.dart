library analytics_setup;

import 'dart:convert' show AsciiCodec, json;

import 'package:flutter_persistent_queue/flutter_persistent_queue.dart'
    show PersistentQueue;
import 'package:flutter_persistent_queue/typedefs/typedefs.dart' show OnFlush;
import 'package:http/http.dart' show post, Response;

import '../config/config.dart' show Config;
import '../store/store.dart' show Store;
import '../util/util.dart'
    show base64GzipList, debugError, debugLog, dedupLists, toJson;

import './setup_params.dart' show SetupParams, OnBatchFlush;

export './setup_params.dart' show SetupParams, OnBatchFlush;

/// @nodoc
class Setup {
  /// @nodoc
  Setup(SetupParams params) {
    _ready = _setup(params);
  }

  Future<bool> _ready;
  List<String> _destinations;
  List<PersistentQueue> _queues;

  /// @nodoc
  Future<bool> get ready => _ready;

  /// @nodoc
  List<String> get destinations => _destinations;

  /// @nodoc
  List<PersistentQueue> get queues => _queues;

  Future<void> _downloadConfig(Config config, String url) async {
    try {
      if (url == null || url.isEmpty) {
        return;
      }

      await config.download(url);

      debugLog('remote config fetched successfully');
    } catch (e, s) {
      debugLog('remote config could not be downloaded this time');
      debugError(e, s);
    }
  }

  String _encode(List<Map<String, dynamic>> batch) =>
      json.encode({'batch': base64GzipList(batch)});

  void _fillSentAt(List<Map<String, dynamic>> batch) {
    final sentAt = DateTime.now().toUtc().toIso8601String();

    for (var event in batch) {
      event['sentAt'] = sentAt;
    }
  }

  Future<PersistentQueue> _initQueue(
      Config config, String url, OnBatchFlush onBatchFlush) async {
    final pq = PersistentQueue(url.hashCode.toString(),
        onFlush: _onFlush(url, onBatchFlush),
        flushAt: config.flushAtLength,
        flushTimeout: config.flushAtDuration,
        maxLength: config.maxQueueLength);

    await pq.ready;

    debugLog('local buffer created succesfully for destination:\n$url');

    return pq;
  }

  Future<List<PersistentQueue>> _initQueues(Config config,
      List<String> destinations, OnBatchFlush onBatchFlush) async {
    final queues = <PersistentQueue>[];

    for (final url in destinations) {
      queues.add(await _initQueue(config, url, onBatchFlush));
    }

    return queues;
  }

  OnFlush _onFlush(String url, OnBatchFlush onBatchFlush) =>
      (List<dynamic> payload) async {
        try {
          final batch = payload.map(toJson).toList();

          if (batch.isNotEmpty) {
            _fillSentAt(batch);
            _validatePost(await _post(url, _encode(batch)));
          }

          try {
            (onBatchFlush ?? (_) => {})(batch);
          } catch (_) {
            // completely ignore callback errors on this scope
          }

          debugLog('an analytics batch got succesfully flushed to:\n$url');

          return true;
        } catch (e, s) {
          debugLog('an analytics batch could not be flushed to:\n$url');
          debugError(e, s);

          return false;
        }
      };

  Future<Response> _post(String url, String body,
          [Duration timeout = const Duration(seconds: 60)]) =>
      post(url, body: body, encoding: AsciiCodec()).timeout(timeout);

  Future<void> _resetOrgId(Store store, String orgId) async {
    store.orgId = Future.value(orgId);
    await store.orgId;
  }

  Future<bool> _setup(SetupParams params) async {
    final config = Config();
    final store = Store();

    await _downloadConfig(config, params.configUrl);
    debugLog(config);

    _destinations = dedupLists(config.destinations, params.destinations);
    _validateDestinations(_destinations);

    await _resetOrgId(store, params.orgId);

    _queues = await _initQueues(config, _destinations, params.onFlush);

    return true;
  }

  void _validateDestinations(List<String> destinations) {
    if (destinations.isEmpty) {
      throw Exception('no destinations have been provided');
    }
  }

  void _validatePost(Response res) {
    if (!res.body.contains('success')) {
      throw Exception('InvalidServerResponse');
    }
  }
}
