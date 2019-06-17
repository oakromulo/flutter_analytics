/// @nodoc
library context_app;

import 'package:package_info/package_info.dart' show PackageInfo;

import '../util/util.dart' show debugError;

/// @nodoc
Future<Map<String, dynamic>> contextApp() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();

    return {
      'build': packageInfo.buildNumber ?? 0,
      'name': packageInfo.appName ?? 'n/a',
      'namespace': packageInfo.packageName,
      'version': packageInfo.version
    };
  } catch (e, s) {
    debugError(e, s);

    return {};
  }
}
