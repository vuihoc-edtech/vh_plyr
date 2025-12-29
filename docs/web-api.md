# VhPlyr Web API

JavaScript API cho điều khiển player từ web (postMessage) và mobile (JS evaluate).

## Global Object

```javascript
window.VhPlyr
```

## Playback Controls

```javascript
VhPlyr.play();              // Start playback
VhPlyr.pause();             // Pause
VhPlyr.togglePlay();        // Toggle play/pause
VhPlyr.stop();              // Stop and reset to 0
VhPlyr.restart();           // Restart from beginning
```

## Seeking

```javascript
VhPlyr.seek(30);            // Seek to 30 seconds
VhPlyr.forward(10);         // Forward 10 seconds
VhPlyr.rewind(10);          // Rewind 10 seconds
```

## Volume

```javascript
VhPlyr.setVolume(0.5);      // Set volume 50%
VhPlyr.getVolume();         // Returns 0-1
VhPlyr.setMuted(true);      // Mute
VhPlyr.isMuted();           // Returns boolean
```

## Speed

```javascript
VhPlyr.setSpeed(1.5);       // 1.5x speed
VhPlyr.getSpeed();          // Returns current speed
```

## Quality

```javascript
VhPlyr.setQuality(720);     // Set to 720p
VhPlyr.setQuality(0);       // Set to Auto
VhPlyr.getQuality();        // Returns current height (e.g., 720)
VhPlyr.getQualities();      // Returns array of quality levels
```

## Source

```javascript
VhPlyr.loadSource('https://example.com/stream.m3u8', true);  // url, autoplay
VhPlyr.getSource();         // Returns current URL
```

## Fullscreen

```javascript
VhPlyr.enterFullscreen();
VhPlyr.exitFullscreen();
VhPlyr.toggleFullscreen();
VhPlyr.isFullscreen();      // Returns boolean
```

## State

```javascript
VhPlyr.getState();          // JSON string with full state
VhPlyr.getCurrentTime();    // Current position in seconds
VhPlyr.getDuration();       // Total duration
VhPlyr.getBuffered();       // Buffered percentage
VhPlyr.isPlaying();         // Boolean
VhPlyr.isPaused();          // Boolean
VhPlyr.isLive();            // Boolean - is live stream
VhPlyr.isReady();           // Boolean - player ready
```

## iframe postMessage

```javascript
const iframe = document.querySelector('iframe');

// Send command
iframe.contentWindow.postMessage({
  action: 'play',
  args: [],
  requestId: 'unique-id'
}, '*');

// Receive response
window.addEventListener('message', (event) => {
  if (event.data.type === 'VhPlyrResponse') {
    console.log(event.data.action, event.data.result);
  }
});
```

## Event Callbacks

Events tự động gửi qua `flutter_inappwebview.callHandler('VhPlyrEvent', payload)`:

```javascript
{
  event: 'onTimeUpdate',
  data: { currentTime: 30.5, duration: 120, percentage: 25.4 },
  timestamp: 1703849123456
}
```

| Event                | Data                                    |
| -------------------- | --------------------------------------- |
| `onReady`            | `{ duration, isLive }`                  |
| `onPlay`             | `{ currentTime }`                       |
| `onPause`            | `{ currentTime }`                       |
| `onEnded`            | `{}`                                    |
| `onTimeUpdate`       | `{ currentTime, duration, percentage }` |
| `onProgress`         | `{ buffered }`                          |
| `onSeeking`          | `{ currentTime }`                       |
| `onSeeked`           | `{ currentTime }`                       |
| `onVolumeChange`     | `{ volume, muted }`                     |
| `onFullscreenChange` | `{ isFullscreen }`                      |
| `onQualityChange`    | `{ quality }`                           |
| `onError`            | `{ message, type?, fatal? }`            |
