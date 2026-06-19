import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_extension.dart';

class TaskFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const TaskFilterChip({super.key, this.label = 'Todas', this.onTap});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: appTheme.textPrimary,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.47,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: appTheme.textPrimary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
