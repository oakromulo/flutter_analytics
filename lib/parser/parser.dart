/// Exposes [AnalyticsParser].
library parser;

import '../util/util.dart' show camelCase;

/// Basic class for safely parsing `<dynamic>` [payload]s.
class AnalyticsParser {
  /// Return an [AnalyticsParser] instance.
  AnalyticsParser(this.payload);

  /// Input [Object] to be parsed.
  final dynamic payload;

  /// Return a JSON-encodable `Map<String, dynamic>` matching [payload].
  Map<String, dynamic> toJson() => _encodeMap(payload) ?? <String, dynamic>{};

  static dynamic _encode(dynamic input) {
    if (_isSimpleType(input)) {
      return input;
    } else if (_isDateTime(input)) {
      return _encodeDateTime(input);
    } else if (_isList(input)) {
      return _encodeList(input);
    }

    return _encodeMap(input) ?? _encodeDefault(input);
  }

  static String? _encodeDateTime(dynamic input) {
    try {
      return (input as DateTime).toUtc().toIso8601String();
    } catch (_) {
      return null;
    }
  }

  static String? _encodeDefault(dynamic input) {
    try {
      if (input == null) {
        return null;
      }

      return input.toString();
    } catch (_) {
      return null;
    }
  }

  static List _encodeList(dynamic input) {
    try {
      return List.of(input as Iterable).map(_encode).toList();
    } catch (_) {
      return [];
    }
  }

  static Map<String, dynamic>? _encodeMap(dynamic input) {
    try {
      if (input == null) {
        return null;
      }

      if (!_isMap(input)) {
        return _encodeMap(input.toJson());
      }

      final _input = Map<String, dynamic>.of(input as Map<String, dynamic>);
      final _output = <String, dynamic>{};

      for (final entry in _input.entries) {
        final key = camelCase(entry.key);

        if (key != null) {
          _output[key] = _encode(entry.value);
        }
      }

      return _output;
    } catch (_) {
      return null;
    }
  }

  static bool _isDateTime(dynamic input) => input is DateTime;

  static bool _isList(dynamic input) => input is Iterable;

  static bool _isMap(dynamic input) => input is Map<String, dynamic>;

  static bool _isSimpleType(dynamic input) {
    try {
      if (input == null) {
        return true;
      }

      return <Type>[bool, double, int, String].contains(input.runtimeType);
    } catch (_) {
      return false;
    }
  }
}
