// Chip de filtro com label e ícone de dropdown, usado na tela de tarefas.
import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';

class TaskFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const TaskFilterChip({super.key, this.label = 'Todas', this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.surfaceTint,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colors.outline),
          boxShadow: colors.subtleShadows,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.textDark,
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                height: 1.47,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: colors.textDark, size: 20),
          ],
        ),
      ),
    );
  }
}
