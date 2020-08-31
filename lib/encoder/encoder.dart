/// @nodoc
library encoder;

import 'dart:convert' show base64, JsonUtf8Encoder;
import 'dart:io' show gzip;

/// @nodoc
class Encoder {
  /// @nodoc
  Encoder(List input) : batch = _fill(input);

  /// @nodoc
  final List<Map<String, dynamic>> batch;

  /// @nodoc
  String get batchId {
    try {
      if (batch.isEmpty ||
          batch.first.isEmpty ||
          !batch.first.containsKey('messageId')) {
        throw null;
      }

      return batch.first['messageId'].toString();
    } catch (_) {
      return '';
    }
  }

  /// @nodoc
  @override
  String toString() => '{"batch":"${_encode(batch)}"}';

  static String _encode(List<Map<String, dynamic>> _batch) {
    try {
      return base64.encode(gzip.encode(JsonUtf8Encoder().convert(_batch)));
    } catch (_) {
      return '';
    }
  }

  static List<Map<String, dynamic>> _fill(List input) {
    try {
      final _input = List.of(input ?? []);
      final _batch = _input.cast<Map<String, dynamic>>();

      final sentAt = DateTime.now().toUtc().toIso8601String();

      for (final event in _batch) {
        event['sentAt'] = sentAt;
      }

      return _batch;
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}
