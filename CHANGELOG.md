## [v7.2.2](https://github.com/oakromulo/flutter_analytics/tree/v7.2.2) - 2020-02-25

- Enforce non-null organization header.
- Fix re-setup `bucket` and `settings` not being reloaded correctly.

## [v7.2.1](https://github.com/oakromulo/flutter_analytics/tree/v7.2.1) - 2020-02-25

- Updated dependencies.

## [v7.1.1](https://github.com/oakromulo/flutter_analytics/tree/v7.1.1) - 2020-02-20

- Optional `bucket` header defined at setup time to simplify post-processing of analytics events.

## [v7.0.3](https://github.com/oakromulo/flutter_analytics/tree/v7.0.3) - 2020-02-20

- Improved event metadata synchronicity: segmented asynchronous data now starts to be fetched at
  trigger time instead of at a later stage.

## [v7.0.2](https://github.com/oakromulo/flutter_analytics/tree/v7.0.2) - 2020-02-20

- Updated documentation.

## [v7.0.1](https://github.com/oakromulo/flutter_analytics/tree/v7.0.1) - 2020-02-20

- Updated dependencies.
- Persistent ContextTraits added to improve Segment portability and allow per-event user
  segmentation.
- New headers `{'organization': orgId, 'version': sdkVersion}` added to allow custom server-side
  processing before attempting to decode batches.
- Strong mode compliance.
- Reduced direct dependencies: `localstorage` and `synchronized` removed.
- Non-persistent `sessionId` and `sessionTimeout` to better reflect real world usage.

## [v6.4.1](https://github.com/oakromulo/flutter_analytics/tree/v6.4.1) - 2020-02-17

- Adds additional settings at setup time.
- Minor breaking change: debug toggle moved from setup params directly to Analytics class.

## [v6.3.4](https://github.com/oakromulo/flutter_analytics/tree/v6.3.4) - 2020-02-17

- Feature: get carrier info when available/possible.

## [v6.3.3](https://github.com/oakromulo/flutter_analytics/tree/v6.3.3) - 2020-02-17

- Fixes a non-serious bug with NMEA time not being included in the payloads when available.

## [v6.3.2+1](https://github.com/oakromulo/flutter_analytics/tree/v6.3.2+1) - 2020-02-15

- Default debug mode silent.

## [v6.3.2](https://github.com/oakromulo/flutter_analytics/tree/v6.3.2) - 2020-02-15

- Fix [location](https://pub.dev/packages/location) plugin hanging due to either location services
  disabled (PR [#267](https://github.com/Lyokone/flutterlocation/pull/267)) or race conditions
  (issue [#281](https://github.com/Lyokone/flutterlocation/issues/281)).

## [v6.3.1](https://github.com/oakromulo/flutter_analytics/tree/v6.3.1) - 2020-02-14

- SessionId now resets when host application is backgrounded (as long as
  Analytics::updateAppLifecycleState) is provided
- [location](https://pub.dev/packages/location) plugin updated to `2.4.0`, aligning Android/iOS gps
  times

## [v6.2.1](https://github.com/oakromulo/flutter_analytics/tree/v6.2.1) - 2020-02-13

- Faster/targeted payload parsing.
- All debug messages are now bypassable at setup time.

## [v6.1.1](https://github.com/oakromulo/flutter_analytics/tree/v6.1.1) - 2020-02-12

- [location](https://pub.dev/packages/location) plugin added w/ OTA-adjustable refresh interval
- Automatic lifecycle tracking removed so that the SDK never fires an implicit event without
  explicit user action.
- Refactored internal sequential event buffers.
- Auto-setup when host application resumes from background (at least one previous successful setup
  is required).
- Auto-flush attempt when host application goes into background.

## [v6.0.1](https://github.com/oakromulo/flutter_analytics/tree/v6.0.1) - 2020-02-11

- Breaking change: singleton instantion of `Analytics` objects instead of static calls.
- Support method `::updateAppLifecycleState` added to improve SDK behavior on background.

## [v5.0.1](https://github.com/oakromulo/flutter_analytics/tree/v5.0.1) - 2020-01-20

- Improved and simplified parser.
- Better handling of null and repetitive groupIds and userIds.
- Recases payloads automatically: all object keys get `camelCased` and screen/tracks event names
  become `Title Cased`.

## [v4.0.2](https://github.com/oakromulo/flutter_analytics/tree/v4.0.2) - 2020-01-16

- Exposes parser for external re-use.

## [v4.0.1](https://github.com/oakromulo/flutter_analytics/tree/v4.0.1) - 2020-01-16

- New JSON parser now safely handles `<dynamic>` payloads containing enums, datetimes, custom
  objects, maps and arrays.

## [v3.0.1](https://github.com/oakromulo/flutter_analytics/tree/v3.0.1) - 2020-01-14

- JSON-encodable `<dynamic>` payloads removed due in order to minimize release-time errors

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
