// Card de tarefa com checkbox, título, disciplina e prazo.
import 'package:flutter/material.dart';
import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_theme_colors.dart';
import '../common/app_surface.dart';
import '../common/metadata_chip.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String subject;
  final String deadline;
  final String visualPriority;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subject,
    required this.deadline,
    this.visualPriority = 'Trabalho',
    this.isChecked = false,
    this.onChanged,
    this.onTap,
  });

  IconData get _priorityIcon {
    return switch (visualPriority) {
      'Prova' => Icons.edit_square,
      'Estudo' => Icons.school_outlined,
      'Seminário' => Icons.co_present_outlined,
      'Leitura' => Icons.menu_book_outlined,
      'Pesquisa' => Icons.search_outlined,
      _ => Icons.assignment_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AppSurface.card(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: ColoredBox(
                  color: isChecked ? colors.success : colors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: ShapeDecoration(
                            color: isChecked
                                ? colors.successSurface
                                : colors.surface,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: isChecked
                                    ? colors.success.withValues(alpha: 0.22)
                                    : colors.outlineStrong.withValues(
                                        alpha: 0.72,
                                      ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x06111827),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Checkbox(
                            value: isChecked,
                            onChanged: onChanged,
                            activeColor: colors.primary,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textDark,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                  height: 1.28,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationThickness: 2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isChecked ? 'Concluída' : 'Pendente',
                                style: TextStyle(
                                  color: isChecked
                                      ? colors.success
                                      : colors.primary,
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                  height: 1.20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MetadataChip(
                          icon: Icons.school_outlined,
                          label: subject,
                          maxWidth: 220,
                        ),
                        MetadataChip(
                          icon: Icons.access_time,
                          label: deadline,
                          maxWidth: 220,
                        ),
                        MetadataChip(
                          icon: _priorityIcon,
                          label: visualPriority,
                          foregroundColor: isChecked
                              ? colors.success
                              : colors.primary,
                          backgroundColor: isChecked
                              ? colors.successSurface
                              : colors.primary.withValues(alpha: 0.10),
                          maxWidth: 220,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
