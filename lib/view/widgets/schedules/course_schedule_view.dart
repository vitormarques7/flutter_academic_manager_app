import 'package:flutter/material.dart';

import '../../../config/scroll/app_scroll_behavior.dart';
import '../../../config/theme/app_theme_colors.dart';
import '../common/empty_state_card.dart';
import 'current_period_schedule.dart';
import 'schedule_models.dart';

class CourseScheduleView extends StatelessWidget {
  final List<ScheduleDay> days;
  final String subtitle;
  final String shiftLabel;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const CourseScheduleView({
    super.key,
    required this.days,
    required this.subtitle,
    required this.shiftLabel,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CourseScheduleHeader(subtitle: subtitle, onBack: onBack),
                    const SizedBox(height: 16),
                    _ScheduleStats(days: days, shiftLabel: shiftLabel),
                    const SizedBox(height: 14),
                    if (days.isEmpty)
                      const EmptyStateCard(
                        message: 'Nenhum horário cadastrado ainda.',
                        icon: Icons.calendar_month_outlined,
                      )
                    else
                      CurrentPeriodSchedule(days: days, onEdit: onEdit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseScheduleHeader extends StatelessWidget {
  final String subtitle;
  final VoidCallback onBack;

  const _CourseScheduleHeader({required this.subtitle, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
        boxShadow: colors.subtleShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tooltip(
                message: 'Voltar',
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: colors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Grade de horários',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 26,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleStats extends StatelessWidget {
  final List<ScheduleDay> days;
  final String shiftLabel;

  const _ScheduleStats({required this.days, required this.shiftLabel});

  @override
  Widget build(BuildContext context) {
    final classCount = days.fold<int>(
      0,
      (count, day) => count + day.classes.length,
    );
    return Row(
      children: [
        Expanded(
          child: _ScheduleStatChip(
            icon: Icons.view_week_outlined,
            label: 'Semana',
            value: '$classCount ${classCount == 1 ? 'aula' : 'aulas'}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ScheduleStatChip(
            icon: Icons.wb_sunny_outlined,
            label: 'Turno',
            value: shiftLabel,
          ),
        ),
      ],
    );
  }
}

class _ScheduleStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ScheduleStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
        boxShadow: colors.subtleShadows,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 11,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
