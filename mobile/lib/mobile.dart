/// VhPlyr - VUIHOC Player Package
///
/// A Flutter package for playing HLS live streams using Plyr.io via WebView.
/// Designed as a backup solution for YouTube Live streaming.
///
/// ## Usage
///
/// ```dart
/// import 'package:mobile/vh_plyr.dart';
///
/// // Create controller
/// final controller = VhPlyrController();
///
/// // Use widget
/// VhPlyr(
///   controller: controller,
///   options: VhPlyrOptions(
///     playerUrl: 'https://cdn.vuihoc.vn/player/index.html',
///     initialSource: 'https://example.com/live.m3u8',
///   ),
/// )
///
/// // Control playback
/// controller.play();
/// controller.pause();
/// controller.seek(30);
/// controller.setVolume(0.5);
///
/// // Listen to events
/// controller.onTimeUpdate.listen((event) {
///   print('Time: ${event.data['currentTime']}');
/// });
/// ```
library;

export 'vh_plyr.dart';
export 'vh_plyr_controller.dart';
export 'vh_plyr_state.dart';
