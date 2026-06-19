import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme_extension.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String subject;
  final String deadline;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subject,
    required this.deadline,
    this.isChecked = false,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: ShapeDecoration(
                  color: appTheme.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Checkbox(
                  value: isChecked,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: appTheme.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.38,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: appTheme.textMuted,
                      ),
                    ),
                    Text(
                      'Disciplina: $subject',
                      style: TextStyle(
                        color: appTheme.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.57,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: appTheme.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Prazo: $deadline',
                    style: TextStyle(
                      color: appTheme.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
