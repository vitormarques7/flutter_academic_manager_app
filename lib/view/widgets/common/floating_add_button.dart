// Botão flutuante de adição ("+") usado nas telas de disciplinas e tarefas.
import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_design_tokens.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 5,
      shadowColor: AppColors.primary.withValues(alpha: 0.24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 56,
          height: 56,
          decoration: ShapeDecoration(
            color: AppColors.primary,
            shape: OvalBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            ),
            shadows: AppShadows.floating,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
