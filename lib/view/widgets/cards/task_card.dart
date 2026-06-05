// Card de tarefa com checkbox, título, disciplina e prazo.
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
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
    return visualPriority == 'Prova'
        ? Icons.edit_square
        : Icons.assignment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF0FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E4F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33587DBD),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 5,
                child: ColoredBox(
                  color: isChecked
                      ? const Color(0xFF8BC2A3)
                      : AppColors.primary,
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
                            color: const Color(0xFFF8F9FF),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0x4C514EB6),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Checkbox(
                            value: isChecked,
                            onChanged: onChanged,
                            activeColor: AppColors.primary,
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
                                  color: const Color(0xFF191820),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
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
                                      ? const Color(0xFF27724D)
                                      : AppColors.primary,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
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
