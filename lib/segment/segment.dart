/// @nodoc
library segment;

import 'package:uuid/uuid.dart' show Uuid;

import '../context/context.dart' show Context;
import '../store/store.dart' show Store;
import '../util/util.dart' show dartEnv, fixEncoding;

export './segment_group.dart' show Group;
export './segment_identify.dart' show Identify;
export './segment_screen.dart' show Screen;
export './segment_track.dart' show Track;

/// @nodoc
abstract class Segment {
  /// @nodoc
  Segment(this.type,
      {this.groupId, this.properties, this.traits, this.userId}) {
    if (groupId != null) {
      _store.groupId = groupId;
    } else {
      groupId = _store.groupId;
    }

    if (userId != null) {
      _store.userId = userId;
    } else {
      userId = _store.userId;
    }
  }

  /// @nodoc
  final SegmentTypeEnum type;

  /// @nodoc
  String groupId;

  /// @nodoc
  final Map<String, dynamic> properties;

  /// @nodoc
  final Map<String, dynamic> traits;

  /// @nodoc
  String userId;

  static final Store _store = Store();
  static final String _dartEnv = dartEnv();

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async {
    final sdkProps = <String, dynamic>{
      'orgId': await _store.orgId,
      'sdk': <String, dynamic>{
        'dartEnv': _dartEnv,
        'sessionId': await _store.sessionId,
        'tzOffsetHours': DateTime.now().timeZoneOffset.inHours
      }
    };

    final payload = <String, dynamic>{
      'anonymousId': await _store.anonymousId,
      'context': {...await Context().toMap(), 'groupId': groupId},
      'messageId': Uuid().v4(),
      'properties': (properties ?? {})..addAll(sdkProps),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'traits': (traits ?? {})
        ..addAll(sdkProps)
        ..remove('id'),
      'type': type.toString().split('.').last.toLowerCase(),
      'userId': userId
    };

    fixEncoding(payload);

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
