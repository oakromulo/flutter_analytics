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
  Segment(this.type, {this.properties, this.traits});

  /// @nodoc
  final SegmentTypeEnum type;

  /// @nodoc
  final Map<String, dynamic> properties;

  /// @nodoc
  final Map<String, dynamic> traits;

  static final Store _store = Store();
  static final String _dartEnv = dartEnv();

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async {
    final sdkProps = <String, dynamic>{
      'orgId': await _store.orgId,
      'sdk': <String, dynamic>{
        'dartEnv': _dartEnv,
        'sessionId': await _store.sessionId,
        'setupId': await _store.setupId,
        'tzOffsetHours': DateTime.now().timeZoneOffset.inHours
      }
    };

    final payload = <String, dynamic>{
      'anonymousId': await _store.anonymousId,
      'context': await Context().toMap(),
      'messageId': Uuid().v4(),
      'properties': (properties ?? {})..addAll(sdkProps),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'traits': (traits ?? {})
        ..addAll(sdkProps)
        ..remove('id'),
      'type': type.toString().split('.').last.toLowerCase(),
      'userId': await _store.userId
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
