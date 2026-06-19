import 'package:flutter/material.dart';

class MainShellScope extends InheritedWidget {
  final ValueChanged<int> selectTab;

  const MainShellScope({
    super.key,
    required this.selectTab,
    required super.child,
  });

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) {
    return selectTab != oldWidget.selectTab;
  }
}
