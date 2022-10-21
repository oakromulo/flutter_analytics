/// @nodoc
library segment_screen;

import './segment.dart' show Segment;
import '../util/util.dart' show titleCase;

/// @nodoc
class Screen extends Segment {
  /// @nodoc
  Screen(this.name, [dynamic properties]) : super(properties);

  /// @nodoc
  final String name;

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async => <String, dynamic>{
        ...await super.toMap(),
        'name': titleCase(name),
        'type': 'screen'
      };
}
