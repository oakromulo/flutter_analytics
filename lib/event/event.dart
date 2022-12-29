/// @nodoc
library event;

import 'dart:async';

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
      final dynamic res = await Future.sync(_handler);

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
  late StreamSubscription<Event> _subscription;

  /// @nodoc
  Future<T?> defer<T>(FutureOr<T>? Function() function) async {
    final Event event = Event(function);

    _controller.add(event);

    final eventFuture = await event.future;
    if (eventFuture is T) {
      return eventFuture;
    }
    return null;
  }

  /// @nodoc
  Future<void> destroy() async {
    await _subscription.cancel();
    await _controller.close();
  }

  void _onData(Event event) => _subscription.pause(event.run());
}
