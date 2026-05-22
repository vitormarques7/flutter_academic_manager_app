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
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
