import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color primarySurface;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceTint;
  final Color outline;
  final Color outlineStrong;
  final Color textDark;
  final Color textMedium;
  final Color textLight;
  final Color textMuted;
  final Color textSubtle;
  final Color textOnPrimary;
  final Color success;
  final Color successSurface;
  final Color warning;
  final Color warningSurface;
  final Color danger;
  final Color dangerSurface;
  final Color event;
  final Color eventSurface;
  final Color navActive;
  final Color navInactive;
  final Color defaultFieldBorder;
  final Color defaultFieldBackground;
  final Color divider;
  final Color chipSelected;
  final Color chipUnselected;
  final Color chipBorder;
  final LinearGradient softSurfaceGradient;
  final LinearGradient brandGradient;
  final List<BoxShadow> subtleShadows;
  final List<BoxShadow> cardShadows;
  final List<BoxShadow> floatingShadows;

  const AppThemeColors({
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.primarySurface,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceTint,
    required this.outline,
    required this.outlineStrong,
    required this.textDark,
    required this.textMedium,
    required this.textLight,
    required this.textMuted,
    required this.textSubtle,
    required this.textOnPrimary,
    required this.success,
    required this.successSurface,
    required this.warning,
    required this.warningSurface,
    required this.danger,
    required this.dangerSurface,
    required this.event,
    required this.eventSurface,
    required this.navActive,
    required this.navInactive,
    required this.defaultFieldBorder,
    required this.defaultFieldBackground,
    required this.divider,
    required this.chipSelected,
    required this.chipUnselected,
    required this.chipBorder,
    required this.softSurfaceGradient,
    required this.brandGradient,
    required this.subtleShadows,
    required this.cardShadows,
    required this.floatingShadows,
  });

  static const AppThemeColors light = AppThemeColors(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    primarySoft: AppColors.primarySoft,
    primarySurface: AppColors.primarySurface,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceAlt: AppColors.surfaceAlt,
    surfaceTint: AppColors.surfaceTint,
    outline: AppColors.outline,
    outlineStrong: AppColors.outlineStrong,
    textDark: AppColors.textDark,
    textMedium: AppColors.textMedium,
    textLight: AppColors.textLight,
    textMuted: AppColors.textMuted,
    textSubtle: AppColors.textSubtle,
    textOnPrimary: AppColors.textOnPrimary,
    success: AppColors.success,
    successSurface: AppColors.successSurface,
    warning: AppColors.warning,
    warningSurface: AppColors.warningSurface,
    danger: AppColors.danger,
    dangerSurface: AppColors.dangerSurface,
    event: AppColors.event,
    eventSurface: AppColors.eventSurface,
    navActive: AppColors.navActive,
    navInactive: AppColors.navInactive,
    defaultFieldBorder: AppColors.defaultFieldBorder,
    defaultFieldBackground: AppColors.defaultFieldBackground,
    divider: AppColors.divider,
    chipSelected: AppColors.chipSelected,
    chipUnselected: AppColors.chipUnselected,
    chipBorder: AppColors.chipBorder,
    softSurfaceGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFFFF), Color(0xFFFBFCFF)],
    ),
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, Color(0xFF4845AA)],
    ),
    subtleShadows: [
      BoxShadow(color: Color(0x0A111827), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x10111827), blurRadius: 12, offset: Offset(0, 6)),
    ],
    cardShadows: [
      BoxShadow(color: Color(0x07111827), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x14111827), blurRadius: 18, offset: Offset(0, 9)),
    ],
    floatingShadows: [
      BoxShadow(
        color: Color(0x1F111827),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
      BoxShadow(color: Color(0x1F514EB6), blurRadius: 16, offset: Offset(0, 4)),
    ],
  );

  static const AppThemeColors dark = AppThemeColors(
    primary: Color(0xFF9B99FF),
    primaryDark: Color(0xFF7774E8),
    primarySoft: Color(0xFF272553),
    primarySurface: Color(0xFF232145),
    background: Color(0xFF10121A),
    surface: Color(0xFF181B25),
    surfaceAlt: Color(0xFF131620),
    surfaceTint: Color(0xFF202331),
    outline: Color(0xFF2B3040),
    outlineStrong: Color(0xFF454B60),
    textDark: Color(0xFFF4F6FF),
    textMedium: Color(0xFFD8DBEA),
    textLight: Color(0xFFB7BCCF),
    textMuted: Color(0xFFA2A8BC),
    textSubtle: Color(0xFF7F879D),
    textOnPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF65D994),
    successSurface: Color(0xFF143323),
    warning: Color(0xFFF7BC5F),
    warningSurface: Color(0xFF3D2A12),
    danger: Color(0xFFFF8580),
    dangerSurface: Color(0xFF411C1B),
    event: Color(0xFFFF8ABE),
    eventSurface: Color(0xFF3C1930),
    navActive: Color(0xFFB7B5FF),
    navInactive: Color(0xFF8F96AB),
    defaultFieldBorder: Color(0xFF9B99FF),
    defaultFieldBackground: Color(0xFF1A1E2A),
    divider: Color(0xFF2B3040),
    chipSelected: Color(0xFF9B99FF),
    chipUnselected: Color(0xFF1A1E2A),
    chipBorder: Color(0xFF7774E8),
    softSurfaceGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1D2130), Color(0xFF171A24)],
    ),
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8F8DFA), Color(0xFF6865D9)],
    ),
    subtleShadows: [
      BoxShadow(color: Color(0x26000000), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 8)),
    ],
    cardShadows: [
      BoxShadow(color: Color(0x24000000), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(
        color: Color(0x3D000000),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
    floatingShadows: [
      BoxShadow(
        color: Color(0x50000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
      BoxShadow(color: Color(0x339B99FF), blurRadius: 18, offset: Offset(0, 4)),
    ],
  );

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? primarySurface,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceTint,
    Color? outline,
    Color? outlineStrong,
    Color? textDark,
    Color? textMedium,
    Color? textLight,
    Color? textMuted,
    Color? textSubtle,
    Color? textOnPrimary,
    Color? success,
    Color? successSurface,
    Color? warning,
    Color? warningSurface,
    Color? danger,
    Color? dangerSurface,
    Color? event,
    Color? eventSurface,
    Color? navActive,
    Color? navInactive,
    Color? defaultFieldBorder,
    Color? defaultFieldBackground,
    Color? divider,
    Color? chipSelected,
    Color? chipUnselected,
    Color? chipBorder,
    LinearGradient? softSurfaceGradient,
    LinearGradient? brandGradient,
    List<BoxShadow>? subtleShadows,
    List<BoxShadow>? cardShadows,
    List<BoxShadow>? floatingShadows,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      primarySurface: primarySurface ?? this.primarySurface,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      outline: outline ?? this.outline,
      outlineStrong: outlineStrong ?? this.outlineStrong,
      textDark: textDark ?? this.textDark,
      textMedium: textMedium ?? this.textMedium,
      textLight: textLight ?? this.textLight,
      textMuted: textMuted ?? this.textMuted,
      textSubtle: textSubtle ?? this.textSubtle,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      danger: danger ?? this.danger,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      event: event ?? this.event,
      eventSurface: eventSurface ?? this.eventSurface,
      navActive: navActive ?? this.navActive,
      navInactive: navInactive ?? this.navInactive,
      defaultFieldBorder: defaultFieldBorder ?? this.defaultFieldBorder,
      defaultFieldBackground:
          defaultFieldBackground ?? this.defaultFieldBackground,
      divider: divider ?? this.divider,
      chipSelected: chipSelected ?? this.chipSelected,
      chipUnselected: chipUnselected ?? this.chipUnselected,
      chipBorder: chipBorder ?? this.chipBorder,
      softSurfaceGradient: softSurfaceGradient ?? this.softSurfaceGradient,
      brandGradient: brandGradient ?? this.brandGradient,
      subtleShadows: subtleShadows ?? this.subtleShadows,
      cardShadows: cardShadows ?? this.cardShadows,
      floatingShadows: floatingShadows ?? this.floatingShadows,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;

    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textMedium: Color.lerp(textMedium, other.textMedium, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      event: Color.lerp(event, other.event, t)!,
      eventSurface: Color.lerp(eventSurface, other.eventSurface, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      defaultFieldBorder: Color.lerp(
        defaultFieldBorder,
        other.defaultFieldBorder,
        t,
      )!,
      defaultFieldBackground: Color.lerp(
        defaultFieldBackground,
        other.defaultFieldBackground,
        t,
      )!,
      divider: Color.lerp(divider, other.divider, t)!,
      chipSelected: Color.lerp(chipSelected, other.chipSelected, t)!,
      chipUnselected: Color.lerp(chipUnselected, other.chipUnselected, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      softSurfaceGradient: LinearGradient.lerp(
        softSurfaceGradient,
        other.softSurfaceGradient,
        t,
      )!,
      brandGradient: LinearGradient.lerp(
        brandGradient,
        other.brandGradient,
        t,
      )!,
      subtleShadows: t < 0.5 ? subtleShadows : other.subtleShadows,
      cardShadows: t < 0.5 ? cardShadows : other.cardShadows,
      floatingShadows: t < 0.5 ? floatingShadows : other.floatingShadows,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appColors {
    return Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
  }
}
