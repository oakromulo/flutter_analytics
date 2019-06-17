// ignore_for_file: lines_longer_than_80_chars

/// Establishes constants required for proper [Config] functioning.
library config_settings;

/// Default settings whenever OTA settings cannot be fetched via [remoteUrl].
const defaults = <String, dynamic>{
  'defaultTimeoutSecs': 60,
  'flushAtLength': 100,
  'flushAtSecs': 300,
  'maxQueueLength': 10000,
  'sessionTimeoutSecs': 1800
};
