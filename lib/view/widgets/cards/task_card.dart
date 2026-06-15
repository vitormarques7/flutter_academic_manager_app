// Card de tarefa com checkbox, título, disciplina e prazo.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return Opacity(
      opacity: isChecked ? 0.6 : 1.0,
      child: Material(
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
                          AnimatedScale(
                            scale: isChecked ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOutBack,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: ShapeDecoration(
                                color: isChecked
                                    ? colors.successSurface
                                    : colors.surface,
                                shape: RoundedRectangleBorder(
                                  side: isChecked
                                      ? BorderSide(
                                          width: 1,
                                          color: colors.success.withValues(alpha: 0.22),
                                        )
                                      : BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Checkbox(
                                value: isChecked,
                                onChanged: onChanged == null
                                    ? null
                                    : (val) {
                                        HapticFeedback.lightImpact();
                                        onChanged!(val);
                                      },
                                activeColor: colors.success,
                                side: isChecked
                                    ? BorderSide.none
                                    : BorderSide(
                                        color: colors.outlineStrong,
                                        width: 1.5,
                                      ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
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
                            foregroundColor: isChecked ? colors.textMuted : null,
                            backgroundColor: isChecked ? colors.surfaceAlt : null,
                          ),
                          MetadataChip(
                            icon: Icons.access_time,
                            label: deadline,
                            maxWidth: 220,
                            foregroundColor: isChecked ? colors.textMuted : null,
                            backgroundColor: isChecked ? colors.surfaceAlt : null,
                          ),
                          MetadataChip(
                            icon: _priorityIcon,
                            label: visualPriority,
                            foregroundColor: isChecked
                                ? colors.textMuted
                                : colors.primary,
                            backgroundColor: isChecked
                                ? colors.surfaceAlt
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
      ),
    );
  }
}
