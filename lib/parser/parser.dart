/// @nodoc
library parser;

/// @nodoc
class Parser {
  /// @nodoc
  Parser(this.payload);

  /// @nodoc
  final dynamic payload;

  /// @nodoc
  Map<String, dynamic> toJson() => _encodeMap(payload) ?? <String, dynamic>{};

  static dynamic _encode(dynamic input) {
    try {
      switch (_EntryType.from(input)) {
        case _EntryTypes.NULL:
        case _EntryTypes.SIMPLE:
          return input;

        case _EntryTypes.DATE:
          return _encodeDateTime(input);

        case _EntryTypes.LIST:
          return _encodeList(input);

        case _EntryTypes.MAP:
        case _EntryTypes.OTHER:
          return _encodeMap(input) ?? input.toString();
      }
    } catch (_) {
      return null;
    }
  }

  static String _encodeDateTime(dynamic input) {
    try {
      return (input as DateTime).toUtc().toIso8601String();
    } catch (_) {
      return null;
    }
  }

  static List<dynamic> _encodeList(dynamic input) {
    try {
      return List<dynamic>.of(input).map<dynamic>(_encode).toList();
    } catch (_) {
      return <dynamic>[];
    }
  }

  static Map<String, dynamic> _encodeMap(dynamic input) {
    try {
      if (input == null) {
        return null;
      }

      if (_EntryType.from(input) != _EntryTypes.MAP) {
        return _encodeMap(input.toJson());
      }

      final _input = Map<String, dynamic>.of(input);
      final _output = <String, dynamic>{};

      for (final MapEntry<String, dynamic> entry in _input.entries) {
        _output[entry.key] = _encode(entry.value);
      }

      return _output;
    } catch (_) {
      return null;
    }
  }
}

/// @nodoc
extension _EntryType on _EntryTypes {
  static _EntryTypes from(dynamic input) {
    if (input == null) {
      return _EntryTypes.NULL;
    } else if (_isSimple(input)) {
      return _EntryTypes.SIMPLE;
    } else if (_isList(input)) {
      return _EntryTypes.LIST;
    } else if (_isMap(input)) {
      return _EntryTypes.MAP;
    } else if (_isDateTime(input)) {
      return _EntryTypes.DATE;
    } else {
      return _EntryTypes.OTHER;
    }
  }

  static bool _isDateTime(dynamic input) {
    try {
      return input is DateTime;
    } catch (_) {
      return false;
    }
  }

  static bool _isMap(dynamic input) {
    try {
      return input.runtimeType.toString().contains('Map<String') &&
          Map<String, dynamic>.of(input) is Map<String, dynamic>;
    } catch (_) {
      return false;
    }
  }

  static bool _isList(dynamic input) {
    try {
      return input.runtimeType.toString().contains('List<') &&
          List<dynamic>.of(input) is List<dynamic>;
    } catch (_) {
      return false;
    }
  }

  static bool _isSimple(dynamic input) {
    try {
      return <Type>[bool, double, int, String].contains(input.runtimeType);
    } catch (_) {
      return false;
    }
  }
}

/// @nodoc
enum _EntryTypes { DATE, LIST, MAP, NULL, OTHER, SIMPLE }
