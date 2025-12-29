# VhPlyr - VUIHOC Player

Giải pháp live streaming dự phòng cho vuihoc.vn sử dụng Plyr.io + HLS.js.

## 📁 Cấu trúc Project

```
VhPlayer/
├── web/                    # Web player (host trên CDN)
│   ├── index.html         # Main player page
│   ├── bridge.js          # VhPlyr JavaScript API
│   └── styles.css         # Custom VUIHOC styling
├── mobile/                 # Flutter package
│   └── lib/
│       ├── mobile.dart           # Barrel export
│       ├── vh_plyr.dart          # Widget + Controls
│       ├── vh_plyr_controller.dart  # Controller
│       └── vh_plyr_state.dart    # State models
└── docs/                   # Documentation
```

## 🚀 Quick Start

### Web Integration (iframe)

```html
<iframe 
  src="https://cdn.vuihoc.vn/player/index.html?url=YOUR_HLS_URL"
  width="100%" 
  style="aspect-ratio: 16/9; border: none;"
  allowfullscreen
></iframe>

<script>
// Control via postMessage
const player = document.querySelector('iframe');
player.contentWindow.postMessage({ action: 'play' }, '*');
player.contentWindow.postMessage({ action: 'pause' }, '*');
player.contentWindow.postMessage({ action: 'seek', args: [30] }, '*');
</script>
```

### Mobile Integration (Flutter)

```dart
import 'package:mobile/mobile.dart';

final controller = VhPlyrController();

// Widget (default 16:9 aspect ratio)
VhPlyr(
  controller: controller,
  options: VhPlyrOptions(
    playerUrl: 'https://cdn.vuihoc.vn/player/index.html',
    initialSource: 'https://example.com/live.m3u8',
    autoplay: true,
  ),
)

// Control
await controller.play();
await controller.pause();
await controller.seek(30);
await controller.setVolume(0.5);

// Events
controller.onTimeUpdate.listen((e) {
  print('Time: ${e.data['currentTime']}');
});
```

## 📖 API Reference

| Method               | Description             |
| -------------------- | ----------------------- |
| `play()`             | Start playback          |
| `pause()`            | Pause playback          |
| `stop()`             | Stop and reset          |
| `seek(seconds)`      | Seek to position        |
| `setVolume(0-1)`     | Set volume              |
| `setMuted(bool)`     | Mute/unmute             |
| `setSpeed(rate)`     | Set playback rate       |
| `setQuality(height)` | Set quality (e.g., 720) |
| `loadSource(url)`    | Load new HLS source     |
| `enterFullscreen()`  | Enter fullscreen        |
| `getState()`         | Get current state       |

## 🎯 Events

| Event                | Description        |
| -------------------- | ------------------ |
| `onReady`            | Player initialized |
| `onPlay`             | Playback started   |
| `onPause`            | Playback paused    |
| `onEnded`            | Playback ended     |
| `onTimeUpdate`       | Time changed       |
| `onError`            | Error occurred     |
| `onQualityChange`    | Quality changed    |
| `onFullscreenChange` | Fullscreen toggled |

## 🔧 Test Stream

```
https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
```

## 📄 See Also

- [Web JavaScript API](./web-api.md)
- [Mobile Flutter Package](./mobile-api.md)
