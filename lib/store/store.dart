/// @nodoc
library store;

import 'dart:io' show File;

import 'package:flutter_udid/flutter_udid.dart' show FlutterUdid;
import 'package:localstorage/localstorage.dart' show LocalStorage;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:uuid/uuid.dart' show Uuid;

import '../config/config.dart' show Config;
import '../event/event.dart' show Event, EventBuffer;
import '../util/util.dart' show debugError;

/// @nodoc
class Store {
  /// @nodoc
  factory Store() => _store;

  Store._internal() {
    _hasInit = _init();
    _buffer = EventBuffer()..enqueue(Event(_onSetup)).catchError(debugError);
  }

  static final _store = Store._internal();

  LocalStorage _storage;
  EventBuffer _buffer;

  String _groupId;
  String _path;
  String _userId;

  Future _hasInit;

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

  Future<String> _get(String key) async {
    try {
      return await _buffer.enqueue(Event(() => _onGet(key))) as String;
    } catch (e, s) {
      debugError(e, s);

      return null;
    }
  }

  Future<void> _set(String key, Future<String> val) =>
      _buffer.enqueue(Event(() => _onSet(key, val))).catchError(debugError);

  Future<String> _onGet(String key) async {
    String value;

    final Map<String, dynamic> item =
        await _storage.getItem(key) ?? <String, dynamic>{};

    if (item != null && item.containsKey('v') && item['v'] != null) {
      value = item['v'].toString();
    }

    return value;
  }

  Future<void> _onSet(String key, Future<String> val) =>
      val.then((v) => _storage.setItem(key, {'v': v}));

  Future<void> _onSetup() async {
    await _hasInit;

    _storage = LocalStorage('__analytics_storage__');
    await _storage.ready;
  }

  Future _init() async {
    try {
      _path = (await getApplicationDocumentsDirectory()).path;

      _groupId ??= await File('$_path/group_id').readAsString();
      _userId ??= await File('$_path/user_id').readAsString();
    } catch (_) {
      // do nothing
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
