import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primária
  static const Color primary = Color(0xFF514EB6);

  // Fundo
  static const Color background = Color(0xFFF8F9FF);

  // Textos
  static const Color textDark = Color(0xFF191820);
  static const Color textMedium = Color(0xFF444444);
  static const Color textLight = Color(0xFF6B6B6B);
  static const Color textMuted = Color(0xFF656565);
  static const Color textOnPrimary = Color(0xFFE7E7E7);

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
  static const Color shadowPrimary = Color(0x4C514EB6);
  static const Color shadowDark = Color(0x3F000000);

  // Divisor
  static const Color divider = Color(0xFF514EB6);

  // Chip selecionado / não selecionado
  static const Color chipSelected = Color(0xFF514EB6);
  static const Color chipUnselected = Color(0xFFF8F9FF);
  static const Color chipBorder = Color(0xFF514EB6);
}
