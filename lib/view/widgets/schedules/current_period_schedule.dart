import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';
import 'schedule_models.dart';

class CurrentPeriodSchedule extends StatelessWidget {
  final List<ScheduleDay> days;
  final VoidCallback onEdit;

  const CurrentPeriodSchedule({
    super.key,
    required this.days,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
        boxShadow: colors.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suas Aulas',
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _EditScheduleButton(onTap: onEdit),
            ],
          ),
          const SizedBox(height: 12),
          const _CurrentPeriodTableHeader(),
          const SizedBox(height: 8),
          Column(
            children: List.generate(days.length, (index) {
              final day = days[index];
              final isLast = index == days.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: _ScheduleDaySection(day: day),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CurrentPeriodTableHeader extends StatelessWidget {
  const _CurrentPeriodTableHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          SizedBox(width: 80, child: _HeaderLabel('Dia')),
          SizedBox(width: 88, child: _HeaderLabel('Horário')),
          Expanded(child: _HeaderLabel('Aula')),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String label;

  const _HeaderLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.textOnPrimary,
          fontSize: 12,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScheduleDaySection extends StatelessWidget {
  final ScheduleDay day;

  const _ScheduleDaySection({required this.day});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceTint,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DayLabel(day: day),
            Expanded(
              child: Column(
                children: List.generate(day.classes.length, (index) {
                  final classInfo = day.classes[index];
                  final isLast = index == day.classes.length - 1;

                  return Column(
                    children: [
                      _PeriodClassRow(classInfo: classInfo),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: colors.primary.withValues(alpha: 0.14),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final ScheduleDay day;

  const _DayLabel({required this.day});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 80,
      color: colors.primarySurface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.weekday.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.primary,
              fontSize: 11,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${day.classes.length} ${day.classes.length == 1 ? 'aula' : 'aulas'}',
              maxLines: 1,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 10,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodClassRow extends StatelessWidget {
  final PeriodScheduleClass classInfo;

  const _PeriodClassRow({required this.classInfo});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeBadge(timeRange: classInfo.timeRange),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              decoration: BoxDecoration(
                color: classInfo.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: classInfo.accentColor.withValues(alpha: 0.24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 46,
                    decoration: BoxDecoration(
                      color: classInfo.accentColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                classInfo.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textDark,
                                  fontSize: 13,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  height: 1.12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _ShortTitleChip(
                              label: classInfo.shortTitle,
                              color: classInfo.accentColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          classInfo.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 11,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                        if (classInfo.note != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            classInfo.note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: classInfo.accentColor,
                              fontSize: 10,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String timeRange;

  const _TimeBadge({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final parts = timeRange.split(' - ');

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            parts.first,
            maxLines: 1,
            style: TextStyle(
              color: colors.textDark,
              fontSize: 13,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 18,
            height: 1,
            color: colors.primary.withValues(alpha: 0.20),
          ),
          const SizedBox(height: 3),
          Text(
            parts.length > 1 ? parts.last : '',
            maxLines: 1,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortTitleChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ShortTitleChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      constraints: const BoxConstraints(maxWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _EditScheduleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditScheduleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Tooltip(
      message: 'Editar grade',
      child: Material(
        color: colors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: colors.primary.withValues(alpha: 0.24),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.edit_outlined,
              color: colors.textOnPrimary,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}
