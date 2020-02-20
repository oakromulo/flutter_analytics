/// @nodoc
library segment;

import 'package:uuid/uuid.dart' show Uuid;
import '../context/context.dart' show Context;
import '../lifecycle/lifecycle.dart' show AppLifecycle;
import '../parser/parser.dart' show AnalyticsParser;
import '../store/store.dart' show Store;
import '../util/util.dart' show dartEnv;
export './segment_group.dart' show Group;
export './segment_identify.dart' show Identify;
export './segment_screen.dart' show Screen;
export './segment_track.dart' show Track;

/// @nodoc
abstract class Segment {
  /// @nodoc
  Segment(dynamic properties)
      : _properties = AnalyticsParser(properties).toJson(),
        _timestamp = DateTime.now().toUtc().toIso8601String();

  static final _dartEnv = dartEnv();

  static String _previousMessageId;
  static String _nextMessageId;

  final Map<String, dynamic> _properties;
  final String _timestamp;

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async {
    final messageId = _nextMessageId ?? Uuid().v4();
    _nextMessageId = Uuid().v4();

    final payload = <String, dynamic>{
      'anonymousId': await Store().anonymousId,
      'context': await Context().toMap(),
      'messageId': messageId,
      'properties': <String, dynamic>{
        ..._properties,
        'orgId': await Store().orgId,
        'sdk': <String, dynamic>{
          'appLifecycle':
              AppLifecycle().state.toString().split('AppLifecycleState.')[1],
          'dartEnv': _dartEnv,
          'nextMessageId': _nextMessageId,
          'previousMessageId': _previousMessageId ?? messageId,
          'sessionId': await Store().sessionId,
          'tzOffsetHours': DateTime.now().timeZoneOffset.inHours
        }
      },
      'timestamp': _timestamp,
      'userId': await Store().userId
    };

    _previousMessageId = messageId;

    return payload;
  }
}
