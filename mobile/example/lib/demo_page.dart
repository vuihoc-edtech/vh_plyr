import 'package:example/widgets/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/mobile.dart';

import 'widgets/controls_section.dart';
import 'widgets/log_section.dart';
import 'widgets/state_section.dart';
import 'widgets/url_input_section.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _controller = VhPlyrController();
  final _urlController = TextEditingController()
    ..text = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
  final _logs = ['[VhPlyr Demo] Ready'];

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _controller.onReady.listen((_) {
      _log('Player ready', isInfo: true);
    });

    _controller.onError.listen((error) {
      _log('Error: $error', isError: true);
    });

    _controller.onPlay.listen((_) => _log('▶️ Playing'));
    _controller.onPause.listen((_) => _log('⏸️ Paused'));
    _controller.onEnded.listen((_) => _log('⏹️ Ended'));
    _controller.onSeeking.listen((_) => _log('🔍 Seeking...'));
    _controller.onSeeked.listen((_) => _log('✅ Seeked'));
  }

  void _log(String message, {bool isInfo = false, bool isError = false}) {
    final time = TimeOfDay.now().format(context);
    setState(() {
      _logs.add('[$time] $message');
      if (_logs.length > 50) _logs.removeAt(0);
    });
  }

  Future<void> _executeAction(String action, [List<dynamic>? args]) async {
    _log('→ $action(${args?.join(', ') ?? ''})');

    switch (action) {
      case 'play':
        await _controller.play();
      case 'pause':
        await _controller.pause();
      case 'stop':
        await _controller.stop();
      case 'rewind':
        await _controller.rewind(args?[0]?.toDouble() ?? 10);
      case 'forward':
        await _controller.forward(args?[0]?.toDouble() ?? 10);
      case 'toggleFullscreen':
        await _controller.toggleFullscreen();
      case 'setVolume':
        await _controller.setVolume(args?[0]?.toDouble() ?? 0.5);
      case 'setMuted':
        await _controller.setMuted(args?[0] ?? true);
      case 'getState':
        final state = await _controller.getState();
        _log(
          '← State: ${state.isPlaying ? "playing" : "paused"}, '
          '${_formatTime(state.currentTime)}/${_formatTime(state.duration)}',
        );
    }
  }

  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void _loadUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    _log(
      'Loading: ${url.substring(0, url.length.clamp(0, 40))}...',
      isInfo: true,
    );
    _controller.loadSource(url, autoplay: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player
            PlayerDecoration(
              child: VhPlyr(
                controller: _controller,
                options: VhPlyrOptions(
                  useLocalAssets: kDebugMode,
                  initialSource: _urlController.text,
                  autoplay: false,
                  debug: true,
                ),
                onReady: () => _log('🎬 Player initialized', isInfo: true),
                onError: (error) => _log('❌ $error', isError: true),
              ),
            ),

            const SizedBox(height: 16),
            // URL Input
            UrlInputSection(controller: _urlController, onLoad: _loadUrl),
            const SizedBox(height: 16),
            // Controls
            ControlsSection(onAction: _executeAction),
            const SizedBox(height: 16),
            // State Display
            StateSection(controller: _controller, formatTime: _formatTime),
            const SizedBox(height: 16),
            // Console Log
            LogSection(
              logs: _logs,
              onClear: () => setState(() {
                _logs
                  ..clear()
                  ..add('[VhPlyr] Cleared');
              }),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Image.network(
        'https://xcdn-cf.vuihoc.vn/theme/vuihoc/imgs/vuihoc_logo_final.png',
        height: 32,
        errorBuilder: (_, __, ___) => const Icon(Icons.play_circle),
      ),
      actions: const [LiveBadge()],
    );
  }

  Widget PlayerDecoration({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }
}
