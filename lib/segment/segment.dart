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
  Segment(this.type,
      {String groupId, this.properties, this.traits, String userId})
      : _timestamp = DateTime.now().toUtc().toIso8601String() {
    if (type == SegmentTypeEnum.GROUP) {
      Store().groupId = groupId;
    } else if (type == SegmentTypeEnum.IDENTIFY) {
      Store().userId = userId;
    }
  }

  /// @nodoc
  final dynamic properties;

  /// @nodoc
  final dynamic traits;

  /// @nodoc
  final SegmentTypeEnum type;

  static final _dartEnv = dartEnv();

  static String _previousMessageId;
  static String _nextMessageId;

  final String _timestamp;

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async {
    final messageId = _nextMessageId ?? Uuid().v4();
    _nextMessageId = Uuid().v4();

    final props = <String, dynamic>{
      ...AnalyticsParser(properties ?? traits).toJson(),
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
    };

    _previousMessageId = messageId;

    final payload = <String, dynamic>{
      'anonymousId': await Store().anonymousId,
      'context': {...await Context().toMap(), 'groupId': Store().groupId},
      'messageId': messageId,
      'properties': props,
      'timestamp': _timestamp,
      'traits': props..remove('id'),
      'type': type.toString().split('.').last.toLowerCase(),
      'userId': Store().userId
    };

    return payload;
  }
}

/// @nodoc
enum SegmentTypeEnum {
  /// @nodoc
  ALIAS,

  /// @nodoc
  GROUP,

  /// @nodoc
  IDENTIFY,

  /// @nodoc
  PAGE,

  /// @nodoc
  SCREEN,

  /// @nodoc
  TRACK
}
