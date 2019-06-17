/// @nodoc
library segment_group;

import '../store/store.dart' show Store;

import './segment.dart' show Segment, SegmentTypeEnum;

/// @nodoc
class Group extends Segment {
  /// @nodoc
  Group(String groupId, [Map<String, dynamic> traits])
      : _ready = _init(groupId),
        super(SegmentTypeEnum.GROUP, traits: traits);

  static final _store = Store();

  final Future<void> _ready;

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async {
    await _ready;

    return (await super.toMap())..remove('properties');
  }

  static Future<void> _init(groupId) async {
    _store.groupId = Future.value(groupId);

    await _store.groupId;
  }
}
