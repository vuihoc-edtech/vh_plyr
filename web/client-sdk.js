/**
 * VhPlyr Client SDK
 * 
 * SDK for controlling VhPlyr iframe across domains/subdomains.
 * 
 * Usage:
 *   const player = new VhPlyrClient('iframe-id', 'https://player.vuihoc.vn');
 *   
 *   player.on('ready', (data) => console.log('Ready:', data));
 *   player.play();
 */

class VhPlyrClient {
    /**
     * @param {string|HTMLIFrameElement} iframeOrId - The iframe ID or element
     * @param {string} targetOrigin - The origin of the player (e.g., 'https://player.vuihoc.vn')
     */
    constructor(iframeOrId, targetOrigin = '*') {
        this.iframe = typeof iframeOrId === 'string' 
            ? document.getElementById(iframeOrId) 
            : iframeOrId;
            
        if (!this.iframe) {
            console.error('[VhPlyrClient] Iframe not found');
            return;
        }

        this.targetOrigin = targetOrigin;
        this.callbacks = {};
        this.requests = {};
        this.requestIdCounter = 0;

        this._setupMessageListener();
    }

    /**
     * Listen for messages from the player
     */
    _setupMessageListener() {
        window.addEventListener('message', (event) => {
            // Check origin if strictly specified
            if (this.targetOrigin !== '*' && event.origin !== this.targetOrigin) {
                return;
            }

            const data = event.data;
            if (!data) return;

            // Handle Response (Method calls)
            if (data.type === 'VhPlyrResponse') {
                const { requestId, result, error } = data;
                if (this.requests[requestId]) {
                    if (error) {
                        this.requests[requestId].reject(error);
                    } else {
                        this.requests[requestId].resolve(result);
                    }
                    delete this.requests[requestId];
                }
            }
            
            // Handle Events (e.g., onPlay, onTimeUpdate)
            else if (data.event) {
                this._emit(data.event, data.data);
            }
        });
    }

    /**
     * Emit event to local listeners
     */
    _emit(eventName, data) {
        if (this.callbacks[eventName]) {
            this.callbacks[eventName].forEach(cb => cb(data));
        }
        
        // Also emit 'all' event
        if (this.callbacks['*']) {
            this.callbacks['*'].forEach(cb => cb(eventName, data));
        }
    }

    /**
     * Send command to player
     */
    _send(action, args = []) {
        if (!this.iframe || !this.iframe.contentWindow) return Promise.reject('Iframe not ready');

        const requestId = this.requestIdCounter++;
        
        return new Promise((resolve, reject) => {
            this.requests[requestId] = { resolve, reject };

            // Timeout after 5 seconds
            setTimeout(() => {
                if (this.requests[requestId]) {
                    delete this.requests[requestId];
                    reject('Timeout');
                }
            }, 5000);

            this.iframe.contentWindow.postMessage({
                action: action,
                args: args,
                requestId: requestId
            }, this.targetOrigin);
        });
    }

    // ============ Public API ============

    /**
     * Subscribe to player events
     * @param {string} eventName - Event name (e.g., 'play', 'timeUpdate')
     * @param {function} callback - Function to call
     */
    on(eventName, callback) {
        if (!this.callbacks[eventName]) {
            this.callbacks[eventName] = [];
        }
        this.callbacks[eventName].push(callback);
    }

    /**
     * Unsubscribe from events
     */
    off(eventName, callback) {
        if (!this.callbacks[eventName]) return;
        if (callback) {
            this.callbacks[eventName] = this.callbacks[eventName].filter(cb => cb !== callback);
        } else {
            delete this.callbacks[eventName];
        }
    }

    // ============ Playback Control ============

    play() { return this._send('play'); }
    pause() { return this._send('pause'); }
    togglePlay() { return this._send('togglePlay'); }
    stop() { return this._send('stop'); }
    restart() { return this._send('restart'); }
    
    /**
     * @param {number} seconds 
     */
    seek(seconds) { return this._send('seek', [seconds]); }
    forward(seconds) { return this._send('forward', [seconds]); }
    rewind(seconds) { return this._send('rewind', [seconds]); }

    // ============ Volume ============
    
    /**
     * @param {number} level 0.0 to 1.0
     */
    setVolume(level) { return this._send('setVolume', [level]); }
    setMuted(muted) { return this._send('setMuted', [muted]); }

    // ============ Quality & Speed ============

    setQuality(quality) { return this._send('setQuality', [quality]); }
    setSpeed(rate) { return this._send('setSpeed', [rate]); }

    // ============ Source ============

    loadSource(url, autoplay = true) { return this._send('loadSource', [url, autoplay]); }

    // ============ Display ============

    enterFullscreen() { return this._send('enterFullscreen'); }
    exitFullscreen() { return this._send('exitFullscreen'); }
    toggleFullscreen() { return this._send('toggleFullscreen'); }
    
    toggleCaptions(show) { return this._send('toggleCaptions', [show]); }
    enterPiP() { return this._send('enterPiP'); }
    exitPiP() { return this._send('exitPiP'); }

    // ============ Getters (Async) ============
    // Note: These methods return Promises because they need to fetch data from the iframe

    async getState() { return this._send('getState').then(JSON.parse); }
    async getCurrentTime() { return this._send('getCurrentTime'); }
    async getDuration() { return this._send('getDuration'); }
    async getVolume() { return this._send('getVolume'); }
    async isMuted() { return this._send('isMuted'); }
    async isPlaying() { return this._send('isPlaying'); }
    async isPaused() { return this._send('isPaused'); }
}

// Export for module systems if needed
if (typeof module !== 'undefined' && module.exports) {
    module.exports = VhPlyrClient;
}
