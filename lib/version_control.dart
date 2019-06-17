/// Collection of constants for static SDK-wide static versioning
///
/// p.s. this is required due to pubspec limitations when bundling plugins
library version_control;

/// Package name, should match the SDKs `pubspec.yaml`
const sdkName = 'flutter_analytics';

/// Package version, should match the SDKs `pubspec.yaml`
const sdkVersion = '0.3.2';

/// Library map concatenating release information for easy consumption
const sdkPackage = <String, dynamic>{'name': sdkName, 'version': sdkVersion};
