# VhPlyr Mobile API

Flutter package API cho điều khiển player qua WebView.

## Installation

```yaml
dependencies:
  mobile:
    path: ../mobile
```

## Quick Start

```dart
import 'package:mobile/mobile.dart';

class LivePlayerPage extends StatefulWidget {
  @override
  State<LivePlayerPage> createState() => _LivePlayerPageState();
}

class _LivePlayerPageState extends State<LivePlayerPage> {
  final controller = VhPlyrController();

  @override
  void initState() {
    super.initState();
    
    // Listen to events
    controller.onReady.listen((_) => print('Ready!'));
    controller.onError.listen((error) => print('Error: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return VhPlyr(
      controller: controller,
      options: VhPlyrOptions(
        playerUrl: 'https://cdn.vuihoc.vn/player/index.html',
        initialSource: 'https://example.com/live.m3u8',
        autoplay: true,
      ),
      aspectRatio: 16 / 9,  // Default
      onReady: () => print('Player ready'),
      onError: (error) => print('Error: $error'),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

## Two Loading Modes

### 1. Remote URL Mode (default)

Player được load từ CDN. Ưu điểm: dễ update player mà không cần update app.

```dart
VhPlyr(
  controller: controller,
  options: VhPlyrOptions.remote(
    playerUrl: 'https://cdn.vuihoc.vn/player/index.html',
    initialSource: 'https://example.com/live.m3u8',
    autoplay: true,
  ),
)
```

### 2. Local Assets Mode

Player được bundle trong app. Ưu điểm: hoạt động offline, load nhanh hơn.

```dart
VhPlyr(
  controller: controller,
  options: VhPlyrOptions.local(
    initialSource: 'https://example.com/live.m3u8',
    autoplay: true,
  ),
)
```

## VhPlyr Widget

| Property          | Type                | Default           | Description           |
| ----------------- | ------------------- | ----------------- | --------------------- |
| `controller`      | `VhPlyrController`  | required          | Controller instance   |
| `options`         | `VhPlyrOptions`     | `VhPlyrOptions()` | Player config         |
| `aspectRatio`     | `double`            | `16/9`            | Aspect ratio          |
| `useAspectRatio`  | `bool`              | `true`            | Enable aspect ratio   |
| `backgroundColor` | `Color`             | `Colors.black`    | Loading background    |
| `placeholder`     | `Widget?`           | null              | Custom loading widget |
| `errorBuilder`    | `Function(String)?` | null              | Custom error widget   |
| `onReady`         | `VoidCallback?`     | null              | Ready callback        |
| `onError`         | `Function(String)?` | null              | Error callback        |

## VhPlyrOptions

| Property         | Type      | Default |
| ---------------- | --------- | ------- |
| `useLocalAssets` | `bool`    | false   |
| `playerUrl`      | `String`  | CDN URL |
| `initialSource`  | `String?` | null    |
| `autoplay`       | `bool`    | false   |
| `controls`       | `bool`    | true    |
| `volume`         | `double`  | 1.0     |
| `muted`          | `bool`    | false   |

## VhPlyrController Methods

### Playback

```dart
await controller.play();
await controller.pause();
await controller.togglePlay();
await controller.stop();
await controller.restart();
```

### Seeking

```dart
await controller.seek(30);        // Seek to 30s
await controller.forward(10);     // Forward 10s
await controller.rewind(10);      // Rewind 10s
```

### Volume

```dart
await controller.setVolume(0.5);   // 50%
await controller.setMuted(true);
await controller.toggleMute();
final volume = await controller.getVolume();
```

### Quality

```dart
await controller.setQuality(720);  // 720p
await controller.setQuality(0);    // Auto
final qualities = await controller.getQualities();
```

### Source

```dart
await controller.loadSource('https://...m3u8', autoplay: true);
final url = await controller.getSource();
```

### State

```dart
final state = await controller.getState();
final time = await controller.getCurrentTime();
final duration = await controller.getDuration();

// Sync state
print(controller.state.isPlaying);
print(controller.state.currentTime);
print(controller.state.isLive);
```

## Event Streams

```dart
controller.onEvent.listen((event) => ...);    // All events
controller.onReady.listen((_) => ...);
controller.onPlay.listen((_) => ...);
controller.onPause.listen((_) => ...);
controller.onEnded.listen((_) => ...);
controller.onTimeUpdate.listen((e) => ...);
controller.onProgress.listen((e) => ...);
controller.onSeeking.listen((_) => ...);
controller.onSeeked.listen((_) => ...);
controller.onVolumeChange.listen((e) => ...);
controller.onFullscreenChange.listen((e) => ...);
controller.onQualityChange.listen((e) => ...);
controller.onError.listen((error) => ...);
```

## VhPlyrState

```dart
VhPlyrState(
  isReady: bool,
  isPlaying: bool,
  isPaused: bool,
  isStopped: bool,
  isEnded: bool,
  isSeeking: bool,
  isLive: bool,
  isFullscreen: bool,
  currentTime: double,
  duration: double,
  volume: double,
  muted: bool,
  speed: double,
  quality: int,
  buffered: double,
)

// Helper
state.progress  // 0-100 percentage
```

## VhPlyrControls Widget

Optional overlay controls widget:

```dart
Stack(
  children: [
    VhPlyr(controller: controller, ...),
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: VhPlyrControls(
        controller: controller,
        showSeekBar: true,
        showTime: true,
        showFullscreen: true,
      ),
    ),
  ],
)
```
