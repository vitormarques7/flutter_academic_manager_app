import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/subjects_page.dart';
import '../pages/tasks_page.dart';
import '../pages/schedule_page.dart';
import '../widgets/common/app_bottom_nav_bar.dart';
import 'main_shell_scope.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  late final List<Widget> _pages = [
    const HomePage(),
    const SubjectsPage(),
    const TasksPage(),
    const SchedulePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
      selectTab: _selectTab,
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _selectTab,
        ),
      ),
    );
  }
}
