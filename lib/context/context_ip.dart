/// @nodoc
library context_ip;

import 'package:http/http.dart' show get;

const _defaultTimeout = Duration(seconds: 5);

/// @nodoc
Future<String> contextIp([Duration timeout = _defaultTimeout]) async {
  try {
    const url = 'https://api.ipify.org';

    return (await get(url).timeout(timeout)).body;
  } catch (_) {
    return '127.0.0.1';
  }
}
