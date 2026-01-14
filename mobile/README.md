# VhPlyr - VUIHOC Mobile Player

Flutter package để phát video HLS trong ứng dụng di động, sử dụng [Plyr.io](https://plyr.io/) và [HLS.js](https://github.com/video-dev/hls.js/) qua WebView.

---

## 🚀 Hướng Dẫn Tích Hợp (Đơn Giản Nhất)

### Bước 1: Thêm dependency

```yaml
# pubspec.yaml
dependencies:
  plyr:
    path: ../path/to/vh_plyr/mobile
```

### Bước 2: Sử dụng widget

```dart
import 'package:plyr/plyr.dart';

// 1. Tạo controller
final controller = VhPlyrController();

// 2. Sử dụng widget
VhPlyr(
  controller: controller,
  options: VhPlyrOptions(
    initialSource: 'https://example.com/video.m3u8',
  ),
)

// 3. Điều khiển video
controller.play();
controller.pause();
controller.seek(30);
```

---

## 📖 API Reference

### Widget chính

```dart
VhPlyr(
  controller: controller,
  options: VhPlyrOptions(
    playerUrl: 'https://vuihoc-edtech.github.io/vh_plyr/',  // URL player web
    initialSource: 'https://example.com/video.m3u8',         // Video ban đầu
    autoplay: false,    // Tự động phát
    controls: true,     // Hiển thị controls
    fullscreen: true,   // Cho phép fullscreen
    volume: 1.0,        // Âm lượng (0-1)
    muted: false,       // Tắt tiếng
    debug: false,       // Bật debug log
  ),
)
```

### Options presets

```dart
// Preview mode - tắt tiếng, tự phát, không controls
VhPlyrOptions.preview(initialSource: 'https://...')

// Full mode - đầy đủ tính năng
VhPlyrOptions.fullMode(initialSource: 'https://...')

// Local assets - dùng player bundle offline
VhPlyrOptions.local(initialSource: 'https://...')
```

---

## 🎮 Điều Khiển (Controller)

### Phát & Dừng

```dart
controller.play();              // Phát
controller.pause();             // Tạm dừng
controller.togglePlay();        // Bật/Tắt
controller.stop();              // Dừng và reset
controller.restart();           // Phát lại từ đầu
```

### Tua & Seek

```dart
controller.seek(30);            // Đến giây 30
controller.forward(10);         // Tua tới 10 giây
controller.rewind(10);          // Tua lùi 10 giây
```

### Âm lượng

```dart
controller.setVolume(0.5);      // Âm lượng 50%
controller.setMuted(true);      // Tắt tiếng
controller.toggleMute();        // Bật/Tắt tiếng
```

### Tốc độ & Chất lượng

```dart
controller.setSpeed(1.5);       // Tốc độ 1.5x
controller.setQuality(720);     // Chất lượng 720p (0 = auto)
```

### Fullscreen

```dart
controller.enterFullscreen();
controller.exitFullscreen();
controller.toggleFullscreen();
```

### Source

```dart
controller.loadSource('https://new-video.m3u8', autoplay: true);
```

---

## 📊 Lấy Thông Tin (async)

```dart
final state = await controller.getState();       // Toàn bộ trạng thái
final time = await controller.getCurrentTime();   // Thời gian hiện tại
final duration = await controller.getDuration();  // Tổng thời lượng
final volume = await controller.getVolume();      // Âm lượng
final speed = await controller.getSpeed();        // Tốc độ phát
```

---

## 🎯 Sự Kiện (Events)

### Lắng nghe stream

```dart
// Cách 1: Stream riêng cho từng event
controller.onReady.listen((_) => print('Player sẵn sàng!'));
controller.onPlay.listen((_) => print('Đang phát'));
controller.onPause.listen((_) => print('Tạm dừng'));
controller.onEnded.listen((_) => print('Kết thúc'));
controller.onTimeUpdate.listen((event) {
  print('Thời gian: ${event.data['currentTime']}s');
});
controller.onError.listen((error) => print('Lỗi: $error'));

// Cách 2: Stream chung cho tất cả events
controller.onEvent.listen((event) {
  switch (event.type) {
    case VhPlyrEventType.ready: ...
    case VhPlyrEventType.play: ...
    case VhPlyrEventType.pause: ...
    case VhPlyrEventType.ended: ...
    case VhPlyrEventType.timeUpdate: ...
    case VhPlyrEventType.progress: ...
    case VhPlyrEventType.seeking: ...
    case VhPlyrEventType.seeked: ...
    case VhPlyrEventType.volumeChange: ...
    case VhPlyrEventType.qualityChange: ...
    case VhPlyrEventType.error: ...
  }
});
```

### Sử dụng state với ChangeNotifier

```dart
// Controller extends ChangeNotifier
ListenableBuilder(
  listenable: controller,
  builder: (context, _) {
    final state = controller.state;
    return Text('${state.currentTime} / ${state.duration}');
  },
)
```

---

## 📋 VhPlyrState

Các thuộc tính trong state:

| Property       | Type     | Mô tả                     |
| -------------- | -------- | ------------------------- |
| `isReady`      | `bool`   | Player đã sẵn sàng        |
| `isPlaying`    | `bool`   | Đang phát                 |
| `isPaused`     | `bool`   | Đang tạm dừng             |
| `isEnded`      | `bool`   | Đã kết thúc               |
| `isLive`       | `bool`   | Là livestream             |
| `isFullscreen` | `bool`   | Đang fullscreen           |
| `isSeeking`    | `bool`   | Đang tua                  |
| `currentTime`  | `double` | Thời gian hiện tại (giây) |
| `duration`     | `double` | Tổng thời lượng (giây)    |
| `buffered`     | `double` | % đã buffer               |
| `volume`       | `double` | Âm lượng (0-1)            |
| `muted`        | `bool`   | Đang tắt tiếng            |
| `speed`        | `double` | Tốc độ phát               |
| `quality`      | `int`    | Chất lượng hiện tại       |
| `progress`     | `double` | % tiến trình (0-100)      |

---

## 🧩 Widgets Bổ Trợ

### VhPlyrControls

Widget controls đơn giản để overlay bên ngoài WebView:

```dart
VhPlyrControls(
  controller: controller,
  showSeekBar: true,
  showVolumeSlider: true,
  onFullscreenPressed: () => controller.toggleFullscreen(),
)
```

### VhPlyrOverlay

Overlay controls đẹp với animation:

```dart
VhPlyrOverlay(
  controller: controller,
  onFullscreenPressed: () => ...,
)
```

### VhPlyrVisibilityWrapper

Tự động pause khi player không hiển thị:

```dart
VhPlyrVisibilityWrapper(
  controller: controller,
  child: VhPlyr(controller: controller, options: ...),
)
```

### VhPlyrManager

Quản lý nhiều player instances (preview + fullscreen):

```dart
// Singleton manager
VhPlyrManager().preload(
  url: 'https://example.com/video.m3u8',
  onReady: (controller) => print('Ready!'),
);
```

---

## 📁 Cấu Trúc Package

```
mobile/
├── lib/
│   ├── plyr.dart              # Export file chính
│   ├── vh_plyr.dart             # Widget VhPlyr
│   ├── vh_plyr_controller.dart  # Controller API
│   ├── vh_plyr_state.dart       # State & Options
│   ├── vh_plyr_overlay.dart     # Overlay controls
│   ├── vh_plyr_manager.dart     # Multi-player manager
│   └── vh_plyr_visibility_wrapper.dart
└── example/                     # Demo app
```

---

© 2024 VUIHOC
