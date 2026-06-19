import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_theme_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        extension: AppThemeExtension.light,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        extension: AppThemeExtension.dark,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppThemeExtension extension,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      fontFamily: 'Inter',
      brightness: brightness,
      scaffoldBackgroundColor: extension.background,
      extensions: [extension],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        surface: extension.surface,
        onSurface: extension.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1.copyWith(
          color: extension.textPrimary,
        ),
        displayMedium: AppTextStyles.headline2.copyWith(
          color: extension.textPrimary,
        ),
        displaySmall: AppTextStyles.headline3.copyWith(
          color: extension.textPrimary,
        ),
        bodyLarge: AppTextStyles.bodyBold.copyWith(
          color: extension.textPrimary,
        ),
        bodyMedium: AppTextStyles.bodyRegular.copyWith(
          color: extension.textPrimary,
        ),
        labelSmall: AppTextStyles.navLabel.copyWith(
          color: extension.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: extension.background,
        foregroundColor: extension.textPrimary,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: extension.surface,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: extension.surface,
        modalBackgroundColor: extension.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTextStyles.fieldPlaceholder.copyWith(
          color: extension.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: BorderSide(color: extension.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: BorderSide(color: extension.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDark ? extension.inputFill : AppColors.defaultFieldBackground,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(double.infinity, 65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return isDark ? extension.textMuted : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return isDark ? extension.inputBorder : const Color(0xFFD9D9E3);
        }),
      ),
      useMaterial3: true,
    );
  }

  @Deprecated('Use AppTheme.lightTheme')
  static ThemeData get theme => lightTheme;
}
