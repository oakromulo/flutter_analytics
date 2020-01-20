/// @nodoc
library segment_track;

import '../util/util.dart' show titleCase;

import './segment.dart' show Segment, SegmentTypeEnum;

/// @nodoc
class Track extends Segment {
  /// @nodoc
  Track(this.event, [Map<String, dynamic> properties])
      : super(SegmentTypeEnum.TRACK, properties: properties);

  /// @nodoc
  final String event;

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async => (await super.toMap())
    ..addAll(<String, dynamic>{'event': titleCase(event)})
    ..remove('traits');
}
