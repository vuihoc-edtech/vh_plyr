/// VhPlyr Visibility Wrapper - Auto pause/play based on visibility
library;

import 'package:flutter/material.dart';

import 'vh_plyr.dart';
import 'vh_plyr_controller.dart';
import 'vh_plyr_manager.dart';
import 'vh_plyr_state.dart';

/// Widget that auto-manages visibility-based pause/play
///
/// Wraps a [VhPlyr] widget and automatically:
/// - Registers with [VhPlyrManager] on mount
/// - Sets as active when visible
/// - Pauses when invisible (scrolled away, tab changed, etc.)
/// - Unregisters on dispose
///
/// Example usage:
/// ```dart
/// VhPlyrVisibilityWrapper(
///   playerId: 'preview_tab_0',
///   controller: controller,
///   streamUrl: 'https://example.com/live.m3u8',
///   child: VhPlyr(
///     controller: controller,
///     options: VhPlyrOptions.preview(),
///   ),
/// )
/// ```
class VhPlyrVisibilityWrapper extends StatefulWidget {
  /// Unique identifier for this player instance
  final String playerId;

  /// Controller for the wrapped VhPlyr
  final VhPlyrController controller;

  /// The VhPlyr widget to wrap
  final Widget child;

  /// Stream URL (stored in manager for reference)
  final String? streamUrl;

  /// Whether to auto-play when becoming visible
  /// Set to false if you want manual control
  final bool autoPlayOnVisible;

  /// Whether to auto-pause when becoming invisible
  final bool autoPauseOnInvisible;

  const VhPlyrVisibilityWrapper({
    super.key,
    required this.playerId,
    required this.controller,
    required this.child,
    this.streamUrl,
    this.autoPlayOnVisible = true,
    this.autoPauseOnInvisible = true,
  });

  @override
  State<VhPlyrVisibilityWrapper> createState() =>
      _VhPlyrVisibilityWrapperState();
}

class _VhPlyrVisibilityWrapperState extends State<VhPlyrVisibilityWrapper>
    with RouteAware, WidgetsBindingObserver {
  RouteObserver<ModalRoute<void>>? _routeObserver;
  final bool _isVisible = true;
  bool _isRouteActive = true;

  @override
  void initState() {
    super.initState();

    // Register with manager
    VhPlyrManager.instance.register(
      widget.playerId,
      widget.controller,
      streamUrl: widget.streamUrl,
    );

    // Listen to app lifecycle
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Try to subscribe to route observer
    final observer = _findRouteObserver();
    if (observer != null && observer != _routeObserver) {
      _routeObserver?.unsubscribe(this);
      _routeObserver = observer;
      _routeObserver?.subscribe(this, ModalRoute.of(context)!);
    }
  }

  RouteObserver<ModalRoute<void>>? _findRouteObserver() {
    try {
      return Navigator.of(context).widget.observers
          .whereType<RouteObserver<ModalRoute<void>>>()
          .firstOrNull;
    } catch (_) {
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App going to background
      _onBecomeInvisible();
    } else if (state == AppLifecycleState.resumed) {
      // App coming back
      if (_isVisible && _isRouteActive) {
        _onBecomeVisible();
      }
    }
  }

  // RouteAware callbacks
  @override
  void didPush() {
    // Route was pushed onto navigator
    _isRouteActive = true;
    _onBecomeVisible();
  }

  @override
  void didPushNext() {
    // Another route was pushed on top of this one
    _isRouteActive = false;
    _onBecomeInvisible();
  }

  @override
  void didPop() {
    _isRouteActive = false;
  }

  @override
  void didPopNext() {
    // Returned to this route
    _isRouteActive = true;
    _onBecomeVisible();
  }

  void _onBecomeVisible() {
    if (!_isVisible) return;
    if (!_isRouteActive) return;
    if (VhPlyrManager.instance.isFullModeActive) return;

    if (widget.autoPlayOnVisible) {
      VhPlyrManager.instance.setActive(widget.playerId);
    }
  }

  void _onBecomeInvisible() {
    if (widget.autoPauseOnInvisible) {
      VhPlyrManager.instance.pause(widget.playerId);
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    VhPlyrManager.instance.unregister(widget.playerId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Preset VhPlyr widget for preview mode (muted, autoplay)
///
/// Convenience widget that combines [VhPlyr] with [VhPlyrVisibilityWrapper]
/// and preview-specific options.
class VhPlyrPreview extends StatelessWidget {
  /// Unique identifier for this preview player
  final String playerId;

  /// Controller (will be created if not provided)
  final VhPlyrController controller;

  /// Stream URL to play
  final String streamUrl;

  /// Aspect ratio (default 16:9)
  final double aspectRatio;

  /// Called when ready
  final VoidCallback? onReady;

  /// Called on error
  final void Function(String)? onError;

  /// Called when user taps to enter full mode
  final VoidCallback? onTapFullMode;

  /// Use local assets instead of remote URL
  final bool useLocalAssets;

  const VhPlyrPreview({
    super.key,
    required this.playerId,
    required this.controller,
    required this.streamUrl,
    this.aspectRatio = 16 / 9,
    this.onReady,
    this.onError,
    this.onTapFullMode,
    this.useLocalAssets = false,
  });

  @override
  Widget build(BuildContext context) {
    return VhPlyrVisibilityWrapper(
      playerId: playerId,
      controller: controller,
      streamUrl: streamUrl,
      child: GestureDetector(
        onTap: onTapFullMode,
        child: Stack(
          children: [
            VhPlyr(
              controller: controller,
              aspectRatio: aspectRatio,
              options: VhPlyrOptions(
                useLocalAssets: useLocalAssets,
                initialSource: streamUrl,
                autoplay: true,
                muted: true,
                controls: false,
              ),
              onReady: onReady,
              onError: onError,
            ),
            // Tap overlay to enter full mode
            if (onTapFullMode != null)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white70,
                    size: 48,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
