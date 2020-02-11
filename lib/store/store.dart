/// @nodoc
library store;

import 'dart:async' show Completer;
import 'dart:io' show File;

import 'package:flutter_udid/flutter_udid.dart' show FlutterUdid;
import 'package:localstorage/localstorage.dart' show LocalStorage;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:uuid/uuid.dart' show Uuid;

import '../config/config.dart' show Config;
import '../util/util.dart' show EventBuffer, debugError;

/// @nodoc
class Store {
  /// @nodoc
  factory Store() => _store;

  Store._internal() {
    _hasInit = _init();

    _buffer = EventBuffer<_StoreEvent>(_onEvent);
    _StoreEvent(_StoreEventType.SETUP).future(_buffer).catchError(debugError);
  }

  static final _store = Store._internal();

  LocalStorage _storage;
  EventBuffer<_StoreEvent> _buffer;

  String _groupId;
  String _path;
  String _userId;

  Future<bool> _hasInit;

  /// @nodoc
  Future<String> get anonymousId async =>
      await _get('anonymousId') ?? await _resetAnonymousId();

  /// @nodoc
  String get groupId => (_groupId ?? '').isNotEmpty ? _groupId : null;

  set groupId(String id) {
    if (id != groupId) {
      _groupId = id;

      File('$_path/group_id')
          .create(recursive: true)
          .then((file) => file.writeAsString(id ?? ''))
          .catchError((_) => null);
    }
  }

  /// @nodoc
  Future<String> get orgId => _get('orgId');
  set orgId(Future<String> orgId) => _set('orgId', orgId);

  /// @nodoc
  Future<String> get sessionId async {
    if (await _isSessionInvalid()) {
      await _resetSession();
    }

    return _get('sessionId');
  }

  /// @nodoc
  String get userId => (_userId ?? '').isNotEmpty ? _userId : null;

  set userId(String id) {
    if (id != userId) {
      _userId = id;

      File('$_path/user_id')
          .create(recursive: true)
          .then((file) => file.writeAsString(id ?? ''))
          .catchError((_) => null);
    }
  }

  Future<String> _get(String key) =>
      _StoreEvent(_StoreEventType.GET, key: key).future(_buffer);

  Future<String> _set(String key, Future<String> val) =>
      _StoreEvent(_StoreEventType.SET, key: key, val: val).future(_buffer);

  Future<void> _onEvent(_StoreEvent event) {
    switch (event.type) {
      case _StoreEventType.GET:
        return _onGet(event);

      case _StoreEventType.SET:
        return _onSet(event);

      case _StoreEventType.SETUP:
        return _onSetup(event);

      default:
        return Future.value(null);
    }
  }

  Future<void> _onGet(_StoreEvent event) async {
    try {
      String value;

      final Map<String, dynamic> item =
          await _storage.getItem(event.key) ?? <String, dynamic>{};

      if (item != null && item.containsKey('v')) {
        value = item['v'].toString();
      }

      event.completer.complete(value);
    } catch (e, s) {
      event.completer.completeError(e, s);
    }
  }

  Future<void> _onSet(_StoreEvent event) async {
    try {
      final val = await event.val;

      await _storage.setItem(event.key, {'v': val});

      event.completer.complete();
    } catch (e, s) {
      event.completer.completeError(e, s);
    }
  }

  Future<void> _onSetup(_StoreEvent event) async {
    try {
      await _hasInit;

      _storage = LocalStorage('__analytics_storage__');
      await _storage.ready;

      event.completer.complete();
    } catch (e, s) {
      event.completer.completeError(e, s);
    }
  }

  Future<bool> _init() async {
    try {
      _path = (await getApplicationDocumentsDirectory()).path;

      _groupId ??= await File('$_path/group_id').readAsString();
      _userId ??= await File('$_path/user_id').readAsString();
    } catch (_) {
      // do nothing
    } finally {
      return true;
    }
  }

  Future<bool> _isSessionInvalid() async {
    final t0 = DateTime.tryParse(await _get('sessionStart') ?? '');

    if (t0 == null) {
      return true;
    }

    final sessionTimeout = Config().sessionTimeout;
    return DateTime.now().toUtc().isAfter(t0.add(sessionTimeout));
  }

  Future<void> _resetSession() async {
    final sessionStart = DateTime.now().toUtc().toIso8601String();

    await _set('sessionStart', Future.value(sessionStart));
    await _set('sessionId', Future.value(Uuid().v4()));
  }

  Future<String> _resetAnonymousId() async {
    final id = await _udid();

    await _set('anonymousId', Future.value(id));

    return id;
  }

  Future<String> _udid() async {
    try {
      final udid = await FlutterUdid.consistentUdid;

      if ((udid ?? '').isEmpty) {
        throw null;
      }

      return udid;
    } catch (e) {
      return Uuid().v4();
    }
  }
}

class _StoreEvent {
  _StoreEvent(this.type, {this.key, this.val}) : completer = Completer();

  final _StoreEventType type;

  final String key;
  final Future<String> val;
  final Completer<String> completer;

  Future<String> future(EventBuffer<_StoreEvent> buffer) {
    buffer.push(this);

    return completer.future;
  }
}

enum _StoreEventType { GET, SET, SETUP }
