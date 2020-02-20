/// @nodoc
library segment_track;

import '../util/util.dart' show titleCase;
import './segment.dart' show Segment;

/// @nodoc
class Track extends Segment {
  /// @nodoc
  Track(this.event, [dynamic properties]) : super(properties);

  /// @nodoc
  final String event;

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async => <String, dynamic>{
        ...await super.toMap(),
        'event': titleCase(event),
        'type': 'track'
      };
}
