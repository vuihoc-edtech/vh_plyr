library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'vh_plyr_controller.dart';
import 'vh_plyr_state.dart';

/// VhPlyr - Video player widget using Plyr.io via WebView
///
/// Example usage:
/// ```dart
/// final controller = VhPlyrController();
///
/// VhPlyr(
///   controller: controller,
///   options: VhPlyrOptions(
///     playerUrl: 'https://cdn.vuihoc.vn/player/index.html',
///     initialSource: 'https://example.com/stream.m3u8',
///   ),
/// )
/// ```
class VhPlyr extends StatefulWidget {
  /// Controller to interact with the player
  final VhPlyrController controller;

  /// Player configuration options
  final VhPlyrOptions options;

  /// Aspect ratio of the player (default: 16/9)
  final double aspectRatio;

  /// Whether to use aspect ratio constraint
  final bool useAspectRatio;

  /// Background color while loading
  final Color backgroundColor;

  /// Widget to show while loading
  final Widget? placeholder;

  /// Widget to show on error
  final Widget Function(String error)? errorBuilder;

  /// Called when player is ready
  final VoidCallback? onReady;

  /// Called on playback errors
  final void Function(String error)? onError;

  const VhPlyr({
    super.key,
    required this.controller,
    this.options = const VhPlyrOptions(),
    this.aspectRatio = 16 / 9,
    this.useAspectRatio = true,
    this.backgroundColor = Colors.black,
    this.placeholder,
    this.errorBuilder,
    this.onReady,
    this.onError,
  });

  @override
  State<VhPlyr> createState() => _VhPlyrState();
}

class _VhPlyrState extends State<VhPlyr> {
  bool _isLoading = true;
  String? _error;
  
  // Stream subscriptions to cancel on dispose
  StreamSubscription<VhPlyrEvent>? _readySubscription;
  StreamSubscription<String>? _errorSubscription;

  // Timer for auto-dismissing temporary errors
  Timer? _errorDismissTimer;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _readySubscription = widget.controller.onReady.take(1).listen(_onReady);
    _errorSubscription = widget.controller.onError.listen(_onError);
  }

  void _onReady(_) {
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onReady?.call();
    }
  }

  void _onError(error) {
    if (mounted) {
      // Ignore temporary network errors that HLS.js auto-recovers from
      if (_isRecoverableError(error)) {
        // Show error briefly then auto-dismiss
        setState(() => _error = error);
        _errorDismissTimer?.cancel();
        _errorDismissTimer = Timer(const Duration(seconds: 3), () {
          if (mounted && _error == error) {
            setState(() => _error = null);
          }
        });
      } else {
        // Fatal error - show permanently until retry
        setState(() => _error = error);
      }
      widget.onError?.call(error);
    }
  }

  /// Check if error is temporary and HLS.js can auto-recover
  bool _isRecoverableError(String error) {
    final recoverable = [
      'net::ERR_FAILED',
      'Network error',
      'Media error',
      'BUFFER_STALLED',
    ];
    return recoverable.any((e) => error.contains(e));
  }

  @override
  Widget build(BuildContext context) {
    Widget player = _buildWebView();

    if (widget.useAspectRatio) {
      player = AspectRatio(aspectRatio: widget.aspectRatio, child: player);
    }

    return player;
  }

  Widget _buildWebView() {
    // Determine how to load the player
    final useLocalAssets = widget.options.useLocalAssets;

    return Stack(
      children: [
        // WebView player
        InAppWebView(
          // Use local assets or remote URL based on options
          initialUrlRequest: useLocalAssets
              ? null // Will use initialData instead
              : URLRequest(url: WebUri(widget.options.buildRemoteUrl())),
          initialFile: useLocalAssets
              ? 'packages/mobile/assets/player/index.html'
              : null,
          initialSettings: InAppWebViewSettings(
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            javaScriptEnabled: true,
            transparentBackground: true,
            supportZoom: false,
            disableHorizontalScroll: true,
            disableVerticalScroll: true,
            allowsBackForwardNavigationGestures: false,
            useShouldOverrideUrlLoading: true,
            useHybridComposition: true,
            // iOS specific
            allowsLinkPreview: false,
            allowsPictureInPictureMediaPlayback: true,
            // Android specific
            useWideViewPort: true,
            loadWithOverviewMode: true,
            builtInZoomControls: false,
            displayZoomControls: false,
          ),
          onConsoleMessage: (controller, consoleMessage) {
            print(consoleMessage);
          },
          onWebViewCreated: (controller) {
            widget.controller.attach(controller);
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onLoadStop: (controller, url) async {
            // If using local assets and has initial source, load it
            if (useLocalAssets && widget.options.initialSource != null) {
              await widget.controller.loadSource(
                widget.options.initialSource!,
                autoplay: widget.options.autoplay,
              );
            }
            // Player ready event will set _isLoading to false
          },
          onReceivedError: (controller, request, error) {
            // Ignore recoverable errors that HLS.js can auto-handle
            // (e.g., segment loading failures, network hiccups)
            if (_isRecoverableError(error.description)) {
              debugPrint(
                '[VhPlyr] Ignoring recoverable error: ${error.description}',
              );
              return;
            }

            // Only show error overlay for fatal errors (like initial page load failure)
            setState(() {
              _error = error.description;
              _isLoading = false;
            });
          },
          shouldOverrideUrlLoading: (controller, action) async {
            // Block external navigation
            return NavigationActionPolicy.CANCEL;
          },
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: widget.backgroundColor,
            child: Center(
              child:
                  widget.placeholder ??
                  const CircularProgressIndicator(
                    color: Colors.deepOrange,
                    strokeWidth: 3
                  ),
            ),
          ),

        // Error overlay
        if (_error != null && !_isLoading)
          Container(
            color: widget.backgroundColor,
            child: Center(
              child:
                  widget.errorBuilder?.call(_error!) ??
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white54,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _retry,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
            ),
          ),
      ],
    );
  }

  void _retry() {
    setState(() {
      _error = null;
      _isLoading = true;
    });
    widget.controller.loadSource(widget.options.initialSource ?? '');
  }

  @override
  void dispose() {
    _errorDismissTimer?.cancel();
    _readySubscription?.cancel();
    _errorSubscription?.cancel();
    widget.controller.detach();
    super.dispose();
  }
}

/// Compact player controls widget
///
/// Use this for custom overlay controls outside of WebView
class VhPlyrControls extends StatelessWidget {
  final VhPlyrController controller;
  final bool showSeekBar;
  final bool showTime;
  final bool showFullscreen;
  final bool showQuality;

  const VhPlyrControls({
    super.key,
    required this.controller,
    this.showSeekBar = true,
    this.showTime = true,
    this.showFullscreen = true,
    this.showQuality = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seek bar
              if (showSeekBar && !state.isLive)
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: const Color(0xFFFF6B35),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFFF6B35),
                  ),
                  child: Slider(
                    value: state.currentTime.clamp(0, state.duration),
                    max: state.duration > 0 ? state.duration : 1,
                    onChanged: (value) => controller.seek(value),
                  ),
                ),

              // Controls row
              Row(
                children: [
                  // Play/Pause
                  IconButton(
                    icon: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: state.isPlaying
                        ? controller.pause
                        : controller.play,
                  ),

                  // Time display
                  if (showTime)
                    Text(
                      state.isLive
                          ? '🔴 LIVE'
                          : '${_formatDuration(state.currentTime)} / ${_formatDuration(state.duration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),

                  const Spacer(),

                  // Fullscreen
                  if (showFullscreen)
                    IconButton(
                      icon: Icon(
                        state.isFullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: controller.toggleFullscreen,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
