# Flutter Analytics

A barebones Analytics SDK to collect anonymous metadata from flutter apps.

## Installation

Add dependency to `pubspec.yaml`:

```yaml
dependencies:
  ...
  flutter_analytics: ^3.0.1
```

Run in your terminal:

```sh
flutter packages get
```

## Usage

```dart
import 'package:flutter_analytics/flutter_analytics.dart' show Analytics;

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
Analytics.setup(
  configUrl: 'https://gist.githubusercontent.com/oakromulo/7678b2b187a24e47c0ba93085575477d/raw/e72767273e4e6a73d14377f650be63d66033a6e3/config.json'
)
```

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
APP_CONFIG_URL="https://remote.config" dart tool/tool_env.dart
flutter drive --target=lib/main.dart
```

## Build documentation locally

```sh
cd ~/flutter_analytics
rm -rf doc
dartdoc
serve doc/api
open 'localhost:5000'
```

## License

MIT
