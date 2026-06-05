import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.background,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.headline1,
      displayMedium: AppTextStyles.headline2,
      displaySmall: AppTextStyles.headline3,
      bodyLarge: AppTextStyles.bodyBold,
      bodyMedium: AppTextStyles.bodyRegular,
      labelSmall: AppTextStyles.navLabel,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: AppTextStyles.fieldPlaceholder,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35),
        borderSide: const BorderSide(color: AppColors.defaultFieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35),
        borderSide: const BorderSide(color: AppColors.defaultFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35),
        borderSide: const BorderSide(
          color: AppColors.defaultFieldBorder,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: AppColors.defaultFieldBackground,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        textStyle: AppTextStyles.button,
        minimumSize: const Size(double.infinity, 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      ),
    ),
    useMaterial3: true,
  );
}
