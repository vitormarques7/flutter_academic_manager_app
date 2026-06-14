import 'package:academic_manager_app/config/theme/theme_mode_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeModePreference', () {
    test('encodes theme modes as stable strings', () {
      expect(ThemeModePreference.encode(ThemeMode.system), 'system');
      expect(ThemeModePreference.encode(ThemeMode.light), 'light');
      expect(ThemeModePreference.encode(ThemeMode.dark), 'dark');
    });

    test('decodes unknown or empty values as system', () {
      expect(ThemeModePreference.decode(null), ThemeMode.system);
      expect(ThemeModePreference.decode('unexpected'), ThemeMode.system);
    });
  });

  group('ThemeModeStore', () {
    test('loads system as the default value', () async {
      SharedPreferences.setMockInitialValues({});

      const store = ThemeModeStore();

      expect(await store.load(), ThemeMode.system);
    });

    test('saves and loads the selected theme mode', () async {
      SharedPreferences.setMockInitialValues({});

      const store = ThemeModeStore();
      await store.save(ThemeMode.dark);

      expect(await store.load(), ThemeMode.dark);
    });
  });
}
