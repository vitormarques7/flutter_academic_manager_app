import 'package:flutter/widgets.dart';

import 'app_theme_controller.dart';

class ThemeControllerScope extends InheritedWidget {
  final AppThemeController controller;

  const ThemeControllerScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static AppThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope was not found in context.');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(ThemeControllerScope oldWidget) {
    return oldWidget.controller != controller;
  }
}
