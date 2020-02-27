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
      : _appLifecycle = AppLifecycle().toString(),
        _anonymousId = Store().anonymousId,
        _context = Context().toMap(),
        _properties = AnalyticsParser(properties).toJson(),
        _sessionId = Store().sessionId,
        _timestamp = DateTime.now().toUtc().toIso8601String(),
        _tzOffsetHours = DateTime.now().timeZoneOffset.inHours,
        _userId = Store().userId;

  static final _dartEnv = dartEnv();

  static String _previousMessageId;
  static String _nextMessageId;

  final String _appLifecycle;
  final Future<String> _anonymousId;
  final Future<Map<String, dynamic>> _context;
  final Map<String, dynamic> _properties;
  final Future<String> _sessionId;
  final String _timestamp;
  final int _tzOffsetHours;
  final Future<String> _userId;

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async {
    await Future<void>.delayed(Duration(microseconds: 1));

    final messageId = _nextMessageId ?? Uuid().v4();
    final previousMessageId = _previousMessageId ?? messageId;

    _previousMessageId = messageId;
    _nextMessageId = Uuid().v4();

    final nextMessageId = _nextMessageId;

    final payload = <String, dynamic>{
      'anonymousId': await _anonymousId,
      'context': await _context,
      'messageId': messageId,
      'properties': <String, dynamic>{
        ..._properties,
        'orgId': await Store().orgId,
        'sdk': <String, dynamic>{
          'appLifecycle': _appLifecycle,
          'dartEnv': _dartEnv,
          'nextMessageId': nextMessageId,
          'previousMessageId': previousMessageId,
          'sessionId': await _sessionId,
          'tzOffsetHours': _tzOffsetHours
        }
      },
      'timestamp': _timestamp,
      'userId': await _userId
    };

    return payload;
  }
}
