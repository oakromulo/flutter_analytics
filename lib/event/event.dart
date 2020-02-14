/// @nodoc
library event;

import 'dart:async' show Completer, StreamController, StreamSubscription;

/// @nodoc
class Event {
  /// @nodoc
  Event(this._handler);

  final _completer = Completer<dynamic>();
  final Future<dynamic> Function() _handler;

  /// @nodoc
  Future<dynamic> get future => _completer.future;

  /// @nodoc
  Future<dynamic> run() async {
    try {
      final res = await _handler();

      _completer.complete(res);

      return res;
    } catch (e, s) {
      _completer.completeError(e, s);

      return null;
    }
  }
}

/// @nodoc
class EventBuffer {
  /// @nodoc
  EventBuffer() {
    _subscription = _controller.stream.listen(_onData);
  }

  final _controller = StreamController<Event>();
  StreamSubscription<Event> _subscription;

  /// @nodoc
  Future<dynamic> enqueue(Event event) {
    _controller.add(event);

    return event.future;
  }

  void _onData(Event event) => _subscription.pause(event.run());
}
