import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme_extension.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const SearchField({
    super.key,
    required this.controller,
    this.hint = 'Pesquise por disciplina',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      height: 49,
      decoration: BoxDecoration(
        color: appTheme.card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: appTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          color: appTheme.textPrimary,
          fontSize: 15,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.primary.withValues(alpha: 0.5),
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.47,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary.withValues(alpha: 0.5),
            size: 22,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
