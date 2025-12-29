import 'package:flutter/material.dart';
import 'common.dart';

/// Console log display section
class LogSection extends StatelessWidget {
  final List<String> logs;
  final VoidCallback onClear;

  const LogSection({super.key, required this.logs, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionLabel('CONSOLE LOG'),
                TextButton(
                  onPressed: onClear,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: const Color(0xFF252540),
                  ),
                  child: const Text('Clear', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  Color color = const Color(0xFF10B981);
                  if (log.contains('Error') || log.contains('❌')) {
                    color = Colors.red.shade400;
                  } else if (log.contains('Ready') ||
                      log.contains('Loading') ||
                      log.contains('🎬')) {
                    color = Colors.blue.shade400;
                  }
                  return Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: color,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
