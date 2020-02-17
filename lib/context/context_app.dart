/// @nodoc
library context_app;

import 'package:package_info/package_info.dart' show PackageInfo;

import '../debug/debug.dart' show Debug;

/// @nodoc
Future<Map<String, dynamic>> contextApp() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();

    return {
      'build': packageInfo.buildNumber,
      'name': packageInfo.appName,
      'namespace': packageInfo.packageName,
      'version': packageInfo.version
    };
  } catch (e, s) {
    Debug().error(e, s);

    return <String, dynamic>{};
  }
}
