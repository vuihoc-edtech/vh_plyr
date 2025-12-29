import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/mobile.dart';

/// Full screen live lesson viewing with sound and time sync
///
/// Receives startTime from preview and seeks to that position.
class LiveLessonFullScreen extends StatefulWidget {
  /// HLS stream URL
  final String streamUrl;

  /// Lesson title
  final String lessonTitle;

  /// Teacher name
  final String teacherName;

  /// Start time from preview (for sync)
  final double startTime;

  const LiveLessonFullScreen({
    super.key,
    required this.streamUrl,
    required this.lessonTitle,
    required this.teacherName,
    this.startTime = 0,
  });

  @override
  State<LiveLessonFullScreen> createState() => _LiveLessonFullScreenState();
}

class _LiveLessonFullScreenState extends State<LiveLessonFullScreen> {
  late final VhPlyrController _controller;
  bool _showControls = true;
  bool _hasSeeked = false;

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

  void _onPlayerReady() {
    debugPrint('[FullScreen] Player ready');

    // Unmute and set volume
    _controller.setMuted(false);
    _controller.setVolume(1.0);
    _controller.play();

    // Seek to start time from preview (only once)
    if (!_hasSeeked && widget.startTime > 0) {
      debugPrint('[FullScreen] Seeking to ${widget.startTime}s');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _controller.seek(widget.startTime);
          _hasSeeked = true;
        }
      });
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Player
            Expanded(
              child: GestureDetector(
                onTap: _toggleControls,
                child: Stack(
                  children: [
                    Center(
                      child: VhPlyr(
                        controller: _controller,
                        aspectRatio: 16 / 9,
                        useAspectRatio: true,
                        options: VhPlyrOptions.fullMode(
                          useLocalAssets: kDebugMode,
                          initialSource: widget.streamUrl,
                          autoplay: true,
                        ),
                        onReady: _onPlayerReady,
                      ),
                    ),

                    // Controls overlay
                    if (_showControls)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: VhPlyrControls(
                          controller: _controller,
                          showQuality: true,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom info area
            _buildBottomInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.black,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lessonTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.teacherName,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          // Live indicator
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

  Widget _buildBottomInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade900,
      child: Row(
        children: [
          // Viewer count (mock)
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
          // Actions
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.thumb_up_outlined, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('👍 Liked!')));
            },
          ),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final state = _controller.state;
              return IconButton(
                icon: Icon(
                  state.muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white70,
                ),
                onPressed: () => _controller.setMuted(!state.muted),
              );
            },
          ),
        ],
      ),
    );
  }
}
