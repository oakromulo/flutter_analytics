# Flutter Analytics

A barebones Analytics SDK to collect anonymous metadata from flutter apps.

## Installation

Add dependency to `pubspec.yaml`:

```yaml
dependencies:
  ...
  flutter_analytics: ^0.3.5
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
  destinations: ['https://remote.server'],
  onFlush: (batch) => batch.forEach(print),
  orgId: '775b5322-287b-4ca7-a750-86e5e848d226',
);

// uniquely identify group of users
Analytics.group('someGroupId', { 'numTrait': 7, 'txtTrait': 'tGroup' });

// uniquely identify current user and its traits
Analytics.identify('anUserId', { 'numTrait': 5, 'txtTrait': 'uUser' });

// identify current screen being viewed
Analytics.screen('My Screen', { 'numProp': -1, 'txtProp': 'pScreen'});

// track discrete events
Analytics.track('Any Event', { 'numProp': 3, 'txtProp': 'pTrack'});

// manually force the SDK to dispatch locally buffered events
Analytics.flush();
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
