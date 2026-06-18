// Campo de busca com ícone de lupa e placeholder roxo translúcido.
import 'package:flutter/material.dart';

import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_theme_colors.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final double height;

  const SearchField({
    super.key,
    required this.controller,
    this.hint = 'Pesquise por disciplina',
    this.onChanged,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: 1,
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0x66000000)
          : const Color(0x10111827),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.outline),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            color: colors.textDark,
            fontSize: 15,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colors.textSubtle,
              fontSize: 15,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              height: 1.47,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(Icons.search, color: colors.primary, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 48,
            ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
