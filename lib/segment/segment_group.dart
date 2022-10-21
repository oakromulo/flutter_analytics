/// @nodoc
library segment_group;

import './segment.dart' show Segment;
import '../store/store.dart' show Store;

/// @nodoc
class Group extends Segment {
  /// @nodoc
  Group(String groupId, [dynamic traits])
      : _setGroupId = Store().setGroupId(groupId),
        super(traits);

  final Future<String?> _setGroupId;

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async {
    final groupId = await _setGroupId;

    final payload = await super.toMap();
    final traits = payload.remove('properties') as Map<String, dynamic>? ??
        <String, dynamic>{};

    return <String, dynamic>{
      ...payload,
      'traits': <String, dynamic>{...traits, 'id': groupId},
      'type': 'group'
    };
  }
}
