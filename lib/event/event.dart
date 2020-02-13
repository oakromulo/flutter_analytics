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
  Future<dynamic> run() => _handler()
      .then((_) => _completer.complete())
      .catchError((e, s) => _completer.completeError(e, s));
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
  Future<dynamic> enqueue(Event event) => _add(event).then((_) => event.future);

  Future<void> _add(Event event) async => _controller.add(event);
  void _onData(Event event) => _subscription.pause(event.run());
}
