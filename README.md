# Flutter Analytics

A barebones Analytics SDK to collect anonymous metadata from flutter apps.

## Installation

Add dependency to `pubspec.yaml`:

```yaml
dependencies:
  ...
  flutter_analytics: ^0.3.1
```

Run in your terminal:

```sh
flutter packages get
```

## Usage

```dart
import 'package:flutter_analytics/flutter_analytics.dart' show Analytics;

// initial setup to run once on application lifecycle, no need to be awaited
Analytics.setup(
  configUrl: 'https://remote.config',
  destinations: ['https://analytics.server'],
  onFlush: (batch) => debugPrint(batch.toString()),
  orgId: '775b5322-287b-4ca7-a750-86e5e848d226',
);

// uniquely identify current app user (pass `null` if unknown)
Analytics.identify('anUserId');

// uniquely identify group of users (it could be an `appId` or `channelId`)
Analytics.group('someGroupId', { 'numTrait': 7, 'txtTrait': 'tGroup' });

// identify current screen being viewed
Analytics.screen('My Screen', { 'numProp': -1, 'txtProp': 'pScreen'});

// track discrete events
Analytics.track('Any Event', { 'numProp': 3, 'txtProp': 'pTrack'});

// force the SDK to dispatch locally buffered events to remote destination(s)
Analytics.flush()
```

## Example

```sh
cd ~/flutter_analytics/example
flutter packages get
open -a simulator
flutter run
```

## Integration tests

```sh
cd ~/flutter_analytics/test
flutter packages get
flutter drive --target=lib/main.dart
```

## Documentation
```sh
cd ~/flutter_analytics
rm -rf doc
dartdoc
serve doc/api
open 'localhost:5000'
```

## License

MIT
