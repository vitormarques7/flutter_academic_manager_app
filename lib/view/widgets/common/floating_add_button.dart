// Botão flutuante de adição ("+") usado nas telas de disciplinas e tarefas.
import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.primary,
      shape: const CircleBorder(),
      elevation: 5,
      shadowColor: colors.primary.withValues(alpha: 0.24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 56,
          height: 56,
          decoration: ShapeDecoration(
            color: colors.primary,
            shape: OvalBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            ),
            shadows: colors.floatingShadows,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
