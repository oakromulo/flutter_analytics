/// @nodoc
library segment;

import 'package:uuid/uuid.dart' show Uuid;
import '../context/context.dart' show Context;
import '../event/event.dart' show EventBuffer;
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
        _buffer = EventBuffer(),
        _properties = AnalyticsParser(properties).toJson(),
        _timestamp = DateTime.now().toUtc().toIso8601String(),
        _tzOffsetHours = DateTime.now().timeZoneOffset.inHours {
    _anonymousId = _buffer.defer<String>(() => Store().anonymousId);
    _context = _buffer.defer<Map<String, dynamic>>(() => Context().toMap());
    _orgId = _buffer.defer<String>(() => Store().orgId);
    _sessionId = _buffer.defer<String>(() => Store().sessionId);
    _userId = _buffer.defer<String>(() => Store().userId);
  }

  static final _dartEnv = dartEnv();

  static String _previousMessageId;
  static String _nextMessageId;

  final String _appLifecycle;
  final EventBuffer _buffer;
  final Map<String, dynamic> _properties;
  final String _timestamp;
  final int _tzOffsetHours;

  Future<String> _anonymousId;
  Future<Map<String, dynamic>> _context;
  Future<String> _orgId;
  Future<String> _sessionId;
  Future<String> _userId;

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async {
    final messageId = _nextMessageId ?? Uuid().v4();
    _nextMessageId = Uuid().v4();

    final payload = <String, dynamic>{
      'anonymousId': await _anonymousId,
      'context': await _context,
      'messageId': messageId,
      'properties': <String, dynamic>{
        ..._properties,
        'orgId': await _orgId,
        'sdk': <String, dynamic>{
          'appLifecycle': _appLifecycle,
          'dartEnv': _dartEnv,
          'nextMessageId': _nextMessageId,
          'previousMessageId': _previousMessageId ?? messageId,
          'sessionId': await _sessionId,
          'tzOffsetHours': _tzOffsetHours
        }
      },
      'timestamp': _timestamp,
      'userId': await _userId
    };

    _previousMessageId = messageId;

    await _buffer.destroy();

    return payload;
  }
}
