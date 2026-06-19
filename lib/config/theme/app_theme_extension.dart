import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color background;
  final Color surface;
  final Color surfaceTint;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color inputFill;
  final Color inputBorder;
  final Color handle;
  final Color badgeBackground;
  final Color shadow;
  final Color fabBackground;
  final Color navBackground;
  final Color navInactive;

  const AppThemeExtension({
    required this.background,
    required this.surface,
    required this.surfaceTint,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.inputFill,
    required this.inputBorder,
    required this.handle,
    required this.badgeBackground,
    required this.shadow,
    required this.fabBackground,
    required this.navBackground,
    required this.navInactive,
  });

  static const light = AppThemeExtension(
    background: AppColors.background,
    surface: Colors.white,
    surfaceTint: Color(0xFFEFF0FB),
    card: Color(0xFFEFF0FB),
    textPrimary: Color(0xFF191820),
    textSecondary: Color(0xFF464552),
    textMuted: Color(0xFF656565),
    inputFill: Color(0xFFF5F6FA),
    inputBorder: Color(0xFFE8EAF2),
    handle: Color(0xFFD9D9E3),
    badgeBackground: Color(0xFFF3F2FF),
    shadow: Color(0x66587DBD),
    fabBackground: Color(0xFFE4E4FF),
    navBackground: AppColors.background,
    navInactive: AppColors.navInactive,
  );

  static const dark = AppThemeExtension(
    background: Color(0xFF12111A),
    surface: Color(0xFF1C1B26),
    surfaceTint: Color(0xFF252433),
    card: Color(0xFF252433),
    textPrimary: Color(0xFFF4F4F8),
    textSecondary: Color(0xFFC8C6D8),
    textMuted: Color(0xFF8E8CA0),
    inputFill: Color(0xFF2E2D3C),
    inputBorder: Color(0xFF3D3B52),
    handle: Color(0xFF4A4860),
    badgeBackground: Color(0xFF2A2840),
    shadow: Color(0x66000000),
    fabBackground: Color(0xFF2A2840),
    navBackground: Color(0xFF1C1B26),
    navInactive: Color(0xFF8E8CA0),
  );

  @override
  AppThemeExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceTint,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? inputFill,
    Color? inputBorder,
    Color? handle,
    Color? badgeBackground,
    Color? shadow,
    Color? fabBackground,
    Color? navBackground,
    Color? navInactive,
  }) {
    return AppThemeExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      handle: handle ?? this.handle,
      badgeBackground: badgeBackground ?? this.badgeBackground,
      shadow: shadow ?? this.shadow,
      fabBackground: fabBackground ?? this.fabBackground,
      navBackground: navBackground ?? this.navBackground,
      navInactive: navInactive ?? this.navInactive,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;

    return AppThemeExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      handle: Color.lerp(handle, other.handle, t)!,
      badgeBackground: Color.lerp(badgeBackground, other.badgeBackground, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      fabBackground: Color.lerp(fabBackground, other.fabBackground, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light;
}
