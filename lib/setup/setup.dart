library analytics_setup;

import 'dart:convert' show AsciiCodec, base64, JsonUtf8Encoder;
import 'dart:io' show gzip;

import 'package:flutter_persistent_queue/flutter_persistent_queue.dart'
    show PersistentQueue;
import 'package:flutter_persistent_queue/typedefs/typedefs.dart' show OnFlush;
import 'package:http/http.dart' show post, Response;

import '../config/config.dart' show Config;
import '../store/store.dart' show Store;
import '../util/util.dart' show debugError, debugLog;

import './setup_params.dart' show SetupParams, OnBatchFlush;

export './setup_params.dart' show SetupParams, OnBatchFlush;

/// @nodoc
class Setup {
  /// @nodoc
  Setup(SetupParams params) {
    _ready = _setup(params);
  }

  List<String> _destinations;
  Future<bool> _ready;
  List<PersistentQueue> _queues;

  /// @nodoc
  List<String> get destinations => _destinations;

  /// @nodoc
  Future<bool> get ready => _ready;

  /// @nodoc
  List<PersistentQueue> get queues => _queues;

  Future<bool> _setup(SetupParams params) async {
    await Setup._downloadConfig(params.configUrl);
    debugLog(Config());

    _destinations = Setup._dedup(Config().destinations, params.destinations);
    Setup._validateDestinations(_destinations);

    await Setup._resetOrgId(params.orgId);

    _queues = await Setup._initQueues(_destinations, params.onFlush);

    return true;
  }

  static String _base64GzipList(List<Map<String, dynamic>> list) =>
      base64.encode(gzip.encode(JsonUtf8Encoder().convert(list)));

  static List<String> _dedup(List<String> a, List<String> b) =>
      <String>{...a ?? [], ...b ?? []}.toList();

  static Future<void> _downloadConfig(String url) async {
    try {
      if (url == null || url.isEmpty) {
        return;
      }

      await Config().download(url);

      debugLog('remote config fetched successfully');
    } catch (e, s) {
      debugLog('remote config could not be downloaded this time');
      debugError(e, s);
    }
  }

  static String _encode(List<Map<String, dynamic>> batch) =>
      '{"batch":"${Setup._base64GzipList(batch)}"}';

  static void _fillSentAt(List<Map<String, dynamic>> batch) {
    final sentAt = DateTime.now().toUtc().toIso8601String();

    for (var event in batch) {
      event['sentAt'] = sentAt;
    }
  }

  static Future<PersistentQueue> _initQueue(
      String url, OnBatchFlush onBatchFlush) async {
    final pq = PersistentQueue(url.hashCode.toString(),
        onFlush: Setup._onFlush(url, onBatchFlush),
        flushAt: Config().flushAtLength,
        flushTimeout: Config().flushAtDuration,
        maxLength: Config().maxQueueLength);

    await pq.ready;

    debugLog('local buffer created succesfully for destination:\n$url');

    return pq;
  }

  static Future<List<PersistentQueue>> _initQueues(
      List<String> destinations, OnBatchFlush onBatchFlush) async {
    final queues = <PersistentQueue>[];

    for (final url in destinations) {
      queues.add(await Setup._initQueue(url, onBatchFlush));
    }

    return queues;
  }

  static OnFlush _onFlush(String url, OnBatchFlush onBatchFlush) =>
      (List<dynamic> payload) async {
        try {
          final batch = payload.cast<Map<String, dynamic>>();

          if (batch.isNotEmpty) {
            Setup._fillSentAt(batch);
            Setup._validatePost(await Setup._post(url, Setup._encode(batch)));
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

  static Future<Response> _post(String url, String body,
          [Duration timeout = const Duration(seconds: 60)]) =>
      post(url, body: body, encoding: AsciiCodec()).timeout(timeout);

  static Future<void> _resetOrgId(String orgId) async {
    Store().orgId = Future.value(orgId);
    await Store().orgId;
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
