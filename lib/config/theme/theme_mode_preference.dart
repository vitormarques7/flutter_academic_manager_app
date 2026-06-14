import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModePreference {
  ThemeModePreference._();

  static const String key = 'theme_mode';
  static const String systemValue = 'system';
  static const String lightValue = 'light';
  static const String darkValue = 'dark';

  static String encode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => lightValue,
      ThemeMode.dark => darkValue,
      ThemeMode.system => systemValue,
    };
  }

  static ThemeMode decode(String? value) {
    return switch (value) {
      lightValue => ThemeMode.light,
      darkValue => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

class ThemeModeStore {
  const ThemeModeStore();

  Future<ThemeMode> load() async {
    final preferences = await SharedPreferences.getInstance();
    return ThemeModePreference.decode(
      preferences.getString(ThemeModePreference.key),
    );
  }

  Future<void> save(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      ThemeModePreference.key,
      ThemeModePreference.encode(mode),
    );
  }
}
