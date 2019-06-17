import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_analytics/flutter_analytics.dart' show Analytics;

void main() => runApp(_MyApp());

class _MyApp extends StatelessWidget {
  Future<void> _mainTest() async {
    debugPrint('prepare for main test');

    Analytics.setup(
      configUrl: await rootBundle.loadString('.config_url'),
      onFlush: (batch) => debugPrint('all flushed: ${batch.length}'),
      orgId: '775b5322-287b-4ca7-a750-86e5e848d226',
    );

    Analytics.track('Push Notification Received', <String, dynamic>{
      'url': 'app://deeplink/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    Analytics.track('Push Notification Tapped', <String, dynamic>{
      'action': 'ACCEPT',
      'url': 'app://deeplink/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    Analytics.track('Application Opened', <String, dynamic>{
      'url': 'app://deeplink/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    Analytics.track('Push Notification Handled', <String, dynamic>{
      'url': 'app://deeplink/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    Analytics.track('Authentication Requested', <String, dynamic>{
      'engine': 'FACEBOOK_LOGIN',
    });

    Analytics.track('Authentication Failed', <String, dynamic>{
      'engine': 'FACEBOOK_LOGIN',
      'failure': 'EXPIRED_TOKEN'
    });

    // always clear user identity and reset session right after auth fails
    Analytics.identify(null);

    Analytics.screen('Login Prompt', <String, dynamic>{
      'url': 'app://deeplink/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    Analytics.track('Authentication Requested', <String, dynamic>{
      'engine': 'FACEBOOK_LOGIN',
    });

    Analytics.track('Authentication Completed',
        <String, dynamic>{'engine': 'FACEBOOK_LOGIN'});

    Analytics.identify(
        '5c903bce-6fa8-4501-9bfd-7bc52a851aec', <String, dynamic>{
      'birthday': '1997-01-18T00:00:00.000000Z',
      'createdAt': '2018-05-04T14:13:28.941000Z',
      'gender': 'fluid',
    });

    Analytics.screen('Post Viewer', <String, dynamic>{
      'url': 'app://deeplink/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    // called before RootQuery.post API call
    Analytics.track('Post Data Requested', <String, dynamic>{
      'id': '5b450fd6504f3fec66bb99bc',
    });

    // called after RootQuery.post API call
    Analytics.track('Post Data Received', <String, dynamic>{
      'post': <String, dynamic>{
        'access': 'EXCLUSIVE',
        'counts': {
          'countComments': 0,
          'countLikes': 0,
          'countReactions': 0,
          'countShares': 0,
          'countThreads': 0,
          'countUniqueCommenters': 0,
          'countViews': 0,
          'countViewsTotal': 0
        },
        'id': '5bf44dfe9a57ac741f5100ac',
        'publishedAt': '2018-10-15T14:01:47.585000Z',
        'title': 'A Change is Gonna Come',
        'type': 'video'
      }
    });

    // fired once within playerState.initState() override
    Analytics.track('Video Player Instantiated', <String, dynamic>{
      //'state': playerState.toMap()
      'state': <String, dynamic>{'isCasting': false}
    });

    // when playback gets to start by user action or auto-play
    Analytics.track('Video Playback Started', <String, dynamic>{
      'sessionId': '12345',
      'contentAssetIds': ['0129370'],
      'contentPodIds': ['segA', 'segB'],
      'adAssetId': ['ad123', 'ad097'],
      'adPodId': ['adSegA', 'adSegB'],
      'adType': ['mid-roll', 'post-roll'],
      'position': 0,
      'totalLength': 392,
      'bitrate': 100,
      'framerate': 29,
      'videoPlayer': 'youtube',
      'sound': 88,
      'fullScreen': false,
      'adEnabled': true,
      'quality': 'hd1080',
      'livestream': false
    });

    // when a video content segment starts playing within a playback.
    Analytics.track('Video Content Started', <String, dynamic>{
      'sessionId': '12345',
      'assetId': '0129370',
      'podId': 'segA',
      'program': 'Planet Earth',
      'title': 'Seasonal Forests',
      'description': 'the greatest woodlands on earth',
      'season': '1',
      'position': 0,
      'total_length': 3600,
      'genre': 'Documentary',
      'publisher': 'BBC',
      'fullEpisode': true,
      'keywords': ['nature', 'forests', 'earth']
    });

    // triggered every `n` seconds of progress
    Analytics.track('Video Content Playing', <String, dynamic>{});
    Analytics.track('Video Content Playing', <String, dynamic>{});
    Analytics.track('Video Content Playing', <String, dynamic>{});
    Analytics.track('Video Content Playing', <String, dynamic>{});
    Analytics.track('Video Content Playing', <String, dynamic>{});

    // when playback gets paused by user action
    Analytics.track('Video Playback Paused', <String, dynamic>{});

    // when a user manually seeks a certain position of the content or ad
    Analytics.track('Video Playback Seek Started', <String, dynamic>{
      'sessionId': '12345',
      'contentAssetId': '0129370',
      'contentPodId': 'segA',
      'position': 278,
      'seekPosition': 320,
      'totalLength': 392,
      'bitrate': 100,
      'framerate': 29,
      'videoPlayer': 'youtube',
      'sound': 55,
      'fullScreen': false,
      'adEnabled': false,
      'quality': 'hd1080',
      'livestream': false
    });

    // after a user manually seeks a certain position
    Analytics.track('Video Playback Seek Completed', <String, dynamic>{});

    // when playback gets resumed after user action
    Analytics.track('Video Playback Resumed', <String, dynamic>{});

    // triggered every `n` seconds of progress
    Analytics.track('Video Content Playing', <String, dynamic>{});
    Analytics.track('Video Content Playing', <String, dynamic>{});
    Analytics.track('Video Content Playing', <String, dynamic>{});

    // when a video content segment fully completes playing within a playback
    Analytics.track('Video Content Completed', <String, dynamic>{
      'sessionId': '12345',
      'assetId': '0129370',
      'podId': 'segA',
      'program': 'Planet Earth',
      'title': 'Seasonal Forests',
      'description': 'the greatest woodlands on earth',
      'season': '1',
      'position': 3600,
      'total_length': 3600,
      'genre': 'Documentary',
      'publisher': 'BBC',
      'fullEpisode': true,
      'keywords': ['nature', 'forests', 'earth']
    });

    // when playback session is complete
    Analytics.track('Video Playback Completed', <String, dynamic>{
      'sessionId': '12345',
      'contentAssetId': '0129370',
      'contentPodId': 'segA',
      'position': 392,
      'totalLength': 392,
      'bitrate': 100,
      'framerate': 29,
      'videoPlayer': 'youtube',
      'sound': 55,
      'fullScreen': false,
      'adEnabled': false,
      'quality': 'hd1080',
      'livestream': false
    });

    // fired once within playerState.dispose() override
    Analytics.track('Media Player Disposed', <String, dynamic>{
      'state': <String, dynamic>{'isCasting': false}
    });

    Analytics.track('Application Backgrounded', <String, dynamic>{
      'url': 'app://deeplink/post/5b450fd6504f3fec66bb99bc?src=push'
    });

    debugPrint('all events have been registered');

    Analytics.flush();
    debugPrint('event flush scheduled');
  }

  Future<String> _runTests() async {
    try {
      await _mainTest();
      return 'Everything fine, see console!';
    } catch (e, s) {
      debugPrint('$e\n$s');
      return 'Something went wrong, see console!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _runTests(),
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
