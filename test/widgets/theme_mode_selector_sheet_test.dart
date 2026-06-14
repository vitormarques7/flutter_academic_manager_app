import 'package:academic_manager_app/config/theme/app_theme.dart';
import 'package:academic_manager_app/config/theme/app_theme_colors.dart';
import 'package:academic_manager_app/config/theme/app_theme_controller.dart';
import 'package:academic_manager_app/view/widgets/common/theme_mode_selector_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('selecting Escuro updates the theme controller', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppThemeController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Scaffold(body: ThemeModeSelectorSheet(controller: controller)),
      ),
    );

    await tester.tap(find.text('Escuro'));
    await tester.pump();

    expect(controller.themeMode, ThemeMode.dark);
  });

  testWidgets(
    'MaterialApp applies AppTheme.dark when ThemeMode.dark is active',
    (tester) async {
      late ThemeData resolvedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              resolvedTheme = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final colors = resolvedTheme.extension<AppThemeColors>();

      expect(resolvedTheme.brightness, Brightness.dark);
      expect(colors?.background, AppThemeColors.dark.background);
    },
  );
}
