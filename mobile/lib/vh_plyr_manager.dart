/// VhPlyr Manager - Singleton for coordinating multiple player instances
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'vh_plyr_controller.dart';

/// Player registration info
class _PlayerEntry {
  final VhPlyrController controller;
  final String? streamUrl;
  bool isPaused;

  _PlayerEntry({
    required this.controller,
    this.streamUrl,
    this.isPaused = true,
  });
}

/// Singleton manager to coordinate multiple VhPlyr instances
///
/// Ensures only ONE preview player plays at a time to optimize performance
/// and prevent audio conflicts. Handles:
/// - Tab switching (pause inactive tab's player)
/// - Full mode transitions (pause preview, resume on exit)
/// - Visibility-based pause/resume
///
/// Example usage:
/// ```dart
/// // Register a preview player
/// VhPlyrManager.instance.register('tab0_preview', controller);
///
/// // Set as active (will pause others)
/// VhPlyrManager.instance.setActive('tab0_preview');
///
/// // When entering full mode from a preview
/// VhPlyrManager.instance.enterFullMode('tab0_preview');
///
/// // When exiting full mode
/// VhPlyrManager.instance.exitFullMode();
/// ```
class VhPlyrManager extends ChangeNotifier {
  // Singleton pattern
  static final VhPlyrManager _instance = VhPlyrManager._internal();
  static VhPlyrManager get instance => _instance;
  VhPlyrManager._internal();

  // Track registered players
  final Map<String, _PlayerEntry> _players = {};

  // Currently active preview player ID
  String? _activePlayerId;

  // Full mode state
  bool _isFullModeActive = false;
  String? _fullModeSourceId;
  VhPlyrController? _fullModeController;

  // Debounce timer for rapid switching
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 100);

  // Pending notification flag to avoid duplicate posts
  bool _pendingNotify = false;

  /// Safely notify listeners, deferring if called during build phase
  void _safeNotify() {
    if (_pendingNotify) return;
    _pendingNotify = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pendingNotify = false;
      notifyListeners();
    });
  }

  /// Whether full mode is currently active
  bool get isFullModeActive => _isFullModeActive;

  /// Current active preview player ID (null if none or in full mode)
  String? get activePlayerId => _activePlayerId;

  /// List of all registered player IDs
  List<String> get registeredPlayerIds => _players.keys.toList();

  // ============ Registration ============

  /// Register a player with a unique ID
  ///
  /// The player will be paused by default. Call [setActive] to start playing.
  void register(String id, VhPlyrController controller, {String? streamUrl}) {
    if (_players.containsKey(id)) {
      debugPrint('[VhPlyrManager] Player $id already registered, updating');
    }
    _players[id] = _PlayerEntry(
      controller: controller,
      streamUrl: streamUrl,
      isPaused: true,
    );
    debugPrint('[VhPlyrManager] Registered player: $id');
  }

  /// Unregister a player when it's disposed
  void unregister(String id) {
    _players.remove(id);
    if (_activePlayerId == id) {
      _activePlayerId = null;
    }
    debugPrint('[VhPlyrManager] Unregistered player: $id');
  }

  /// Check if a player is registered
  bool isRegistered(String id) => _players.containsKey(id);

  /// Get controller for a registered player
  VhPlyrController? getController(String id) => _players[id]?.controller;

  // ============ Visibility Management ============

  /// Set a player as active (will pause all others)
  ///
  /// Only one preview player can be active at a time.
  /// If full mode is active, this is a no-op.
  void setActive(String id) {
    if (_isFullModeActive) {
      debugPrint('[VhPlyrManager] Full mode active, ignoring setActive($id)');
      return;
    }

    if (!_players.containsKey(id)) {
      debugPrint('[VhPlyrManager] Player $id not registered');
      return;
    }

    // Debounce rapid switching
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _performSetActive(id);
    });
  }

  void _performSetActive(String id) {
    if (_activePlayerId == id) return;

    debugPrint('[VhPlyrManager] Setting active: $id (was: $_activePlayerId)');

    // Pause current active player
    if (_activePlayerId != null && _players.containsKey(_activePlayerId!)) {
      final current = _players[_activePlayerId!]!;
      current.controller.pause();
      current.isPaused = true;
    }

    // Set new active and play
    _activePlayerId = id;
    final entry = _players[id]!;
    entry.controller.play();
    entry.isPaused = false;

    _safeNotify();
  }

  /// Pause all preview players
  ///
  /// Used when entering full mode or when app goes to background.
  void pauseAll() {
    debugPrint('[VhPlyrManager] Pausing all players');
    for (final entry in _players.values) {
      entry.controller.pause();
      entry.isPaused = true;
    }
    _safeNotify();
  }

  /// Resume the active player (if any)
  ///
  /// Used when exiting full mode or when app returns to foreground.
  void resumeActive() {
    if (_activePlayerId != null && _players.containsKey(_activePlayerId!)) {
      debugPrint('[VhPlyrManager] Resuming active player: $_activePlayerId');
      final entry = _players[_activePlayerId!]!;
      entry.controller.play();
      entry.isPaused = false;
      _safeNotify();
    }
  }

  /// Pause a specific player
  void pause(String id) {
    final entry = _players[id];
    if (entry != null) {
      entry.controller.pause();
      entry.isPaused = true;
    }
  }

  /// Get the stream URL for a registered player
  String? getStreamUrl(String id) => _players[id]?.streamUrl;

  // ============ Full Mode Lifecycle ============

  /// Enter full mode from a preview player
  ///
  /// - Pauses all preview players
  /// - Optionally tracks the source preview ID for reference
  /// - Full mode controller can share the same stream
  void enterFullMode(String sourcePreviewId, {VhPlyrController? controller}) {
    debugPrint('[VhPlyrManager] Entering full mode from: $sourcePreviewId');

    _isFullModeActive = true;
    _fullModeSourceId = sourcePreviewId;
    _fullModeController = controller;

    // Pause all preview players
    pauseAll();

    _safeNotify();
  }

  /// Exit full mode and optionally resume the source preview
  ///
  /// If [resumePreview] is true, the preview player that triggered
  /// full mode will resume playing (muted).
  void exitFullMode({bool resumePreview = true}) {
    debugPrint('[VhPlyrManager] Exiting full mode, resume: $resumePreview');

    _isFullModeActive = false;
    final sourceId = _fullModeSourceId;
    _fullModeSourceId = null;
    _fullModeController = null;

    if (resumePreview && sourceId != null) {
      // Use resumeActive instead of setActive (setActive skips if same ID)
      if (_activePlayerId == sourceId && _players.containsKey(sourceId)) {
        debugPrint('[VhPlyrManager] Resuming same player: $sourceId');
        final entry = _players[sourceId]!;
        entry.controller.play();
        entry.isPaused = false;
      } else {
        setActive(sourceId);
      }
    }

    _safeNotify();
  }

  /// Get the source preview ID that triggered full mode
  String? get fullModeSourceId => _fullModeSourceId;

  /// Get the full mode controller (if set)
  VhPlyrController? get fullModeController => _fullModeController;

  // ============ Cleanup ============

  /// Clear all registered players
  ///
  /// Call this when navigating away from the screen with players.
  void clear() {
    debugPrint('[VhPlyrManager] Clearing all players');
    _debounceTimer?.cancel();
    _players.clear();
    _activePlayerId = null;
    _isFullModeActive = false;
    _fullModeSourceId = null;
    _fullModeController = null;
    _safeNotify();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
