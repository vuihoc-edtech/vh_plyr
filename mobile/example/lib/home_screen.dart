import 'package:flutter/material.dart';
import 'package:mobile/mobile.dart';

import 'screens/weekly_calendar_tab.dart';
import 'screens/course_list_tab.dart';

/// Home screen with 2 tabs demonstrating multiple preview players
///
/// This simulates the vuihoc.vn mobile app where:
/// - Tab 0: Weekly calendar with live lesson preview
/// - Tab 1: Course list with live lesson preview
///
/// Only ONE preview player plays at a time (managed by VhPlyrManager)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // Tab has finished changing - activate the correct preview
      final tabIndex = _tabController.index;
      debugPrint('[HomeScreen] Tab changed to: $tabIndex');

      // Each tab has its own player ID
      // The tab's player will be activated when it becomes visible
      // This is handled automatically by VhPlyrVisibilityWrapper
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    // Clear all players when leaving home screen
    VhPlyrManager.instance.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: const [WeeklyCalendarTab(), CourseListTab()],
      ),
      bottomNavigationBar: _buildBottomTabBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Image.network(
        'https://xcdn-cf.vuihoc.vn/theme/vuihoc/imgs/vuihoc_logo_final.png',
        height: 32,
        errorBuilder: (_, __, ___) => const Text('VUIHOC'),
      ),
      actions: [
        // Manager status indicator
        ListenableBuilder(
          listenable: VhPlyrManager.instance,
          builder: (context, _) {
            final manager = VhPlyrManager.instance;
            final activeId = manager.activePlayerId;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                avatar: Icon(
                  manager.isFullModeActive
                      ? Icons.fullscreen
                      : Icons.play_circle,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  activeId?.replaceAll('preview_', '') ?? 'none',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: manager.isFullModeActive
                    ? Colors.deepPurple
                    : Colors.deepOrange,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.deepOrange,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.deepOrange,
        tabs: const [
          Tab(icon: Icon(Icons.calendar_month), text: 'Lịch học'),
          Tab(icon: Icon(Icons.school), text: 'Khóa học'),
        ],
      ),
    );
  }
}
