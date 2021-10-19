/// @nodoc
library segment_identify;

import './segment.dart' show Segment;
import '../context/context.dart' show Context;
import '../parser/parser.dart' show AnalyticsParser;
import '../store/store.dart' show Store;

/// @nodoc
class Identify extends Segment {
  /// @nodoc
  Identify(String userId, [dynamic traits])
      : _setUserId = Store().setUserId(userId),
        super(traits) {
    Context.traits = <String, dynamic>{
      ...AnalyticsParser(traits).toJson(),
      'id': userId
    };
  }

  final Future<String?> _setUserId;

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async {
    final userId = await _setUserId;

    final payload = await super.toMap();
    final traits = payload.remove('properties') as Map<String, dynamic>? ??
        <String, dynamic>{};

    return <String, dynamic>{
      ...payload,
      'traits': <String, dynamic>{...traits, 'id': userId},
      'type': 'identify'
    };
  }
}
