/// @nodoc
library segment_identify;

import './segment.dart' show Segment, SegmentTypeEnum;

/// @nodoc
class Identify extends Segment {
  /// @nodoc
  Identify(String userId, [dynamic traits])
      : super(SegmentTypeEnum.IDENTIFY, traits: traits, userId: userId);

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async =>
      (await super.toMap())..remove('properties');
}
