/// @nodoc
library util;

import 'package:recase/recase.dart' show ReCase;

/// @nodoc
String dartEnv() =>
    bool.fromEnvironment('dart.vm.product') ? 'PRODUCTION' : 'DEVELOPMENT';

/// @nodoc
String camelCase(String s) => _toCase(s, (s) => ReCase(s).camelCase);

/// @nodoc
String titleCase(String s) => _toCase(s, (s) => ReCase(s).titleCase);

String _toCase(String string, String Function(String) recaseFunction) {
  try {
    if (string == null || string.isEmpty) {
      return null;
    }

    return recaseFunction(string);
  } catch (_) {
    return null;
  }
}
