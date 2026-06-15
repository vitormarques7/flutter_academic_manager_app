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
  int _navigationDirection = 1; // 1 for right, -1 for left

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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isEntering = child.key == ValueKey<int>(_currentIndex);
            
            final offsetTween = isEntering
                ? Tween<Offset>(
                    begin: Offset(_navigationDirection * 1.0, 0.0),
                    end: Offset.zero,
                  )
                : Tween<Offset>(
                    begin: Offset(-_navigationDirection * 1.0, 0.0),
                    end: Offset.zero,
                  );

            return SlideTransition(
              position: offsetTween.animate(animation),
              child: child,
            );
          },
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              children: <Widget>[
                ...previousChildren.map((child) => Positioned.fill(child: child)),
                if (currentChild != null) Positioned.fill(child: currentChild),
              ],
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
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
