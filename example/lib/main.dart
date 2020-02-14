// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter_analytics/flutter_analytics.dart' show Analytics;

Future<void> example() async {
  // initial setup to run once on application lifecycle
  Analytics().setup(destinations: ['http://localhost:3000/analytics']);

  // uniquely identify group of users
  Analytics().group('someGroupId', {'numTrait': 7, 'txtTrait': 'tGroup'});

  // uniquely identify current user and its traits
  Analytics().identify('anUserId', {'numTrait': 5, 'txtTrait': 'uUser'});

  // identify current screen being viewed
  Analytics().screen('My Screen', {'numProp': -1, 'txtProp': 'pScreen'});

  // track discrete events
  Analytics().track('Any Event', {'numProp': 3, 'txtProp': 'pTrack'});

  // debug logged events to console (return `true` to bypass `destinations`)
  await Analytics().flush((batch) async {
    batch.forEach(print);

    return true;
  });
}

class ExampleApp extends StatefulWidget {
  const ExampleApp();

  @override
  State<StatefulWidget> createState() => ExampleAppState();
}

class ExampleAppState extends State<ExampleApp> with WidgetsBindingObserver {
  @override
  Widget build(context) {
    return FutureBuilder(
        future: runExample(),
        builder: (context, snapshot) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(snapshot.data ?? 'hold on'),
              ),
            ),
          );
        });
  } // build

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

  Future<String> runExample() async {
    try {
      await Analytics().requestPermission();
      await example();

      return 'Everything fine, see console!';
    } catch (e, s) {
      debugPrint('$e\n$s');

      return 'Something went wrong, see console!';
    }
  }
}

void main() => runApp(const ExampleApp());
