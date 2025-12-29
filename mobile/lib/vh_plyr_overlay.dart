/// VhPlyr Overlay - Global overlay for seamless video transitions
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'vh_plyr.dart';
import 'vh_plyr_controller.dart';
import 'vh_plyr_state.dart';

/// Mode of the overlay player
enum VhPlyrOverlayMode {
  /// Player is hidden
  hidden,

  /// Player is in preview mode (small, muted)
  preview,

  /// Player is in full mode (fullscreen, unmuted)
  fullMode,
}

/// Controller for managing the overlay player state
///
/// Access via [VhPlyrOverlayScope.of(context)]
class VhPlyrOverlayController extends ChangeNotifier {
  VhPlyrOverlayController();

  /// The player controller (single instance)
  final VhPlyrController playerController = VhPlyrController();

  /// Current mode
  VhPlyrOverlayMode _mode = VhPlyrOverlayMode.hidden;
  VhPlyrOverlayMode get mode => _mode;

  /// Current stream URL
  String? _streamUrl;
  String? get streamUrl => _streamUrl;

  /// Target bounds for preview mode
  Rect? _previewBounds;
  Rect? get previewBounds => _previewBounds;

  /// GlobalKey of the target widget for preview positioning
  GlobalKey? _targetKey;

  /// Whether player is ready
  bool _isReady = false;
  bool get isReady => _isReady;

  /// Use local assets
  bool useLocalAssets = false;

  /// Lesson info for full mode display
  String? lessonTitle;
  String? teacherName;

  /// Show player in preview mode at the position of [targetKey]
  ///
  /// The player will be muted and positioned to match the target widget.
  void showPreview({
    required GlobalKey targetKey,
    required String streamUrl,
    String? lessonTitle,
    String? teacherName,
  }) {
    _targetKey = targetKey;
    _streamUrl = streamUrl;
    this.lessonTitle = lessonTitle;
    this.teacherName = teacherName;

    // Get bounds from target key
    _updatePreviewBounds();

    if (_mode == VhPlyrOverlayMode.hidden) {
      // First time showing - load the stream
      _mode = VhPlyrOverlayMode.preview;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        playerController.loadSource(streamUrl, autoplay: true);
        playerController.setMuted(true);
      });
    } else if (_mode == VhPlyrOverlayMode.preview) {
      // Already in preview - just update position
      _mode = VhPlyrOverlayMode.preview;
    }

    _safeNotify();
  }

  /// Update preview bounds from target key
  void _updatePreviewBounds() {
    if (_targetKey?.currentContext != null) {
      final renderBox =
          _targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        _previewBounds = Rect.fromLTWH(
          position.dx,
          position.dy,
          renderBox.size.width,
          renderBox.size.height,
        );
      }
    }
  }

  /// Expand to full mode with animation
  ///
  /// Player will be unmuted and expanded to fullscreen.
  void expandToFullMode() {
    if (_mode == VhPlyrOverlayMode.fullMode) return;

    debugPrint('[VhPlyrOverlay] Expanding to full mode');
    _mode = VhPlyrOverlayMode.fullMode;

    // Unmute for full mode
    playerController.setMuted(false);
    playerController.setVolume(1.0);

    _safeNotify();
  }

  /// Collapse back to preview mode
  ///
  /// Player will be muted and animated back to preview position.
  void collapseToPreview() {
    if (_mode != VhPlyrOverlayMode.fullMode) return;

    debugPrint('[VhPlyrOverlay] Collapsing to preview');
    _mode = VhPlyrOverlayMode.preview;

    // Mute for preview
    playerController.setMuted(true);

    // Update bounds in case they changed
    _updatePreviewBounds();

    _safeNotify();
  }

  /// Hide the player completely
  void hide() {
    debugPrint('[VhPlyrOverlay] Hiding player');
    _mode = VhPlyrOverlayMode.hidden;
    playerController.pause();
    _safeNotify();
  }

  /// Called when player is ready
  void onPlayerReady() {
    _isReady = true;
    _safeNotify();
  }

  // Safe notification to avoid setState during build
  bool _pendingNotify = false;
  void _safeNotify() {
    if (_pendingNotify) return;
    _pendingNotify = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pendingNotify = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }
}

/// Scope that provides [VhPlyrOverlayController] to descendants
///
/// Wrap your MaterialApp with this to enable overlay-based player:
/// ```dart
/// VhPlyrOverlayScope(
///   child: MaterialApp(
///     home: HomeScreen(),
///   ),
/// )
/// ```
class VhPlyrOverlayScope extends StatefulWidget {
  final Widget child;

  /// Whether to use local assets for the player
  final bool useLocalAssets;

  const VhPlyrOverlayScope({
    super.key,
    required this.child,
    this.useLocalAssets = false,
  });

  /// Get the controller from context
  static VhPlyrOverlayController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_VhPlyrOverlayScopeData>();
    assert(scope != null, 'VhPlyrOverlayScope not found in widget tree');
    return scope!.controller;
  }

  /// Try to get the controller (returns null if not found)
  static VhPlyrOverlayController? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_VhPlyrOverlayScopeData>();
    return scope?.controller;
  }

  @override
  State<VhPlyrOverlayScope> createState() => _VhPlyrOverlayScopeState();
}

class _VhPlyrOverlayScopeState extends State<VhPlyrOverlayScope> {
  late final VhPlyrOverlayController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VhPlyrOverlayController();
    _controller.useLocalAssets = widget.useLocalAssets;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _VhPlyrOverlayScopeData(
      controller: _controller,
      // Add Directionality since we're above MaterialApp
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // Main app content
            widget.child,

            // Overlay player
            _VhPlyrOverlayWidget(controller: _controller),
          ],
        ),
      ),
    );
  }
}

/// InheritedWidget to provide controller
class _VhPlyrOverlayScopeData extends InheritedWidget {
  final VhPlyrOverlayController controller;

  const _VhPlyrOverlayScopeData({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_VhPlyrOverlayScopeData oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// The actual overlay widget that displays the player
class _VhPlyrOverlayWidget extends StatelessWidget {
  final VhPlyrOverlayController controller;

  const _VhPlyrOverlayWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.mode == VhPlyrOverlayMode.hidden) {
          return const SizedBox.shrink();
        }

        final screenSize = MediaQuery.of(context).size;
        final isFullMode = controller.mode == VhPlyrOverlayMode.fullMode;

        // Calculate target bounds
        final Rect targetBounds;
        if (isFullMode) {
          // Fullscreen
          targetBounds = Rect.fromLTWH(
            0,
            0,
            screenSize.width,
            screenSize.height,
          );
        } else {
          // Preview bounds or default
          targetBounds =
              controller.previewBounds ??
              Rect.fromLTWH(16, 100, screenSize.width - 32, 200);
        }

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: targetBounds.left,
          top: targetBounds.top,
          width: targetBounds.width,
          height: targetBounds.height,
          child: Material(
            color: Colors.black,
            elevation: isFullMode ? 16 : 4,
            borderRadius: BorderRadius.circular(isFullMode ? 0 : 12),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // The player (never disposed!)
                VhPlyr(
                  controller: controller.playerController,
                  useAspectRatio: false,
                  options: VhPlyrOptions(
                    useLocalAssets: controller.useLocalAssets,
                    initialSource: controller.streamUrl,
                    autoplay: true,
                    muted: !isFullMode,
                    controls: isFullMode,
                  ),
                  onReady: controller.onPlayerReady,
                ),

                // Preview mode overlay
                if (!isFullMode) _buildPreviewOverlay(context),

                // Full mode UI
                if (isFullMode) _buildFullModeUI(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewOverlay(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => controller.expandToFullMode(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
            ),
          ),
          child: Stack(
            children: [
              // Live badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Play button
              const Center(
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white70,
                  size: 48,
                ),
              ),

              // Muted indicator
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.volume_off,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullModeUI(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Spacer (player area)
            const Expanded(child: SizedBox()),

            // Controls
            VhPlyrControls(
              controller: controller.playerController,
              showQuality: true,
            ),

            // Bottom info
            _buildBottomInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => controller.collapseToPreview(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.lessonTitle ?? 'Live Lesson',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.teacherName != null)
                  Text(
                    controller.teacherName!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 8),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black54,
      child: Row(
        children: [
          const Row(
            children: [
              Icon(Icons.people, color: Colors.white70, size: 16),
              SizedBox(width: 4),
              Text(
                '156 người xem',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.thumb_up_outlined, color: Colors.white70),
            onPressed: () {},
          ),
          ListenableBuilder(
            listenable: controller.playerController,
            builder: (context, _) {
              final state = controller.playerController.state;
              return IconButton(
                icon: Icon(
                  state.muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white70,
                ),
                onPressed: () =>
                    controller.playerController.setMuted(!state.muted),
              );
            },
          ),
        ],
      ),
    );
  }
}
