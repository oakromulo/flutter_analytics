// ignore_for_file: unawaited_futures, public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter_analytics/flutter_analytics.dart';

Future<void> example() async {
  // initial setup to run once on application lifecycle
  Analytics.setup(destinations: ['http://localhost:3000/analytics']);

  // uniquely identify group of users
  Analytics.group('someGroupId', {'numTrait': 7, 'txtTrait': 'tGroup'});

  // uniquely identify current user and its traits
  Analytics.identify('anUserId', {'numTrait': 5, 'txtTrait': 'uUser'});

  // identify current screen being viewed
  Analytics.screen('My Screen', {'numProp': -1, 'txtProp': 'pScreen'});

  // track discrete events
  Analytics.track('Any Event', {'numProp': 3, 'txtProp': 'pTrack'});

  // debug logged events to console (returning `true` bypasses `destinations`)
  Analytics.flush((batch) async {
    batch.forEach(print);

    return true;
  });
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

void main() => runApp(MyApp());
