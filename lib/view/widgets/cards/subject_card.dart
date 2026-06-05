// Card de disciplina com nome, professor, barra de frequência e média atual.
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../common/metadata_chip.dart';

class SubjectCard extends StatelessWidget {
  final String name;
  final String teacher;
  final double frequency;
  final double average;
  final int? workload;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.name,
    required this.teacher,
    required this.frequency,
    required this.average,
    this.workload,
    this.onTap,
  });

  Color get _averageColor {
    if (average >= 7) return const Color(0xFF27724D);
    if (average >= 5) return const Color(0xFF9A6A00);
    return const Color(0xFF9A2828);
  }

  @override
  Widget build(BuildContext context) {
    final percentLabel = '${(frequency * 100).round()}%';

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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x4C514EB6)),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF191820),
                        fontSize: 17,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.26,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      teacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF464552),
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Frequência',
                          style: TextStyle(
                            color: Color(0xFF464552),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          percentLabel,
                          style: const TextStyle(
                            color: Color(0xFF464552),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: LinearProgressIndicator(
                        value: frequency.clamp(0.0, 1.0).toDouble(),
                        minHeight: 8,
                        backgroundColor: const Color(0x33514EB6),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    if (workload != null) ...[
                      const SizedBox(height: 10),
                      MetadataChip(
                        icon: Icons.access_time,
                        label: '${workload}h',
                        iconSize: 15,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 76,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E4F0)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Média',
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFF464552),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      average.toStringAsFixed(1),
                      style: TextStyle(
                        color: _averageColor,
                        fontSize: 32,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
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
