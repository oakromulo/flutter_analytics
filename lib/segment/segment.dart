/// @nodoc
library segment;

import '../context/context.dart' show Context;
import '../event/event.dart' show EventBuffer;
import '../lifecycle/lifecycle.dart' show AppLifecycle;
import '../parser/parser.dart' show AnalyticsParser;
import '../store/store.dart' show Store;
import '../util/util.dart' show dartEnv, uuidV4;
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

  static final _buffer = EventBuffer();
  static final _dartEnv = dartEnv();

  static String? _previousMessageId;
  static String? _nextMessageId;

  final String _appLifecycle;
  final Future<String?> _anonymousId;
  final Future<Map<String, dynamic>> _context;
  final Map<String, dynamic> _properties;
  final Future<String?> _sessionId;
  final String _timestamp;
  final int _tzOffsetHours;
  final Future<String?> _userId;

  /// @nodoc
  Future<Map<String, dynamic>> toMap() async {
    final messageId = _nextMessageId ?? (await _genUuid());
    final previousMessageId = _previousMessageId ?? messageId;

    _previousMessageId = messageId;
    _nextMessageId = await _genUuid();

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

  static Future<String?> _genUuid() => _buffer.defer(() =>
      Future<void>.delayed(Duration(milliseconds: 1)).then((_) => uuidV4()));
}
