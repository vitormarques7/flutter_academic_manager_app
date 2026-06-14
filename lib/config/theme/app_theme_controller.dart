import 'package:flutter/material.dart';

import 'theme_mode_preference.dart';

class AppThemeController extends ChangeNotifier {
  final ThemeModeStore _store;

  ThemeMode _themeMode;

  AppThemeController({
    ThemeModeStore store = const ThemeModeStore(),
    ThemeMode initialThemeMode = ThemeMode.system,
  }) : _store = store,
       _themeMode = initialThemeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    _themeMode = await _store.load();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
    await _store.save(mode);
  }
}
