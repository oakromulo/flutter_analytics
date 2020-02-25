/// @nodoc
library test_app;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_analytics/flutter_analytics.dart';
import 'package:flutter_analytics/version_control.dart';

import 'package:flutter_driver/driver_extension.dart';

import './.env.dart' show configUrl;

/// @nodoc
void main() {
  enableFlutterDriverExtension();
  runApp(_MyApp());
}

const _org = 'integrationTests';

class _MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> with WidgetsBindingObserver {
  String txt1 = '', txt2 = '', txt3 = '';

  bool localEnabled = true, remoteEnabled = true, tputEnabled = true;

  Future<String> localTest() async {
    await _clear();
    await Analytics().setup(destinations: ['http://any.com'], orgId: _org);
    await _clear();

    await Analytics().group('myGroup', {'numTrait': 7, 'txtTrait': 'tGroup'});
    await Analytics().identify('myUser');
    await Analytics().screen('A Screen', {'numProp': 5, 'txtProp': 'pScreen'});
    await Analytics().track('An Event', {'numProp': 3, 'txtProp': 'pTrack'});

    await Analytics().flush((batch) async {
      assert(batch.length == 4);

      for (int i = 0; i < 4; ++i) {
        final evt = batch[i] as Map<String, dynamic>;
        final props =
            (evt['properties'] ?? evt['traits']) as Map<String, dynamic>;

        assertEventCore(evt);

        if (i >= 1) {
          assert(evt['anonymousId'] == batch.first['anonymousId']);
          assert(evt['context']['groupId'] == 'myGroup');
          assert(evt['userId'] == 'myUser');

          final firstSdk = batch.first['traits']['sdk'] as Map<String, dynamic>;
          assert(props['sdk']['sessionId'] == firstSdk['sessionId']);
        }

        assert(props['orgId'] == _org);

        switch (i) {
          case 0:
            assert(evt['type'] == 'group');
            assert(evt['traits']['numTrait'].toString() == '7');
            assert(evt['traits']['txtTrait'].toString() == 'tGroup');
            break;

          case 1:
            assert(evt['type'] == 'identify');
            break;

          case 2:
            assert(evt['type'] == 'screen');
            assert(evt['properties']['numProp'].toString() == '5');
            assert(evt['properties']['txtProp'].toString() == 'pScreen');
            break;

          case 3:
            assert(evt['type'] == 'track');
            assert(evt['properties']['numProp'].toString() == '3');
            assert(evt['properties']['txtProp'].toString() == 'pTrack');
            break;
        }
      }

      return true;
    });

    await _clear();

    return 'local test completed successfully';
  }

  Future<String> remoteTest() async {
    final batches = <List<Map<String, dynamic>>>[];

    final onFlush = (List<Map<String, dynamic>> batch) {
      batches.add(batch);
    };

    await _clear();
    Analytics().setup(
        bucket: 'com.bucket',
        configUrl: configUrl,
        onFlush: onFlush,
        orgId: 'remote');
    await _clear();

    Analytics().group('myGroupIdGoesHere');

    Analytics()
        .identify('5c903bce-6fa8-4501-9bfd-7bc52a851aec', <String, dynamic>{
      'birthday': '1997-01-18T00:00:00.000000Z',
      'createdAt': '2018-05-04T14:13:28.941000Z',
      'gender': 'fluid',
    });

    Analytics().screen('Post Viewer', <String, dynamic>{
      'url': 'app://deeplink.myapp/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    Analytics().track('Some Event');

    Analytics().track('Application Backgrounded', <String, dynamic>{
      'url': 'app://deeplink.myapp/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    Analytics().flush();

    while (batches.isEmpty) {
      await Future<void>.delayed(Duration(seconds: 1));
    }

    // may implicate in false negatives for edge cases
    assert(batches.last.length >= 5);

    await _clear();

    return 'remote test completed successfully';
  }

  Future<String> throughputTest() async {
    final t0 = DateTime.now();

    int _evtCnt = 0;
    const totalTracks = 1000;

    final onFlush = (List<Map<String, dynamic>> b) {
      _evtCnt += b.length;
    };

    await _clear();
    Analytics().setup(configUrl: configUrl, onFlush: onFlush, orgId: 'tput');
    await _clear();

    int i = totalTracks;
    while (--i >= 0) {
      Analytics().track('Load Test Event');
    }

    while (_evtCnt < totalTracks - 100) {
      print('event count: $_evtCnt');
      await Future<void>.delayed(Duration(seconds: 1));
    }

    await Analytics().flush();

    final int eventCount = _evtCnt;
    final t1 = DateTime.now();

    final eventTput = eventCount / t1.difference(t0).inSeconds;
    print('throughput: ${eventTput.toStringAsFixed(2)} eps');

    assert(eventTput >= 20.0);

    await _clear();

    return 'throughput test completed successfully';
  }

  @override
  Widget build(_) {
    final bar = AppBar(title: Text('Integration Test'));
    final body = bodyBuilder();
    final bottom = BottomAppBar(child: Row());

    final home = Scaffold(appBar: bar, body: body, bottomNavigationBar: bottom);

    return MaterialApp(home: home);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      Analytics().updateAppLifecycleState(state);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Widget bodyBuilder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text('LOCAL TEST'),
          IconButton(
              key: Key('local'),
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                if (!localEnabled) {
                  return;
                }

                localEnabled = false;

                localTest()
                    .then((res) => setState(() => txt1 = res))
                    .catchError((dynamic e) => setState(() => txt1 = '$e'))
                    .whenComplete(() => setState(() => localEnabled = true));
              }),
          Text(txt1, key: Key('txt1')),
          Divider(),
          Text('REMOTE TEST'),
          IconButton(
              key: Key('remote'),
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                if (!remoteEnabled) {
                  return;
                }

                remoteEnabled = false;

                remoteTest()
                    .then((res) => setState(() => txt2 = res))
                    .catchError((dynamic e) => setState(() => txt2 = '$e'))
                    .whenComplete(() => setState(() => remoteEnabled = true));
              }),
          Text(txt2, key: Key('txt2')),
          Divider(),
          Text('THROUGHPUT TEST'),
          IconButton(
              key: Key('throughput'),
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                if (!tputEnabled) {
                  return;
                }

                tputEnabled = false;

                throughputTest()
                    .then((res) => setState(() => txt3 = res))
                    .catchError((dynamic e) => setState(() => txt3 = '$e'))
                    .whenComplete(() => setState(() => tputEnabled = true));
              }),
          Text(txt3, key: Key('txt3'))
        ],
      ),
    );
  }

  void assertEventCore(Map<String, dynamic> event) {
    assert(event['anonymousId'].toString().length == 64);

    final context = event['context'] as Map<String, dynamic>;

    assert(context['app']['build'].toString() == '8');
    assert(context['app']['version'] == '5.6.7');

    final device = context['device'] as Map<String, dynamic>;

    if (Platform.isIOS) {
      assert(device['id'].toString().length == 36);
      assert(device['manufacturer'].toString().toLowerCase() == 'apple');
      assert(device['model'] == 'iPhone');
      assert(device['name'].toString().contains('iPhone'));
      assert(context['os']['name'] == 'iOS');
    }

    assert(context['library']['name'] == sdkName);
    assert(context['library']['version'] == sdkVersion);

    assert(context['network']['cellular'] as bool || true);
    assert(context['network']['wifi'] as bool || true);

    assert(event['messageId'].toString().length == 36);
    assert(
        DateTime.parse(event['timestamp'].toString()).isBefore(DateTime.now()));

    final props =
        (event['properties'] ?? event['traits']) as Map<String, dynamic>;

    assert(props['sdk']['dartEnv'] == 'DEVELOPMENT');
    assert(props['sdk']['sessionId'].toString().length == 36);
    assert(int.tryParse(props['sdk']['tzOffsetHours'].toString()) >= -12);
    assert(int.tryParse(props['sdk']['tzOffsetHours'].toString()) <= 12);
  }

  Future<void> _clear() async {
    if (Analytics().ready) {
      await Analytics().flush((_) => Future.value(true));
    }
  }
}
