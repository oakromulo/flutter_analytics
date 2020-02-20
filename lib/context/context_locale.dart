/// @nodoc
library context_locale;

import 'package:devicelocale/devicelocale.dart' show Devicelocale;
import '../debug/debug.dart' show Debug;

/// @nodoc
Future<String> contextLocale() async {
  try {
    return Devicelocale.currentLocale;
  } catch (e, s) {
    Debug().error(e, s);

    return '';
  }
}
