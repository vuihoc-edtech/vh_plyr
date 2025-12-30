# VhPlyr - VUIHOC Web Player

Trình phát video HLS được xây dựng trên [Plyr](https://plyr.io/) và [HLS.js](https://github.com/video-dev/hls.js/), hỗ trợ nhúng cross-domain an toàn.

---

## 🚀 Hướng Dẫn Tích Hợp (Đơn Giản Nhất)

Để tích hợp player từ `player.vuihoc.vn` vào `vuihoc.vn`, bạn chỉ cần làm theo 2 bước:

### Bước 1: Cấu hình Server (Deploy)

Trên server `player.vuihoc.vn`, thêm header để cho phép `vuihoc.vn` nhúng iframe:

```nginx
# Nginx Config
add_header Content-Security-Policy "frame-ancestors https://*.vuihoc.vn";
add_header X-Frame-Options "ALLOW-FROM https://vuihoc.vn";
```

### Bước 2: Nhúng vào Web

Sử dụng SDK `client-sdk.js` để nhúng và điều khiển player dễ dàng:

```html
<!-- 1. Nhúng Iframe -->
<iframe 
    id="vh-player"
    src="https://player.vuihoc.vn/"
    width="100%" height="480" frameborder="0" allowfullscreen>
</iframe>

<!-- 2. Tải SDK -->
<script src="https://player.vuihoc.vn/client-sdk.js"></script>

<!-- 3. Điều khiển -->
<script>
    // Kết nối với player
    const player = new VhPlyrClient('vh-player', 'https://player.vuihoc.vn');

    // Lắng nghe sự kiện
    player.on('ready', () => console.log('Player sẵn sàng!'));
    
    // Điều khiển video
    function playVideo() {
        player.loadSource('https://example.com/video.m3u8');
        player.play();
    }
</script>
```

---

## 📖 SDK Reference

Tất cả các lệnh đều trả về **Promise** (bất đồng bộ).

### Điều khiển

```javascript
player.play();              // Phát
player.pause();             // Tạm dừng
player.togglePlay();        // Bật/Tắt
player.seek(30);            // Đến giây 30
player.setVolume(0.5);      // Âm lượng 50%
player.setMuted(true);      // Tắt tiếng
player.toggleFullscreen();  // Toàn màn hình
```

### Lấy thông tin

```javascript
const state = await player.getState();
const time = await player.getCurrentTime();
const duration = await player.getDuration();
```

### Sự kiện (Events)

```javascript
player.on('ready', (data) => {});
player.on('play', (data) => {});
player.on('pause', (data) => {});
player.on('ended', (data) => {});
player.on('timeUpdate', (data) => {}); // data.currentTime
player.on('error', (err) => console.error(err));
```

---

## 📁 File Cần Deploy
Chỉ cần deploy 3 file này lên `player.vuihoc.vn`:
1. `index.html`
2. `bridge.js`
3. `styles.css`
4. `client-sdk.js` (Để client tải về dùng)

---
© 2024 VUIHOC
