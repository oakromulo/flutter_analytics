/// @nodoc
library store;

import 'dart:io' show File;

import 'package:flutter_udid/flutter_udid.dart' show FlutterUdid;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

import '../config/config.dart' show Config;
import '../debug/debug.dart' show Debug;
import '../event/event.dart' show EventBuffer;
import '../lifecycle/lifecycle.dart' show AppLifecycle, AppLifecycleState;
import '../util/util.dart' show uuidV4;

/// @nodoc
class Store {
  /// @nodoc
  factory Store() => _store;

  Store._internal() : _buffer = EventBuffer() {
    _buffer.defer<void>(_init);
  }

  static final _store = Store._internal();

  final EventBuffer _buffer;

  String? _anonymousId;
  String? _groupId;
  String? _orgId;
  String? _path;
  String? _sessionId;
  DateTime? _sessionTimeout;
  String? _userId;

  /// @nodoc
  Future<String?> get anonymousId => _buffer.defer<String>(() => _anonymousId);

  /// @nodoc
  Future<String?> get groupId => _buffer.defer<String>(() => _groupId);

  /// @nodoc
  Future<String?> get orgId => _buffer.defer<String>(() => _orgId);

  /// @nodoc
  Future<String?> get userId => _buffer.defer<String>(() => _userId);

  /// @nodoc
  Future<String?> get sessionId => _buffer.defer<String?>(() async {
        if (_isSessionExpired()) {
          await _resetSession();
        }

        return _sessionId;
      });

  /// @nodoc
  Future<String?> setGroupId(String id) => _buffer.defer<String?>(() async {
        if ((_groupId ?? '') == id) {
          return _groupId;
        }

        return _groupId = await _write('group_id', id);
      });

  /// @nodoc
  Future<String?> setOrgId(String? id) => _buffer.defer<String?>(() async {
        if ((_orgId ?? '') == (id ?? '')) {
          return _orgId;
        }

        return _orgId = await _write('org_id', id);
      });

  /// @nodoc
  Future<String?> setUserId(String id) => _buffer.defer<String?>(() async {
        if ((_userId ?? '') == id) {
          return _userId;
        }

        await _resetSession();

        return _userId = await _write('user_id', id);
      });

  @override
  String toString() => '''state:
    anonymousId: $_anonymousId
    groupId: $_groupId
    orgId: $_orgId
    sessionId: $_sessionId
    sessionTimeout: ${_strFromDate(_sessionTimeout)}\n''';

  Future<void> _init() async {
    try {
      AppLifecycle().subscribe(_onAppLifecycleState);

      _path = (await getApplicationDocumentsDirectory()).path;

      _anonymousId = await _initAnonymousId();
      _groupId = await _read('group_id');
      _orgId = await _read('org_id');
      _userId = await _read('user_id');

      await _resetSession();

      Debug().log('init complete');
    } catch (e, s) {
      Debug().error(e, s);
    }
  }

  Future<String?> _initAnonymousId() async =>
      (await _read('anonymous_id')) ??
      (await _write(
        'anonymous_id',
        await _udid(),
      ));

  bool _isSessionExpired() =>
      _sessionTimeout == null ||
      DateTime.now().toUtc().isAfter(
            _sessionTimeout!,
          );

  String? _nullIfEmpty(String text) => text.isNotEmpty ? text : null;

  void _onAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetSession();
    }
  }

  Future<String?> _read(String key) async {
    if ((_path ?? '').isEmpty) {
      return null;
    }
    try {
      return File('$_path/__analytics_$key').readAsString().then<String>(
            (value) => _nullIfEmpty(value)!,
          );
    } catch (e) {
      return null;
    }
  }

  Future<void> _resetSession() async {
    _sessionId = uuidV4();
    _sessionTimeout = DateTime.now().toUtc().add(Config().sessionTimeout);
  }

  String? _strFromDate(DateTime? date) {
    try {
      if (date == null) {
        return null;
      }

      return date.toIso8601String();
    } catch (_) {
      return null;
    }
  }

  Future<String> _udid() async {
    try {
      final udid = await FlutterUdid.consistentUdid;

      if (udid.isEmpty) {
        return uuidV4();
      }

      return udid;
    } catch (_) {
      return uuidV4();
    }
  }

  Future<String?> _write(String key, String? value) async {
    try {
      if ((_path ?? '').isEmpty) {
        return value;
      }

      await File('$_path/__analytics_$key').create(recursive: true).then((f) => f.writeAsString(value ?? ''));

      return value;
    } catch (_) {
      return value;
    }
  }
}
