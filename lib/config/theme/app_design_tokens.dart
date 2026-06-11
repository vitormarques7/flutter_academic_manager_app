import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0A111827), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x10111827), blurRadius: 12, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x07111827), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x14111827), blurRadius: 18, offset: Offset(0, 9)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F111827), blurRadius: 20, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x1F514EB6), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

class AppGradients {
  AppGradients._();

  static const LinearGradient softSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFBFCFF)],
  );

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, Color(0xFF4845AA)],
  );
}
