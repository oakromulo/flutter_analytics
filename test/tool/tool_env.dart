import 'dart:io';

Future<void> main() async {
  final configUrl = Platform.environment['APP_CONFIG_URL'];

  File('lib/.env.dart').writeAsString(configUrl.isNotEmpty
    ? '''
/// @nodoc
const configUrl = '$configUrl';\n'''
    : '''
/// @nodoc
const String configUrl = null;\n''');
}
