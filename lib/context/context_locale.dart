/// @nodoc
library context_locale;

import 'package:devicelocale/devicelocale.dart' show Devicelocale;

import '../util/util.dart' show debugError;

/// @nodoc
Future<String> contextLocale() async {
  try {
    return Devicelocale.currentLocale;
  } catch (e, s) {
    debugError(e, s);

    return '';
  }
}
