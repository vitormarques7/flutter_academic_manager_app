// Card de disciplina com nome, professor, barra de frequência e média atual.
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_theme_colors.dart';
import '../common/app_surface.dart';
import '../common/metadata_chip.dart';

class SubjectCard extends StatelessWidget {
  final String name;
  final String teacher;
  final double frequency;
  final double average;
  final int? workload;
  final VoidCallback? onTap;
  final Color accentColor;
  final bool showFrequency;

  const SubjectCard({
    super.key,
    required this.name,
    required this.teacher,
    required this.frequency,
    required this.average,
    this.workload,
    this.onTap,
    this.accentColor = AppColors.primary,
    this.showFrequency = true,
  });

  Color get _averageColor {
    if (average >= 7) return const Color(0xFF27724D);
    if (average >= 5) return const Color(0xFF9A6A00);
    return const Color(0xFF9A2828);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveAccentColor = accentColor == AppColors.primary
        ? colors.primary
        : accentColor;
    final percentLabel = '${(frequency * 100).round()}%';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AppSurface.card(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: effectiveAccentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: effectiveAccentColor.withValues(alpha: 0.28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveAccentColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: effectiveAccentColor,
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
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 17,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        height: 1.26,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      teacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textMedium,
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    if (showFrequency) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Frequência',
                            style: TextStyle(
                              color: colors.textMedium,
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            percentLabel,
                            style: TextStyle(
                              color: colors.textMedium,
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
                          backgroundColor: colors.primary.withValues(
                            alpha: 0.12,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            effectiveAccentColor,
                          ),
                        ),
                      ),
                    ],
                    if (workload != null) ...[
                      const SizedBox(height: 10),
                      MetadataChip(
                        icon: Icons.access_time,
                        label: '${workload}h',
                        foregroundColor: effectiveAccentColor,
                        backgroundColor: effectiveAccentColor.withValues(
                          alpha: 0.08,
                        ),
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
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.outline),
                  boxShadow: colors.subtleShadows,
                ),
                child: Column(
                  children: [
                    Text(
                      'Média',
                      maxLines: 1,
                      style: TextStyle(
                        color: colors.textMedium,
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
