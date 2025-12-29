/// VhPlyr Controller for Flutter
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'vh_plyr_state.dart';

/// Controller for VhPlyr player
///
/// Provides Dart API to control the web-based Plyr player via JS evaluation.
/// Use with [VhPlyr] widget or standalone with your own WebView.
class VhPlyrController extends ChangeNotifier {
  InAppWebViewController? _webViewController;

  // State
  VhPlyrState _state = const VhPlyrState();
  List<VhPlyrQuality> _qualities = [];

  // Event streams
  final _eventController = StreamController<VhPlyrEvent>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// Current player state
  VhPlyrState get state => _state;

  /// Available quality levels
  List<VhPlyrQuality> get qualities => _qualities;

  /// Stream of all player events
  Stream<VhPlyrEvent> get onEvent => _eventController.stream;

  /// Stream of error messages
  Stream<String> get onError => _errorController.stream;

  /// Stream of specific events
  Stream<VhPlyrEvent> get onReady =>
      onEvent.where((e) => e.type == VhPlyrEventType.ready);
  Stream<VhPlyrEvent> get onPlay =>
      onEvent.where((e) => e.type == VhPlyrEventType.play);
  Stream<VhPlyrEvent> get onPause =>
      onEvent.where((e) => e.type == VhPlyrEventType.pause);
  Stream<VhPlyrEvent> get onEnded =>
      onEvent.where((e) => e.type == VhPlyrEventType.ended);
  Stream<VhPlyrEvent> get onTimeUpdate =>
      onEvent.where((e) => e.type == VhPlyrEventType.timeUpdate);
  Stream<VhPlyrEvent> get onProgress =>
      onEvent.where((e) => e.type == VhPlyrEventType.progress);
  Stream<VhPlyrEvent> get onSeeking =>
      onEvent.where((e) => e.type == VhPlyrEventType.seeking);
  Stream<VhPlyrEvent> get onSeeked =>
      onEvent.where((e) => e.type == VhPlyrEventType.seeked);
  Stream<VhPlyrEvent> get onVolumeChange =>
      onEvent.where((e) => e.type == VhPlyrEventType.volumeChange);
  Stream<VhPlyrEvent> get onFullscreenChange =>
      onEvent.where((e) => e.type == VhPlyrEventType.fullscreenChange);
  Stream<VhPlyrEvent> get onQualityChange =>
      onEvent.where((e) => e.type == VhPlyrEventType.qualityChange);

  /// Whether the controller is attached to a WebView
  bool get isAttached => _webViewController != null;

  /// Whether the player is ready
  bool get isReady => _state.isReady;

  /// Whether the player is currently playing
  bool get isPlaying => _state.isPlaying;

  /// Attach to WebView controller
  void attach(InAppWebViewController controller) {
    _webViewController = controller;
    _setupHandlers();
  }

  /// Detach from WebView controller
  void detach() {
    _webViewController = null;
  }

  void _setupHandlers() {
    _webViewController?.addJavaScriptHandler(
      handlerName: 'VhPlyrEvent',
      callback: (args) {
        if (args.isNotEmpty) {
          _handleEvent(args[0]);
        }
      },
    );
  }

  void _handleEvent(dynamic data) {
    try {
      final json = data is String
          ? jsonDecode(data)
          : data as Map<String, dynamic>;
      final event = VhPlyrEvent.fromJson(json);

      // Update state based on event
      _updateStateFromEvent(event);

      // Emit event
      _eventController.add(event);
      notifyListeners();
    } catch (e) {
      debugPrint('VhPlyrController: Error parsing event: $e');
    }
  }

  void _updateStateFromEvent(VhPlyrEvent event) {
    switch (event.type) {
      case VhPlyrEventType.ready:
        _state = _state.copyWith(
          isReady: true,
          duration: (event.data['duration'] ?? 0).toDouble(),
          isLive: event.data['isLive'] ?? false,
        );
        break;

      case VhPlyrEventType.play:
        _state = _state.copyWith(
          isPlaying: true,
          isPaused: false,
          isStopped: false,
        );
        break;

      case VhPlyrEventType.pause:
        _state = _state.copyWith(isPlaying: false, isPaused: true);
        break;

      case VhPlyrEventType.ended:
        _state = _state.copyWith(
          isPlaying: false,
          isPaused: true,
          isEnded: true,
        );
        break;

      case VhPlyrEventType.timeUpdate:
        _state = _state.copyWith(
          currentTime: (event.data['currentTime'] ?? 0).toDouble(),
          duration: (event.data['duration'] ?? _state.duration).toDouble(),
        );
        break;

      case VhPlyrEventType.progress:
        _state = _state.copyWith(
          buffered: (event.data['buffered'] ?? 0).toDouble(),
        );
        break;

      case VhPlyrEventType.seeking:
        _state = _state.copyWith(isSeeking: true);
        break;

      case VhPlyrEventType.seeked:
        _state = _state.copyWith(isSeeking: false);
        break;

      case VhPlyrEventType.volumeChange:
        _state = _state.copyWith(
          volume: (event.data['volume'] ?? 1).toDouble(),
          muted: event.data['muted'] ?? false,
        );
        break;

      case VhPlyrEventType.fullscreenChange:
        _state = _state.copyWith(
          isFullscreen: event.data['isFullscreen'] ?? false,
        );
        break;

      case VhPlyrEventType.qualityChange:
        _state = _state.copyWith(quality: event.data['quality'] ?? -1);
        break;

      case VhPlyrEventType.error:
        _errorController.add(event.data['message'] ?? 'Unknown error');
        break;

      case VhPlyrEventType.manifestParsed:
        final qualitiesData = event.data['qualities'] as List? ?? [];
        _qualities = qualitiesData
            .map((q) => VhPlyrQuality.fromJson(q))
            .toList();
        _state = _state.copyWith(isLive: event.data['isLive'] ?? false);
        break;

      default:
        break;
    }
  }

  // ============ Playback Controls ============

  /// Start playback
  Future<void> play() => _evaluateJs('VhPlyr.play()');

  /// Pause playback
  Future<void> pause() => _evaluateJs('VhPlyr.pause()');

  /// Toggle play/pause
  Future<void> togglePlay() => _evaluateJs('VhPlyr.togglePlay()');

  /// Stop playback and reset
  Future<void> stop() => _evaluateJs('VhPlyr.stop()');

  /// Restart from beginning
  Future<void> restart() => _evaluateJs('VhPlyr.restart()');

  // ============ Seeking ============

  /// Seek to specific time in seconds
  Future<void> seek(double seconds) => _evaluateJs('VhPlyr.seek($seconds)');

  /// Forward by seconds (default: 10)
  Future<void> forward([double seconds = 10]) =>
      _evaluateJs('VhPlyr.forward($seconds)');

  /// Rewind by seconds (default: 10)
  Future<void> rewind([double seconds = 10]) =>
      _evaluateJs('VhPlyr.rewind($seconds)');

  // ============ Volume ============

  /// Set volume (0-1)
  Future<void> setVolume(double level) =>
      _evaluateJs('VhPlyr.setVolume($level)');

  /// Get current volume
  Future<double> getVolume() async {
    final result = await _evaluateJs('VhPlyr.getVolume()');
    return double.tryParse(result?.toString() ?? '') ?? 1.0;
  }

  /// Set muted state
  Future<void> setMuted(bool muted) => _evaluateJs('VhPlyr.setMuted($muted)');

  /// Toggle mute
  Future<void> toggleMute() =>
      _evaluateJs('VhPlyr.setMuted(!VhPlyr.isMuted())');

  // ============ Speed ============

  /// Set playback speed (0.5 - 2)
  Future<void> setSpeed(double rate) => _evaluateJs('VhPlyr.setSpeed($rate)');

  /// Get current speed
  Future<double> getSpeed() async {
    final result = await _evaluateJs('VhPlyr.getSpeed()');
    return double.tryParse(result?.toString() ?? '') ?? 1.0;
  }

  // ============ Quality ============

  /// Set quality level (height in pixels, or 0 for auto)
  Future<void> setQuality(int quality) =>
      _evaluateJs('VhPlyr.setQuality($quality)');

  /// Get current quality
  Future<int> getQuality() async {
    final result = await _evaluateJs('VhPlyr.getQuality()');
    return int.tryParse(result?.toString() ?? '') ?? 0;
  }

  /// Refresh available qualities
  Future<List<VhPlyrQuality>> getQualities() async {
    final result = await _evaluateJs('JSON.stringify(VhPlyr.getQualities())');
    if (result != null) {
      try {
        final list = jsonDecode(result.toString()) as List;
        _qualities = list.map((q) => VhPlyrQuality.fromJson(q)).toList();
        return _qualities;
      } catch (e) {
        debugPrint('VhPlyrController: Error parsing qualities: $e');
      }
    }
    return _qualities;
  }

  // ============ Fullscreen ============

  /// Enter fullscreen
  Future<void> enterFullscreen() => _evaluateJs('VhPlyr.enterFullscreen()');

  /// Exit fullscreen
  Future<void> exitFullscreen() => _evaluateJs('VhPlyr.exitFullscreen()');

  /// Toggle fullscreen
  Future<void> toggleFullscreen() => _evaluateJs('VhPlyr.toggleFullscreen()');

  // ============ Source ============

  /// Load a new source URL
  Future<void> loadSource(String url, {bool autoplay = false}) =>
      _evaluateJs('VhPlyr.loadSource("$url", $autoplay)');

  /// Get current source URL
  Future<String> getSource() async {
    final result = await _evaluateJs('VhPlyr.getSource()');
    return result?.toString() ?? '';
  }

  // ============ State ============

  /// Get full player state
  Future<VhPlyrState> getState() async {
    final result = await _evaluateJs('VhPlyr.getState()');
    if (result != null) {
      _state = VhPlyrState.fromJsonString(result.toString());
      notifyListeners();
    }
    return _state;
  }

  /// Get current playback time
  Future<double> getCurrentTime() async {
    final result = await _evaluateJs('VhPlyr.getCurrentTime()');
    return double.tryParse(result?.toString() ?? '') ?? 0;
  }

  /// Get total duration
  Future<double> getDuration() async {
    final result = await _evaluateJs('VhPlyr.getDuration()');
    return double.tryParse(result?.toString() ?? '') ?? 0;
  }

  /// Get buffered percentage
  Future<double> getBuffered() async {
    final result = await _evaluateJs('VhPlyr.getBuffered()');
    return double.tryParse(result?.toString() ?? '') ?? 0;
  }

  // ============ Picture-in-Picture ============

  /// Enter Picture-in-Picture mode
  Future<void> enterPiP() => _evaluateJs('VhPlyr.enterPiP()');

  /// Exit Picture-in-Picture mode
  Future<void> exitPiP() => _evaluateJs('VhPlyr.exitPiP()');

  // ============ Controls ============

  /// Show player controls
  Future<void> showControls() => _evaluateJs('VhPlyr.showControls()');

  /// Hide player controls
  Future<void> hideControls() => _evaluateJs('VhPlyr.hideControls()');

  // ============ Cleanup ============

  /// Destroy player instance
  Future<void> destroy() => _evaluateJs('VhPlyr.destroy()');

  Future<dynamic> _evaluateJs(String script) async {
    if (_webViewController == null) {
      debugPrint('VhPlyrController: WebView not attached');
      return null;
    }
    try {
      return await _webViewController!.evaluateJavascript(source: script);
    } catch (e) {
      debugPrint('VhPlyrController: JS evaluation error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _eventController.close();
    _errorController.close();
    super.dispose();
  }
}
