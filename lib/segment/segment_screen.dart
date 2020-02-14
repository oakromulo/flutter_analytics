/// @nodoc
library segment_screen;

import '../util/util.dart' show titleCase;

import './segment.dart' show Segment, SegmentTypeEnum;

/// @nodoc
class Screen extends Segment {
  /// @nodoc
  Screen(this.name, [dynamic properties])
      : super(SegmentTypeEnum.SCREEN, properties: properties);

  /// @nodoc
  final String name;

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async => (await super.toMap())
    ..addAll(<String, dynamic>{'name': titleCase(name)})
    ..remove('traits');
}
