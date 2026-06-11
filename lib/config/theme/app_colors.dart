import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primária
  static const Color primary = Color(0xFF514EB6);
  static const Color primaryDark = Color(0xFF37318E);
  static const Color primarySoft = Color(0xFFEDEBFF);
  static const Color primarySurface = Color(0xFFF1F0FF);

  // Fundo
  static const Color background = Color(0xFFF7F8FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3FB);
  static const Color surfaceTint = Color(0xFFEFF0FB);
  static const Color outline = Color(0xFFE0E4F2);
  static const Color outlineStrong = Color(0xFFC9CEE6);

  // Textos
  static const Color textDark = Color(0xFF191820);
  static const Color textMedium = Color(0xFF3E3D4A);
  static const Color textLight = Color(0xFF6B6F80);
  static const Color textMuted = Color(0xFF6B6F80);
  static const Color textSubtle = Color(0xFF8D91A3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Estados
  static const Color success = Color(0xFF16834A);
  static const Color successSurface = Color(0xFFEAF7EF);
  static const Color warning = Color(0xFFB45309);
  static const Color warningSurface = Color(0xFFFFF4E5);
  static const Color danger = Color(0xFFB42318);
  static const Color dangerSurface = Color(0xFFFFEDEB);
  static const Color event = Color(0xFFDB2777);
  static const Color eventSurface = Color(0xFFFFEAF3);

  // Navegação (bottom nav bar)
  static const Color navActive = Color(0xFF514EB6);
  static const Color navInactive = Color(0xFF656565);

  // Campos de texto (telas de auth — fundo roxo)
  static const Color authFieldBackground = Color(0xFF5F5CC4);
  static const Color authFieldBorder = Color(0xFFFFFFFF);

  // Campos de texto (telas de setup — fundo claro)
  static const Color defaultFieldBorder = Color(0xFF514EB6);
  static const Color defaultFieldBackground = Color(0xFFF8F9FF);

  // Sombra
  static const Color shadowPrimary = Color(0x2E514EB6);
  static const Color shadowDark = Color(0x1F111827);

  // Divisor
  static const Color divider = Color(0xFFE0E4F2);

  // Chip selecionado / não selecionado
  static const Color chipSelected = Color(0xFF514EB6);
  static const Color chipUnselected = Color(0xFFF8F9FF);
  static const Color chipBorder = Color(0xFF514EB6);
}
