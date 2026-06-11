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
  int? _previousIndex;
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
      body: ClipRect(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_currentIndex),
          tween: Tween<double>(begin: _previousIndex == null ? 1 : 0, end: 1),
          duration: _previousIndex == null
              ? Duration.zero
              : const Duration(milliseconds: 210),
          curve: Curves.easeOutCubic,
          onEnd: () {
            if (_previousIndex == null || !mounted) return;
            setState(() => _previousIndex = null);
          },
          builder: (context, value, child) {
            final previousIndex = _previousIndex;
            if (previousIndex == null) return _pages[_currentIndex];

            return Stack(
              children: [
                _TabPageSlide(
                  translation: Offset(-_navigationDirection * value, 0),
                  child: _pages[previousIndex],
                ),
                _TabPageSlide(
                  translation: Offset(_navigationDirection * (1 - value), 0),
                  child: _pages[_currentIndex],
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() {
            _previousIndex = _currentIndex;
            _navigationDirection = index > _currentIndex ? 1 : -1;
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _TabPageSlide extends StatelessWidget {
  final Offset translation;
  final Widget child;

  const _TabPageSlide({required this.translation, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FractionalTranslation(translation: translation, child: child),
    );
  }
}
