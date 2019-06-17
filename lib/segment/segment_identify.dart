/// @nodoc
library segment_identify;

import '../store/store.dart' show Store;

import './segment.dart' show Segment, SegmentTypeEnum;

/// @nodoc
class Identify extends Segment {
  /// @nodoc
  Identify(String userId, [Map<String, dynamic> traits])
      : _ready = _init(userId),
        super(SegmentTypeEnum.IDENTIFY, traits: traits);

  static final _store = Store();

  final Future<void> _ready;

  /// @nodoc
  @override
  Future<Map<String, dynamic>> toMap() async {
    await _ready;

    return (await super.toMap())..remove('properties');
  }

  static Future<void> _init(userId) async {
    _store.userId = Future.value(userId);

    await _store.userId;
  }
}
