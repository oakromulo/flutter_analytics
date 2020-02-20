/// @nodoc
library encoder;

import 'dart:convert' show base64, JsonUtf8Encoder;
import 'dart:io' show gzip;

/// @nodoc
class Encoder {
  /// @nodoc
  Encoder(List<dynamic> input) : batch = _fill(input);

  /// @nodoc
  final List<Map<String, dynamic>> batch;

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

  static List<Map<String, dynamic>> _fill(List<dynamic> input) {
    try {
      final _input = List<dynamic>.of(input ?? <dynamic>[]);
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
