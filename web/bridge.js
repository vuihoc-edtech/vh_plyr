/**
 * VhPlyr - VUIHOC Player Bridge API
 * 
 * JavaScript bridge for controlling the player from:
 * - Web: Direct API calls or postMessage (iframe)
 * - Mobile: JS evaluation from WebView
 * 
 * Usage:
 *   VhPlyr.play();
 *   VhPlyr.pause();
 *   VhPlyr.seek(30);
 *   VhPlyr.getState();
 */

(function(window) {
    'use strict';

    // Player instances
    let plyr = null;
    let hls = null;
    let isLive = false;
    let isReady = false;
    let currentQuality = -1;

    // Callback handler for mobile WebView
    const callbacks = {
        onReady: null,
        onPlay: null,
        onPause: null,
        onEnded: null,
        onTimeUpdate: null,
        onProgress: null,
        onError: null,
        onQualityChange: null,
        onFullscreenChange: null,
        onSeeking: null,
        onSeeked: null,
        onVolumeChange: null,
        onWaiting: null,
        onCanPlay: null
    };

    // Emit event to mobile via flutter handler or console
    function emitEvent(eventName, data) {
        const payload = { event: eventName, data: data, timestamp: Date.now() };
        
        // For Flutter InAppWebView
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('VhPlyrEvent', JSON.stringify(payload));
        }
        
        // For standard WebView with JS handler
        if (window.VhPlyrHandler) {
            window.VhPlyrHandler.postMessage(JSON.stringify(payload));
        }
        
        // Console log for debugging
        console.log('[VhPlyr]', eventName, data);
        
        // Call registered callback
        if (callbacks[eventName] && typeof callbacks[eventName] === 'function') {
            callbacks[eventName](data);
        }
    }

    // Setup Plyr event listeners
    function setupEventListeners() {
        if (!plyr) return;

        plyr.on('ready', function() {
            isReady = true;
            emitEvent('onReady', { duration: plyr.duration, isLive: isLive });
        });

        plyr.on('play', function() {
            emitEvent('onPlay', { currentTime: plyr.currentTime });
        });

        plyr.on('pause', function() {
            emitEvent('onPause', { currentTime: plyr.currentTime });
        });

        plyr.on('ended', function() {
            emitEvent('onEnded', {});
        });

        plyr.on('timeupdate', function() {
            emitEvent('onTimeUpdate', {
                currentTime: plyr.currentTime,
                duration: plyr.duration,
                percentage: (plyr.currentTime / plyr.duration) * 100 || 0
            });
        });

        plyr.on('progress', function() {
            emitEvent('onProgress', { buffered: plyr.buffered });
        });

        plyr.on('seeking', function() {
            emitEvent('onSeeking', { currentTime: plyr.currentTime });
        });

        plyr.on('seeked', function() {
            emitEvent('onSeeked', { currentTime: plyr.currentTime });
        });

        plyr.on('volumechange', function() {
            emitEvent('onVolumeChange', { volume: plyr.volume, muted: plyr.muted });
        });

        plyr.on('waiting', function() {
            emitEvent('onWaiting', {});
        });

        plyr.on('canplay', function() {
            emitEvent('onCanPlay', {});
        });

        plyr.on('enterfullscreen', function() {
            emitEvent('onFullscreenChange', { isFullscreen: true });
        });

        plyr.on('exitfullscreen', function() {
            emitEvent('onFullscreenChange', { isFullscreen: false });
        });

        plyr.on('qualitychange', function(event) {
            currentQuality = event.detail.quality;
            emitEvent('onQualityChange', { quality: currentQuality });
        });

        plyr.on('error', function(event) {
            emitEvent('onError', { message: event.detail.plyr.media.error?.message || 'Unknown error' });
        });
    }

    // Setup HLS.js event listeners
    function setupHlsListeners() {
        if (!hls) return;

        hls.on(Hls.Events.ERROR, function(event, data) {
            if (data.fatal) {
                switch (data.type) {
                    case Hls.ErrorTypes.NETWORK_ERROR:
                        emitEvent('onError', { message: 'Network error', type: 'network', fatal: true });
                        hls.startLoad();
                        break;
                    case Hls.ErrorTypes.MEDIA_ERROR:
                        emitEvent('onError', { message: 'Media error', type: 'media', fatal: true });
                        hls.recoverMediaError();
                        break;
                    default:
                        emitEvent('onError', { message: 'Fatal error', type: data.type, fatal: true });
                        break;
                }
            }
        });

        hls.on(Hls.Events.MANIFEST_PARSED, function(event, data) {
            const qualities = hls.levels.map((level, index) => ({
                index: index,
                height: level.height,
                width: level.width,
                bitrate: level.bitrate
            }));
            emitEvent('onManifestParsed', { qualities: qualities, isLive: hls.liveSyncPosition !== undefined });
            isLive = hls.liveSyncPosition !== undefined;
        });
    }

    // Initialize or update quality options for Plyr
    function updateQualityOptions() {
        if (!hls || !plyr) return;

        const availableQualities = hls.levels.map((l) => l.height);
        availableQualities.unshift(0); // Auto quality

        plyr.quality = availableQualities.includes(720) ? 720 : availableQualities[1] || 0;
    }

    // VhPlyr API
    const VhPlyr = {
        // ============ Playback Controls ============
        
        play: function() {
            if (plyr) plyr.play();
        },

        pause: function() {
            if (plyr) plyr.pause();
        },

        togglePlay: function() {
            if (plyr) plyr.togglePlay();
        },

        stop: function() {
            if (plyr) {
                plyr.stop();
                plyr.currentTime = 0;
            }
        },

        restart: function() {
            if (plyr) plyr.restart();
        },

        // ============ Seeking ============

        seek: function(seconds) {
            if (plyr) plyr.currentTime = parseFloat(seconds) || 0;
        },

        forward: function(seconds) {
            if (plyr) plyr.forward(parseFloat(seconds) || 10);
        },

        rewind: function(seconds) {
            if (plyr) plyr.rewind(parseFloat(seconds) || 10);
        },

        // ============ Volume ============

        setVolume: function(level) {
            if (plyr) plyr.volume = Math.max(0, Math.min(1, parseFloat(level) || 0));
        },

        getVolume: function() {
            return plyr ? plyr.volume : 0;
        },

        setMuted: function(muted) {
            if (plyr) plyr.muted = muted === true || muted === 'true';
        },

        isMuted: function() {
            return plyr ? plyr.muted : false;
        },

        // ============ Speed ============

        setSpeed: function(rate) {
            if (plyr) plyr.speed = parseFloat(rate) || 1;
        },

        getSpeed: function() {
            return plyr ? plyr.speed : 1;
        },

        // ============ Quality ============

        setQuality: function(quality) {
            if (hls) {
                const targetQuality = parseInt(quality);
                if (targetQuality === 0 || targetQuality === -1) {
                    hls.currentLevel = -1; // Auto
                } else {
                    const levelIndex = hls.levels.findIndex(l => l.height === targetQuality);
                    if (levelIndex !== -1) hls.currentLevel = levelIndex;
                }
            }
        },

        getQuality: function() {
            if (hls && hls.currentLevel >= 0) {
                return hls.levels[hls.currentLevel]?.height || 0;
            }
            return 0; // Auto
        },

        getQualities: function() {
            if (!hls) return [];
            return hls.levels.map((level, index) => ({
                index: index,
                height: level.height,
                width: level.width,
                bitrate: level.bitrate,
                label: level.height + 'p'
            }));
        },

        // ============ Fullscreen ============

        enterFullscreen: function() {
            if (plyr) plyr.fullscreen.enter();
        },

        exitFullscreen: function() {
            if (plyr) plyr.fullscreen.exit();
        },

        toggleFullscreen: function() {
            if (plyr) plyr.fullscreen.toggle();
        },

        isFullscreen: function() {
            return plyr ? plyr.fullscreen.active : false;
        },

        // ============ Source ============

        loadSource: function(url, autoplay) {
            const video = document.getElementById('player');
            if (!video) {
                emitEvent('onError', { message: 'Video element not found' });
                return;
            }

            // Destroy existing instances
            if (hls) {
                hls.destroy();
                hls = null;
            }

            // Check if HLS
            if (url.includes('.m3u8')) {
                if (Hls.isSupported()) {
                    hls = new Hls({
                        enableWorker: true,
                        lowLatencyMode: true,
                        backBufferLength: 90
                    });
                    
                    hls.loadSource(url);
                    hls.attachMedia(video);
                    setupHlsListeners();
                    
                    hls.on(Hls.Events.MANIFEST_PARSED, function() {
                        // Initialize Plyr after HLS is ready
                        initPlyr(video, autoplay);
                        updateQualityOptions();
                    });
                } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                    // Native HLS support (Safari)
                    video.src = url;
                    initPlyr(video, autoplay);
                } else {
                    emitEvent('onError', { message: 'HLS not supported' });
                }
            } else {
                // Direct video source (MP4, WebM, etc.)
                video.src = url;
                initPlyr(video, autoplay);
            }
        },

        getSource: function() {
            const video = document.getElementById('player');
            return video ? video.src : '';
        },

        // ============ State ============

        getState: function() {
            return JSON.stringify({
                isReady: isReady,
                isPlaying: plyr ? plyr.playing : false,
                isPaused: plyr ? plyr.paused : true,
                isStopped: plyr ? plyr.stopped : true,
                isEnded: plyr ? plyr.ended : false,
                isSeeking: plyr ? plyr.seeking : false,
                isLive: isLive,
                isFullscreen: plyr ? plyr.fullscreen.active : false,
                currentTime: plyr ? plyr.currentTime : 0,
                duration: plyr ? plyr.duration : 0,
                volume: plyr ? plyr.volume : 1,
                muted: plyr ? plyr.muted : false,
                speed: plyr ? plyr.speed : 1,
                quality: currentQuality,
                buffered: plyr ? plyr.buffered : 0
            });
        },

        getCurrentTime: function() {
            return plyr ? plyr.currentTime : 0;
        },

        getDuration: function() {
            return plyr ? plyr.duration : 0;
        },

        getBuffered: function() {
            return plyr ? plyr.buffered : 0;
        },

        isPlaying: function() {
            return plyr ? plyr.playing : false;
        },

        isPaused: function() {
            return plyr ? plyr.paused : true;
        },

        isLive: function() {
            return isLive;
        },

        isReady: function() {
            return isReady;
        },

        // ============ Captions ============

        toggleCaptions: function(show) {
            if (plyr) plyr.toggleCaptions(show);
        },

        // ============ Picture-in-Picture ============

        enterPiP: function() {
            if (plyr && plyr.pip) plyr.pip = true;
        },

        exitPiP: function() {
            if (plyr && plyr.pip) plyr.pip = false;
        },

        // ============ Controls ============

        showControls: function() {
            if (plyr) plyr.toggleControls(true);
        },

        hideControls: function() {
            if (plyr) plyr.toggleControls(false);
        },

        // ============ Callbacks ============

        on: function(eventName, callback) {
            if (callbacks.hasOwnProperty('on' + eventName.charAt(0).toUpperCase() + eventName.slice(1))) {
                callbacks['on' + eventName.charAt(0).toUpperCase() + eventName.slice(1)] = callback;
            } else if (callbacks.hasOwnProperty(eventName)) {
                callbacks[eventName] = callback;
            }
        },

        off: function(eventName) {
            const key = 'on' + eventName.charAt(0).toUpperCase() + eventName.slice(1);
            if (callbacks.hasOwnProperty(key)) {
                callbacks[key] = null;
            }
        },

        // ============ Destroy ============

        destroy: function() {
            if (hls) {
                hls.destroy();
                hls = null;
            }
            if (plyr) {
                plyr.destroy();
                plyr = null;
            }
            isReady = false;
        },

        // ============ Version ============

        getVersion: function() {
            return '1.0.0';
        }
    };

    // Initialize Plyr player
    function initPlyr(video, autoplay) {
        if (plyr) {
            plyr.destroy();
        }

        plyr = new Plyr(video, {
            controls: [
                'play-large',
                'play',
                'progress',
                'current-time',
                'duration',
                'mute',
                'volume',
                'settings',
                'pip',
                'fullscreen'
            ],
            settings: ['quality', 'speed'],
            quality: {
                default: 720,
                options: [1080, 720, 480, 360, 240],
                forced: false,
                onChange: function(quality) {
                    VhPlyr.setQuality(quality);
                }
            },
            speed: {
                selected: 1,
                options: [0.5, 0.75, 1, 1.25, 1.5, 2]
            },
            tooltips: {
                controls: true,
                seek: true
            },
            keyboard: {
                focused: true,
                global: false
            },
            fullscreen: {
                enabled: true,
                fallback: true,
                iosNative: true
            },
            autoplay: autoplay === true || autoplay === 'true',
            invertTime: false,
            toggleInvert: false
        });

        setupEventListeners();
    }

    // Expose to global
    window.VhPlyr = VhPlyr;

})(window);
