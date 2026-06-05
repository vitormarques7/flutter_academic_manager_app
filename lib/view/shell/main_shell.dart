import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/subjects_page.dart';
import '../pages/tasks_page.dart';
import '../pages/schedule_page.dart';
import '../widgets/common/app_bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  int _navigationDirection = 1;

  static const List<Widget> _pages = [
    HomePage(),
    SubjectsPage(),
    TasksPage(),
    SchedulePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: Offset(0.04 * _navigationDirection, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() {
            _navigationDirection = index > _currentIndex ? 1 : -1;
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
