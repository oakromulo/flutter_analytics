/// @nodoc
library setup;

import 'dart:async' show FutureOr;
import 'dart:convert' show AsciiCodec;

import 'package:flutter_persistent_queue/flutter_persistent_queue.dart' show PersistentQueue;
import 'package:http/http.dart' show post, Response;
import '../config/config.dart' show Config;
import '../debug/debug.dart' show Debug;
import '../encoder/encoder.dart' show Encoder;
import '../event/event.dart' show EventBuffer;
import '../settings/settings.dart' show AnalyticsSettings;
import '../store/store.dart' show Store;
import '../version_control.dart' show sdkVersion;

/// @nodocs
class Setup {
  /// @nodoc
  Setup(this.params) : _buffer = EventBuffer() {
    _buffer.defer(() => _setup(params));
  }

  /// @nodoc
  final SetupParams params;

  /// @nodoc
  Future<void>? ready;

  final EventBuffer _buffer;

  late List<String> _destinations;
  List<PersistentQueue>? _queues;

  /// @nodoc
  Future<List<PersistentQueue>?> get queues => _buffer.defer<List<PersistentQueue>>(
        () => _queues,
      );

  Future<void> _setup(SetupParams params) async {
    Config().settings = params.settings;
    await _downloadConfig(params.configUrl);
    Debug().log(Config());

    _destinations = _dedup(Config().destinations, params.destinations);
    _validateDestinations(_destinations);
    Debug().log('destinations: $_destinations');

    await Store().setOrgId(params.orgId);
    Debug().log(Store());

    _queues = await _initQueues(_destinations, params);
  }

  static List<String> _dedup(List<String> a, List<String>? b) => <String>{
        ...a,
        ...b ?? <String>[]
      }.toList();

  static Future<void> _downloadConfig(String? url) async {
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
    String url,
    SetupParams params,
  ) async {
    final headers = <String, String>{
      'bucket': params.bucket ?? '',
      'organization': params.orgId ?? '',
      'version': sdkVersion
    };

    final pq = PersistentQueue(
      url.hashCode.toString(),
      onFlush: _onFlush(url, params.onFlush, headers),
      flushAt: Config().flushAtLength,
      flushTimeout: Config().flushAtDuration,
      maxLength: Config().maxQueueLength,
      nickname: url,
    );

    await pq.ready;

    Debug().log('local buffer created succesfully for destination:\n$url');

    return pq;
  }

  static Future<List<PersistentQueue>> _initQueues(
    List<String> destinations,
    SetupParams params,
  ) async {
    final queues = <PersistentQueue>[];

    for (final url in destinations) {
      queues.add(await _initQueue(url, params));
    }

    return queues;
  }

  static FutureOr Function(List) _onFlush(
    String url,
    OnBatchFlush? onBatchFlush,
    Map<String, String> headers,
  ) =>
      (List input) async {
        try {
          final encoder = Encoder(input);
          final batch = encoder.batch;

          if (batch.isNotEmpty) {
            final _post = post(
              Uri.parse(url),
              body: encoder.toString(),
              encoding: AsciiCodec(),
              headers: {
                ...headers,
                'batch': encoder.batchId
              },
            );
            _validatePost(await _post.timeout(Config().defaultTimeout));
          }

          try {
            await Future.sync(() => (onBatchFlush ?? ((_) => null))(batch));
          } catch (_) {
            // do nothing
          }

          Debug().log('an analytics batch got succesfully flushed to:\n$url');

          return true;
        } catch (e, s) {
          Debug().log('an analytics batch could not be flushed to:\n$url');
          Debug().error(e, s);

          return false;
        }
      };

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
    this.bucket,
    this.configUrl,
    this.destinations,
    this.onFlush,
    this.orgId,
    this.settings,
  );

  /// @nodoc
  final String? bucket;

  /// @nodoc
  final String? configUrl;

  /// @nodoc
  final List<String>? destinations;

  /// @nodoc
  final OnBatchFlush? onFlush;

  /// @nodoc
  final String? orgId;

  /// @nodoc
  final AnalyticsSettings? settings;
}

/// Type signature alias for the optional `onFlush` event handler.
typedef OnBatchFlush = FutureOr<void> Function(List<Map<String, dynamic>>);
