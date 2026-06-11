import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _font = 'Roboto';
  static const double _letterSpacing = 0;

  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontFamily: _font,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: _letterSpacing,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: _letterSpacing,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: _letterSpacing,
  );

  // Body
  static const TextStyle bodyBold = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textMedium,
    letterSpacing: _letterSpacing,
    height: 1.38,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: _letterSpacing,
    height: 1.38,
  );

  // Botões
  static const TextStyle button = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: _letterSpacing,
  );

  // Labels de seção (caps lock)
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textMedium,
    letterSpacing: 0.7,
  );

  // Navegação (bottom nav bar)
  static const TextStyle navLabel = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: _letterSpacing,
    height: 1.83,
  );

  // Campos de texto (placeholder)
  static const TextStyle fieldPlaceholder = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: _letterSpacing,
  );

  // Cards de perfil
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    letterSpacing: _letterSpacing,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnPrimary,
    letterSpacing: _letterSpacing,
  );
}
