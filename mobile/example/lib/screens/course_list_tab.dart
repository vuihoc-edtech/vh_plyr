import 'package:flutter/material.dart';

import '../widgets/live_lesson_card.dart';

/// Course List Tab with live lesson preview
///
/// Simulates the vuihoc.vn course list where users can
/// browse their enrolled courses and join live lessons.
class CourseListTab extends StatelessWidget {
  const CourseListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          _buildSearchBar(),
          const SizedBox(height: 20),

          // Live now section
          const Text(
            '🔴 Đang phát trực tiếp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Live lesson with preview (different stream to test multiple players)
          const LiveLessonCard(
            playerId: 'preview_courses',
            lessonTitle: 'Luyện thi THPT QG - Toán',
            teacherName: 'Thầy Phạm Văn D',
            streamUrl:
                'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
            startTime: '14:30',
            duration: '90 phút',
          ),

          const SizedBox(height: 24),

          // Enrolled courses
          const Text(
            '📚 Khóa học của tôi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildCourseItem(
            title: 'Luyện thi THPT QG - Toán 2024',
            progress: 0.65,
            lessons: 48,
            completedLessons: 31,
          ),
          _buildCourseItem(
            title: 'Luyện thi THPT QG - Vật lý 2024',
            progress: 0.42,
            lessons: 36,
            completedLessons: 15,
          ),
          _buildCourseItem(
            title: 'Luyện thi THPT QG - Hóa học 2024',
            progress: 0.28,
            lessons: 42,
            completedLessons: 12,
          ),
          _buildCourseItem(
            title: 'Tiếng Anh giao tiếp cơ bản',
            progress: 0.85,
            lessons: 24,
            completedLessons: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm khóa học...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCourseItem({
    required String title,
    required double progress,
    required int lessons,
    required int completedLessons,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepOrange, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedLessons/$lessons bài học',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.deepOrange,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
