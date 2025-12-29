import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/mobile.dart';

import '../screens/live_lesson_full_screen.dart';

/// Live lesson card with embedded preview player
///
/// Shows a small muted preview of the live lesson.
/// Tapping opens the full mode viewing screen with time sync.
class LiveLessonCard extends StatefulWidget {
  /// Unique identifier for this preview player
  final String playerId;

  /// Lesson title
  final String lessonTitle;

  /// Teacher name
  final String teacherName;

  /// HLS stream URL
  final String streamUrl;

  /// Start time display
  final String startTime;

  /// Duration display
  final String duration;

  const LiveLessonCard({
    super.key,
    required this.playerId,
    required this.lessonTitle,
    required this.teacherName,
    required this.streamUrl,
    required this.startTime,
    required this.duration,
  });

  @override
  State<LiveLessonCard> createState() => _LiveLessonCardState();
}

class _LiveLessonCardState extends State<LiveLessonCard> {
  late final VhPlyrController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VhPlyrController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullMode() async {
    // Get current time from preview for sync
    final currentTime = _controller.state.currentTime;
    debugPrint('[LiveLessonCard] Opening full mode, currentTime: $currentTime');

    // Notify manager that we're entering full mode
    VhPlyrManager.instance.enterFullMode(widget.playerId);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LiveLessonFullScreen(
          streamUrl: widget.streamUrl,
          lessonTitle: widget.lessonTitle,
          teacherName: widget.teacherName,
          startTime: currentTime, // Pass current time for sync
        ),
      ),
    );

    // Returned from full mode - resume preview
    VhPlyrManager.instance.exitFullMode(resumePreview: true);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview player (embedded, scrolls with content)
          Stack(
            children: [
              VhPlyrVisibilityWrapper(
                playerId: widget.playerId,
                controller: _controller,
                streamUrl: widget.streamUrl,
                child: VhPlyr(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                  options: VhPlyrOptions.preview(
                    useLocalAssets: kDebugMode,
                    initialSource: widget.streamUrl,
                  ),
                  onReady: () {
                    if (mounted) {
                      setState(() => _isReady = true);
                      // Ensure preview is muted
                      _controller.setMuted(true);
                      _controller.setVolume(0);
                      // Auto-set as active when ready
                      VhPlyrManager.instance.setActive(widget.playerId);
                    }
                  },
                ),
              ),

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

              // Tap to enter full mode overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isReady ? _openFullMode : null,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
                  ),
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

          // Lesson info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lessonTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.teacherName,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.startTime} • ${widget.duration}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Join button
                ElevatedButton(
                  onPressed: _isReady ? _openFullMode : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Vào học'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
