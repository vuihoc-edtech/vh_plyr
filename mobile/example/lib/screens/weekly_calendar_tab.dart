import 'package:flutter/material.dart';

import '../widgets/live_lesson_card.dart';

/// Weekly Calendar Tab with live lesson preview
///
/// Simulates the vuihoc.vn weekly calendar view where
/// users can see their schedule and join live lessons.
class WeeklyCalendarTab extends StatelessWidget {
  const WeeklyCalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week navigation
          _buildWeekHeader(),
          const SizedBox(height: 16),

          // Day slots
          _buildDaySlots(),
          const SizedBox(height: 24),

          // Live lesson section
          const Text(
            '🔴 Buổi học đang diễn ra',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Live lesson card with preview
          const LiveLessonCard(
            playerId: 'preview_calendar',
            lessonTitle: 'Toán lớp 12 - Đạo hàm',
            teacherName: 'Thầy Nguyễn Văn A',
            streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
            startTime: '14:00',
            duration: '45 phút',
          ),

          const SizedBox(height: 24),

          // Upcoming lessons
          const Text(
            '📅 Buổi học sắp tới',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildUpcomingLessonItem(
            title: 'Vật lý lớp 12 - Dao động điều hòa',
            teacher: 'Cô Trần Thị B',
            time: '15:00 - 15:45',
          ),
          _buildUpcomingLessonItem(
            title: 'Hóa học lớp 12 - Este',
            teacher: 'Thầy Lê Văn C',
            time: '16:00 - 16:45',
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    final now = DateTime.now();
    final weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final dayDate = now.subtract(Duration(days: now.weekday - 1 - index));
        final isToday = dayDate.day == now.day;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: isToday ? Colors.deepOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                weekDays[index],
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${dayDate.day}',
                style: TextStyle(
                  color: isToday ? Colors.white : null,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDaySlots() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTimeSlot('08:00 - 08:45', 'Ngữ văn lớp 12', isCompleted: true),
          _buildTimeSlot(
            '09:00 - 09:45',
            'Tiếng Anh lớp 12',
            isCompleted: true,
          ),
          _buildTimeSlot('14:00 - 14:45', 'Toán lớp 12', isLive: true),
          _buildTimeSlot('15:00 - 15:45', 'Vật lý lớp 12'),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(
    String time,
    String title, {
    bool isCompleted = false,
    bool isLive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              time,
              style: TextStyle(
                color: isCompleted ? Colors.grey : null,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted ? Colors.grey : null,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  Widget _buildUpcomingLessonItem({
    required String title,
    required String teacher,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_lesson, color: Colors.deepOrange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    teacher,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
