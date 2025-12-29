# VhPlyr Mobile Demo

Demo app cho VhPlyr - tương tự phiên bản web `demo.html`.

## Tính năng

- 🎬 **Video Player** - Phát HLS streams qua WebView
- 🎛️ **Điều khiển đầy đủ** - Play, Pause, Stop, Seek, Volume, Mute, Fullscreen
- 📊 **Hiển thị trạng thái** - Thời gian hiện tại, tổng thời lượng, trạng thái player
- 🔗 **URL Input** - Nhập URL stream HLS (m3u8) tuỳ ý
- 📝 **Console Log** - Xem các event và action trong thời gian thực

## Chạy Demo

```bash
cd mobile/example
flutter pub get
flutter run
```

## Screenshots

| Feature       | Description                               |
| ------------- | ----------------------------------------- |
| Player        | Phát video HLS qua Plyr.io trong WebView  |
| Controls      | Các nút điều khiển tương tự demo.html     |
| State Display | Hiển thị thời gian và trạng thái realtime |
| Console       | Log các action và event                   |

## Tham khảo

- [demo.html](../../demo.html) - Phiên bản Web demo
- [VhPlyr API](../../docs/web-api.md) - Tài liệu API
