/// @nodoc
library segment_group;

import './segment.dart' show Segment, SegmentTypeEnum;

/// @nodoc
class Group extends Segment {
  /// @nodoc
  Group(String groupId, [Map<String, dynamic> traits])
      : super(SegmentTypeEnum.GROUP, groupId: groupId, traits: traits);

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async =>
      (await super.toMap())..remove('properties');
}
