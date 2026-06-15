import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_design_tokens.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => light;

  static ThemeData get light => _build(AppThemeColors.light, Brightness.light);

  static ThemeData get dark => _build(AppThemeColors.dark, Brightness.dark);

  static ThemeData _build(AppThemeColors colors, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.textOnPrimary,
      surface: colors.surface,
      onSurface: colors.textDark,
      error: colors.danger,
      outline: colors.outline,
    );

    return ThemeData(
      fontFamily: 'Roboto',
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: colorScheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textDark),
        titleTextStyle: AppTextStyles.headline3.copyWith(
          color: colors.textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.outline, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navLabel.copyWith(color: colors.primary);
          }
          return AppTextStyles.navLabel.copyWith(color: colors.textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary);
          }
          return IconThemeData(color: colors.textMuted);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1.copyWith(color: colors.textDark),
        displayMedium: AppTextStyles.headline2.copyWith(color: colors.textDark),
        displaySmall: AppTextStyles.headline3.copyWith(color: colors.textDark),
        bodyLarge: AppTextStyles.bodyBold.copyWith(color: colors.textMedium),
        bodyMedium: AppTextStyles.bodyRegular.copyWith(color: colors.textLight),
        labelSmall: AppTextStyles.navLabel.copyWith(color: colors.textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTextStyles.fieldPlaceholder.copyWith(
          color: colors.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.defaultFieldBorder, width: 2),
        ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
          textStyle: AppTextStyles.button.copyWith(fontSize: 17),
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? colors.surfaceTint
            : AppColors.textDark,
        contentTextStyle: AppTextStyles.bodyRegular.copyWith(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: colors.divider),
      useMaterial3: true,
    );
  }
}
