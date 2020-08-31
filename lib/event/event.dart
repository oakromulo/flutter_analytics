/// @nodoc
library event;

import 'dart:async'
    show Completer, FutureOr, StreamController, StreamSubscription;

/// @nodoc
class Event {
  /// @nodoc
  Event(this._handler);

  final _completer = Completer();
  final FutureOr Function() _handler;

  /// @nodoc
  Future get future => _completer.future;

  /// @nodoc
  Future run() async {
    try {
      final res = await Future.sync(_handler);

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
  Future<T> defer<T>(FutureOr<T> Function() function) async {
    final Event event = Event(function);

    _controller.add(event);

    return await event.future as T;
  }

  /// @nodoc
  Future<void> destroy() async {
    await _subscription.cancel();
    await _controller.close();
  }

  void _onData(Event event) => _subscription.pause(event.run());
}
