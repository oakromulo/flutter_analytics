// ignore_for_file: unawaited_futures, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_analytics/flutter_analytics.dart';

Future<void> example() async {
  // final printer = (b) => {print('⬇⬇⬇\n$b\n⬆⬆⬆')};
  final printer = (b) {
    var type = b['type'];
    var id = b['userId'];
    print('$type $id');
  };

  await Analytics.setup(
    configUrl: await configUrl(),
    onFlush: (batch) => batch.forEach(printer),
    orgId: '775b5322-287b-4ca7-a750-86e5e848d226',
  );

  await Analytics.flush();
  await Analytics.track('A');
  await Analytics.identify('n/a');
  await Analytics.track('B');
  await Analytics.identify('midId');
  await Analytics.track('C');
  await Analytics.identify('n/a');
  await Analytics.track('D');
  await Analytics.identify('finalId');
  await Analytics.track('e');
  await Analytics.flush();

  /*
  await Analytics.flush();
  Analytics.track('A');
  Analytics.identify('n/a');
  Analytics.track('B');
  Analytics.identify('midId');
  Analytics.track('C');
  Analytics.identify('n/a');
  Analytics.track('D');
  Analytics.identify('finalId');
  Analytics.track('e');
  await Analytics.flush();
  */

  /*
  await Analytics.flush();
  Analytics.track('A');
  await Analytics.identify('n/a');
  Analytics.track('B');
  await Analytics.identify('midId');
  Analytics.track('C');
  await Analytics.identify('n/a');
  Analytics.track('D');
  await Analytics.identify('finalId');
  Analytics.track('E');
  await Analytics.flush();
  */
}

Future<String> runExample() async {
  try {
    await example();

    return 'Everything fine, see console!';
  } catch (e, s) {
    debugPrint('$e\n$s');

    return 'Something went wrong, see console!';
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: runExample(),
      builder: (context, snapshot) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(snapshot.data.toString() ?? 'hold on'),
            ),
          ),
        );
      }, // builder
    );
  } // build
}

Future<String> configUrl() => rootBundle.loadString('.config_url');

void main() => runApp(MyApp());
