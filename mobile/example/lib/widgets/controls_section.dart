import 'package:flutter/material.dart';
import 'common.dart';

/// Player controls grid section
class ControlsSection extends StatelessWidget {
  final void Function(String action, [List<dynamic>? args]) onAction;

  const ControlsSection({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('ĐIỀU KHIỂN PLAYER'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.3,
              children: [
                ControlButton(
                  icon: Icons.play_arrow,
                  label: 'Play',
                  onTap: () => onAction('play'),
                ),
                ControlButton(
                  icon: Icons.pause,
                  label: 'Pause',
                  onTap: () => onAction('pause'),
                ),
                ControlButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  onTap: () => onAction('stop'),
                ),
                ControlButton(
                  icon: Icons.replay_10,
                  label: '-10s',
                  onTap: () => onAction('rewind', [10]),
                ),
                ControlButton(
                  icon: Icons.forward_10,
                  label: '+10s',
                  onTap: () => onAction('forward', [10]),
                ),
                ControlButton(
                  icon: Icons.fullscreen,
                  label: 'Fullscreen',
                  onTap: () => onAction('toggleFullscreen'),
                ),
                ControlButton(
                  icon: Icons.volume_down,
                  label: 'Vol 50%',
                  onTap: () => onAction('setVolume', [0.5]),
                ),
                ControlButton(
                  icon: Icons.volume_off,
                  label: 'Mute',
                  onTap: () => onAction('setMuted', [true]),
                ),
                ControlButton(
                  icon: Icons.info_outline,
                  label: 'State',
                  onTap: () => onAction('getState'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
