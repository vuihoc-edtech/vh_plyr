import 'package:flutter/material.dart';
import 'package:mobile/vh_plyr_controller.dart';
import 'common.dart';

/// Player state display section
class StateSection extends StatelessWidget {
  final VhPlyrController controller;
  final String Function(double seconds) formatTime;

  const StateSection({
    super.key,
    required this.controller,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('TRẠNG THÁI PLAYER'),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final state = controller.state;
                return Row(
                  children: [
                    Expanded(
                      child: StateCard(
                        value: formatTime(state.currentTime),
                        label: 'Thời gian',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StateCard(
                        value: formatTime(state.duration),
                        label: 'Tổng',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StateCard(
                        value: state.isPlaying
                            ? '▶️'
                            : state.isPaused
                                ? '⏸️'
                                : '---',
                        label: 'Trạng thái',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
