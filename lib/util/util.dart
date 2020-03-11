/// @nodoc
library util;

import 'package:recase/recase.dart' show ReCase;
import 'package:uuid/uuid.dart' show Uuid;
import 'package:uuid/uuid_util.dart' show UuidUtil;

/// @nodoc
String dartEnv() =>
    bool.fromEnvironment('dart.vm.product') ? 'PRODUCTION' : 'DEVELOPMENT';

/// @nodoc
String camelCase(String s) => _toCase(s, (s) => ReCase(s).camelCase);

/// @nodoc
String titleCase(String s) => _toCase(s, (s) => ReCase(s).titleCase);

/// @nodoc
String uuidV4() =>
    Uuid().v4(options: <String, dynamic>{'rng': UuidUtil.cryptoRNG});

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
