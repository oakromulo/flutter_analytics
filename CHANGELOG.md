## [v2.0.1](https://github.com/oakromulo/flutter_analytics/tree/v2.0.1) - 2019-12-30

- Exceptional DateTime treatment introduced on
  [v0.4.0](https://github.com/oakromulo/flutter_analytics/tree/v0.4.1) removed due to a flutter bug
  that could bypass try/catch blocks and cause an application to crash when attempting to json
  encode datetime in release mode

## [v1.3.1+1](https://github.com/oakromulo/flutter_analytics/tree/v1.3.1) - 2019-12-27

- Stricter flutter, dart and iOS versioning in order to minimize false flag issues

## [v1.2.1](https://github.com/oakromulo/flutter_analytics/tree/v1.2.1) - 2019-12-26

- Dependencies updated

## [v1.2.0](https://github.com/oakromulo/flutter_analytics/tree/v1.2.0) - 2019-10-24

- updated [localstorage](https://pub.dev/packages/localstorage) and
  [flutter_persistent_queue](https://pub.dev/packages/flutter_persistent_queue)

## [v1.1.1+1](https://github.com/oakromulo/flutter_analytics/tree/v1.1.1+1) - 2019-10-18

- update connectivity dependency

## [v1.1.1](https://github.com/oakromulo/flutter_analytics/tree/v1.1.1) - 2019-10-18

- Dependencies and environment constraints updated

## [v1.1.0](https://github.com/oakromulo/flutter_analytics/tree/v1.1.0) - 2019-10-17

- Non-persistent payload pointers added for chronological debugging purposes
- README updated with examples for server-side analytics consumption and OTA config

## [v1.0.0](https://github.com/oakromulo/flutter_analytics/tree/v1.0.0) - 2019-10-16

- Full analytics refactor for improved codebase clarity
- Leverages the latest [flutter_persistent_queue](https://pub.dev/packages/flutter_persistent_queue)
  implementation under the hood
- JSON-encodable `<dynamic>` payloads now supported
- Improved settings and localstorage caching
- Better debugging messages on debug targets and saner error handling throughout

## [v0.4.1](https://github.com/oakromulo/flutter_analytics/tree/v0.4.1) - 2019-10-03

- Improve persistency of `groupId` and `userId`

## [v0.4.0](https://github.com/oakromulo/flutter_analytics/tree/v0.4.0) - 2019-09-26

- Implicit cast of DateTime props within payloads to ISOStrings

## [v0.3.5](https://github.com/oakromulo/flutter_analytics/tree/v0.3.5) - 2019-09-25

- Improved debugging and error handling

## [v0.3.4+1](https://github.com/oakromulo/flutter_analytics/tree/v0.3.4+1) - 2019-09-17

- Minor maintenance

## [v0.3.4](https://github.com/oakromulo/flutter_analytics/tree/v0.3.4) - 2019-09-16

- Updated dependencies

## [v0.3.3](https://github.com/oakromulo/flutter_analytics/tree/v0.3.3) - 2019-06-17

- Improved documentation

## [v0.3.2](https://github.com/oakromulo/flutter_analytics/tree/v0.3.2) - 2019-06-17

- Improved example

## [v0.3.1](https://github.com/oakromulo/flutter_analytics/tree/v0.3.1) - 2019-06-17

- First public release
