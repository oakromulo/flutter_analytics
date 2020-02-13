# Flutter Analytics

A barebones Analytics SDK to collect anonymous metadata from flutter apps.

## Installation

Add dependency to `pubspec.yaml`:

```yaml
dependencies:
  ...
  flutter_analytics: ^6.0.1
```

Run in your terminal:

```sh
flutter packages get
```

## Usage

```dart
import 'package:flutter_analytics/flutter_analytics.dart' show Analytics;

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
```

## Server-side consumption example

Receive batches of flutter_analytics on AWS Lambda and ship them to S3:

```python
from base64 import b64decode
from boto3 import client
from datetime import datetime
from dateutil.parser import parse
from gzip import GzipFile
from io import BytesIO
from json import dumps, loads
from zlib import decompress, MAX_WBITS

s3 = client('s3')

bucket = 'my.bucket'
output_file = 'output.json'

def lambda_handler(event, context):
  try:
    return {'statusCode': 200, 'body': upload(event)}
  except Exception as e:
    return {'statusCode': 500, 'body': str(e)}


def upload(event):
  decoded = b64decode(loads(event['body'])['batch'])

  batch = loads(decompress(decoded, MAX_WBITS | 16))

  gz_body = BytesIO()

  gz = GzipFile(None, 'wb', 1, gz_body)
  gz.write(dumps(batch).encode('utf-8'))
  gz.close()

  s3.put_object(
    Body=gz_body.getvalue(),
    Bucket=bucket,
    Key=output_file,
    ContentEncoding='gzip',
    ContentType='application/json'
  )

  return '{"success":true}'
```

## OTA remote configuration

A remote config file can be supplied like this:

```dart
Analytics().setup(
  configUrl: 'https://gist.githubusercontent.com/oakromulo/7678b2b187a24e47c0ba93085575477d/raw/e72767273e4e6a73d14377f650be63d66033a6e3/config.json'
)
```

## Location

### Android

In order to use the [location](https://pub.dev/packages/location) plugin in Android, you have to add
this permission in AndroidManifest.xml :

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Update your gradle.properties file with this:

```
android.enableJetifier=true
android.useAndroidX=true
org.gradle.jvmargs=-Xmx1536M
```

Please also make sure that you have those dependencies in your build.gradle:

```
  dependencies {
      classpath 'com.android.tools.build:gradle:3.3.0'
      classpath 'com.google.gms:google-services:4.2.0'
  }
...
  compileSdkVersion 28
```

### iOS

For device [location](https://pub.dev/packages/location) information in iOS the following permission
descriptions must be added to `Info.plist`:

```xml
NSLocationWhenInUseUsageDescription
NSLocationAlwaysUsageDescription
```

**Warning:** there is a currently a bug in iOS simulator in which you have to manually select a
Location several times in order for the Simulator to actually send data. Please keep that in mind
when testing in iOS simulator.

The OnNmeaMessageListener property is only available for minimum SDK of 24.

## Run the example on a simulator

```sh
cd ~/flutter_analytics/example
flutter packages get
open -a simulator
flutter run
```

## Run integration tests

```sh
cd ~/flutter_analytics/test
flutter packages get
APP_CONFIG_URL="https://remote.config" flutter pub run tool/tool_env.dart
flutter drive --target=lib/main.dart
```

## License

MIT
