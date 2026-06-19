// Botão flutuante de adição ("+") usado nas telas de disciplinas e tarefas.
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme_extension.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: ShapeDecoration(
          color: appTheme.fabBackground,
          shape: const OvalBorder(),
          shadows: [
            BoxShadow(
              color: appTheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.primary, size: 28),
      ),
    );
  }
}
