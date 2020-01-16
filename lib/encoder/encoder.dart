/// @nodoc
library encoder;

import 'dart:convert' show base64, JsonUtf8Encoder;
import 'dart:io' show gzip;

import '../parser/parser.dart' show AnalyticsParser;

/// @nodoc
class Encoder {
  /// @nodoc
  Encoder(List<dynamic> input) : batch = _parse(input);

  /// @nodoc
  final List<Map<String, dynamic>> batch;

  /// @nodoc
  @override
  String toString() => '{"batch":"$_string"}';

  static List<Map<String, dynamic>> _parse(List<dynamic> input) {
    try {
      final _batch = List<dynamic>.of(input ?? []).cast<Map<String, dynamic>>();

      _fillSentAt(_batch);

      return _batch.map((item) => AnalyticsParser(item).toJson()).toList();
    } catch (_) {
      return [];
    }
  }

  static void _fillSentAt(List<Map<String, dynamic>> input) {
    try {
      final sentAt = DateTime.now().toUtc().toIso8601String();

      for (final event in input) {
        event['sentAt'] = sentAt;
      }
    } catch (_) {
      return;
    }
  }

  String get _string {
    try {
      return base64.encode(gzip.encode(JsonUtf8Encoder().convert(batch)));
    } catch (_) {
      return null;
    }
  }
}
