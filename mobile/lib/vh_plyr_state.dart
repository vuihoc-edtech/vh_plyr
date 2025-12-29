/// VhPlyr state models
library;

import 'dart:convert';

/// Current state of the VhPlyr player
class VhPlyrState {
  final bool isReady;
  final bool isPlaying;
  final bool isPaused;
  final bool isStopped;
  final bool isEnded;
  final bool isSeeking;
  final bool isLive;
  final bool isFullscreen;
  final double currentTime;
  final double duration;
  final double volume;
  final bool muted;
  final double speed;
  final int quality;
  final double buffered;

  const VhPlyrState({
    this.isReady = false,
    this.isPlaying = false,
    this.isPaused = true,
    this.isStopped = true,
    this.isEnded = false,
    this.isSeeking = false,
    this.isLive = false,
    this.isFullscreen = false,
    this.currentTime = 0,
    this.duration = 0,
    this.volume = 1,
    this.muted = false,
    this.speed = 1,
    this.quality = -1,
    this.buffered = 0,
  });

  factory VhPlyrState.fromJson(Map<String, dynamic> json) {
    return VhPlyrState(
      isReady: json['isReady'] ?? false,
      isPlaying: json['isPlaying'] ?? false,
      isPaused: json['isPaused'] ?? true,
      isStopped: json['isStopped'] ?? true,
      isEnded: json['isEnded'] ?? false,
      isSeeking: json['isSeeking'] ?? false,
      isLive: json['isLive'] ?? false,
      isFullscreen: json['isFullscreen'] ?? false,
      currentTime: (json['currentTime'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 1).toDouble(),
      muted: json['muted'] ?? false,
      speed: (json['speed'] ?? 1).toDouble(),
      quality: json['quality'] ?? -1,
      buffered: (json['buffered'] ?? 0).toDouble(),
    );
  }

  factory VhPlyrState.fromJsonString(String jsonString) {
    try {
      return VhPlyrState.fromJson(json.decode(jsonString));
    } catch (e) {
      return const VhPlyrState();
    }
  }

  Map<String, dynamic> toJson() => {
    'isReady': isReady,
    'isPlaying': isPlaying,
    'isPaused': isPaused,
    'isStopped': isStopped,
    'isEnded': isEnded,
    'isSeeking': isSeeking,
    'isLive': isLive,
    'isFullscreen': isFullscreen,
    'currentTime': currentTime,
    'duration': duration,
    'volume': volume,
    'muted': muted,
    'speed': speed,
    'quality': quality,
    'buffered': buffered,
  };

  /// Progress percentage (0-100)
  double get progress => duration > 0 ? (currentTime / duration) * 100 : 0;

  VhPlyrState copyWith({
    bool? isReady,
    bool? isPlaying,
    bool? isPaused,
    bool? isStopped,
    bool? isEnded,
    bool? isSeeking,
    bool? isLive,
    bool? isFullscreen,
    double? currentTime,
    double? duration,
    double? volume,
    bool? muted,
    double? speed,
    int? quality,
    double? buffered,
  }) {
    return VhPlyrState(
      isReady: isReady ?? this.isReady,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isStopped: isStopped ?? this.isStopped,
      isEnded: isEnded ?? this.isEnded,
      isSeeking: isSeeking ?? this.isSeeking,
      isLive: isLive ?? this.isLive,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      currentTime: currentTime ?? this.currentTime,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      muted: muted ?? this.muted,
      speed: speed ?? this.speed,
      quality: quality ?? this.quality,
      buffered: buffered ?? this.buffered,
    );
  }

  @override
  String toString() => 'VhPlyrState(${toJson()})';
}

/// Event types emitted by VhPlyr
enum VhPlyrEventType {
  ready,
  play,
  pause,
  ended,
  timeUpdate,
  progress,
  seeking,
  seeked,
  volumeChange,
  waiting,
  canPlay,
  fullscreenChange,
  qualityChange,
  error,
  manifestParsed,
}

/// Player event with type and data
class VhPlyrEvent {
  final VhPlyrEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  VhPlyrEvent({required this.type, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  factory VhPlyrEvent.fromJson(Map<String, dynamic> json) {
    final eventName = json['event'] as String? ?? '';
    return VhPlyrEvent(
      type: _parseEventType(eventName),
      data: json['data'] ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
    );
  }

  static VhPlyrEventType _parseEventType(String name) {
    switch (name) {
      case 'onReady':
        return VhPlyrEventType.ready;
      case 'onPlay':
        return VhPlyrEventType.play;
      case 'onPause':
        return VhPlyrEventType.pause;
      case 'onEnded':
        return VhPlyrEventType.ended;
      case 'onTimeUpdate':
        return VhPlyrEventType.timeUpdate;
      case 'onProgress':
        return VhPlyrEventType.progress;
      case 'onSeeking':
        return VhPlyrEventType.seeking;
      case 'onSeeked':
        return VhPlyrEventType.seeked;
      case 'onVolumeChange':
        return VhPlyrEventType.volumeChange;
      case 'onWaiting':
        return VhPlyrEventType.waiting;
      case 'onCanPlay':
        return VhPlyrEventType.canPlay;
      case 'onFullscreenChange':
        return VhPlyrEventType.fullscreenChange;
      case 'onQualityChange':
        return VhPlyrEventType.qualityChange;
      case 'onError':
        return VhPlyrEventType.error;
      case 'onManifestParsed':
        return VhPlyrEventType.manifestParsed;
      default:
        return VhPlyrEventType.ready;
    }
  }

  @override
  String toString() => 'VhPlyrEvent($type, $data)';
}

/// Quality level information
class VhPlyrQuality {
  final int index;
  final int height;
  final int width;
  final int bitrate;
  final String label;

  const VhPlyrQuality({
    required this.index,
    required this.height,
    required this.width,
    required this.bitrate,
    required this.label,
  });

  factory VhPlyrQuality.fromJson(Map<String, dynamic> json) {
    return VhPlyrQuality(
      index: json['index'] ?? 0,
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      bitrate: json['bitrate'] ?? 0,
      label: json['label'] ?? '${json['height'] ?? 0}p',
    );
  }

  static const auto = VhPlyrQuality(
    index: -1,
    height: 0,
    width: 0,
    bitrate: 0,
    label: 'Auto',
  );

  @override
  String toString() => label;
}

/// Configuration options for VhPlyr
///
/// Supports two modes:
/// 1. **Remote URL (CDN)** - Load player from remote server
/// 2. **Local Assets** - Load player from package assets (offline-capable)
class VhPlyrOptions {
  /// Use local assets bundled with the package instead of remote URL.
  ///
  /// When `true`:
  /// - Player HTML/JS/CSS is loaded from package assets
  /// - Works offline after first install
  /// - Faster initial load
  ///
  /// When `false` (default):
  /// - Player is loaded from `playerUrl`
  /// - Easy to update player without app update
  /// - Requires network connection
  final bool useLocalAssets;

  /// Base URL where the web player is hosted (only used when `useLocalAssets` is false)
  ///
  /// Default: 'https://cdn.vuihoc.vn/player/index.html'
  final String playerUrl;

  /// Initial source URL (HLS m3u8 or direct video)
  final String? initialSource;

  /// Auto-play when loaded
  final bool autoplay;

  /// Show controls
  final bool controls;

  /// Enable fullscreen
  final bool fullscreen;

  /// Initial volume (0-1)
  final double volume;

  /// Initial muted state
  final bool muted;

  const VhPlyrOptions({
    this.useLocalAssets = false,
    this.playerUrl = 'https://cdn.vuihoc.vn/player/index.html',
    this.initialSource,
    this.autoplay = false,
    this.controls = true,
    this.fullscreen = true,
    this.volume = 1.0,
    this.muted = false,
  });

  /// Factory for remote URL mode
  const factory VhPlyrOptions.remote({
    String playerUrl,
    String? initialSource,
    bool autoplay,
    bool controls,
    bool fullscreen,
    double volume,
    bool muted,
  }) = VhPlyrOptions;

  /// Factory for local assets mode
  const VhPlyrOptions.local({
    String? initialSource,
    bool autoplay = false,
    bool controls = true,
    bool fullscreen = true,
    double volume = 1.0,
    bool muted = false,
  }) : this(
         useLocalAssets: true,
         playerUrl: '',
         initialSource: initialSource,
         autoplay: autoplay,
         controls: controls,
         fullscreen: fullscreen,
         volume: volume,
         muted: muted,
       );

  /// Build the full URL with query parameters (for remote mode)
  String buildRemoteUrl() {
    final uri = Uri.parse(playerUrl);
    final params = <String, String>{};

    if (initialSource != null) {
      params['url'] = initialSource!;
    }
    if (autoplay) {
      params['autoplay'] = 'true';
    }

    return uri
        .replace(queryParameters: params.isNotEmpty ? params : null)
        .toString();
  }
}
