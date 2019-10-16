/// @nodoc
library event;

import 'dart:async' show Completer;
import 'package:flutter_persistent_queue/typedefs/typedefs.dart' show OnFlush;

import '../segment/segment.dart' show Segment;
import '../setup/setup.dart' show SetupParams;
import '../util/util.dart' show EventBuffer;

/// @nodoc
class Event {
  /// @nodoc
  Event(this.type, {this.child, this.enabled, this.flush, this.setup});

  /// @nodoc
  final EventType type;

  /// @nodoc
  final Segment child;

  /// @nodoc
  final bool enabled;

  /// @nodoc
  final OnFlush flush;

  /// @nodoc
  final SetupParams setup;

  /// @nodoc
  final Completer<void> completer = Completer();

  /// @nodoc
  Future<void> future(EventBuffer<Event> buffer) {
    buffer.push(this);

    return completer.future;
  }
}

/// @nodoc
enum EventType {
  /// @nodoc
  FLUSH,

  /// @nodoc
  LOG,

  /// @nodoc
  SETUP
}
