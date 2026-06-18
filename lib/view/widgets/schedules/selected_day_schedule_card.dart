import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_theme_colors.dart';
import '../common/app_surface.dart';
import 'schedule_models.dart';

class SelectedDayScheduleCard extends StatelessWidget {
  final DateTime selectedDay;
  final List<ScheduleClassInfo> classes;
  final List<ScheduleEventInfo> events;
  final List<ScheduleTaskInfo> tasks;

  const SelectedDayScheduleCard({
    super.key,
    required this.selectedDay,
    required this.classes,
    this.events = const [],
    this.tasks = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasClasses = classes.isNotEmpty;
    final hasEvents = events.isNotEmpty;
    final hasTasks = tasks.isNotEmpty;

    final sections = <Widget>[
      if (hasClasses)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardSectionLabel('Aulas'),
            const SizedBox(height: 12),
            ...classes.asMap().entries.map((entry) {
              final index = entry.key;
              final classInfo = entry.value;
              final isLast = index == classes.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                child: _ScheduleClassRow(classInfo: classInfo),
              );
            }),
          ],
        ),
      if (hasEvents)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardSectionLabel('Eventos'),
            const SizedBox(height: 12),
            ...events.asMap().entries.map((entry) {
              final index = entry.key;
              final eventInfo = entry.value;
              final isLast = index == events.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                child: _ScheduleEventRow(eventInfo: eventInfo),
              );
            }),
          ],
        ),
      if (hasTasks)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardSectionLabel('Tarefas'),
            const SizedBox(height: 12),
            ...tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final taskInfo = entry.value;
              final isLast = index == tasks.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                child: _ScheduleTaskRow(taskInfo: taskInfo),
              );
            }),
          ],
        ),
    ];

    return _RaisedCard(
      minHeight: 218,
      padding: const EdgeInsets.fromLTRB(17, 24, 17, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedDayTitle(selectedDay),
            style: TextStyle(
              color: colors.textDark,
              fontSize: 15,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          if (!hasClasses && !hasEvents && !hasTasks)
            const _EmptyScheduleMessage()
          else ...[
            for (int i = 0; i < sections.length; i++) ...[
              sections[i],
              if (i < sections.length - 1) ...[
                const SizedBox(height: 18),
                Divider(height: 1, color: colors.divider),
                const SizedBox(height: 18),
              ],
            ],
          ],
        ],
      ),
    );
  }

  String _selectedDayTitle(DateTime day) {
    final weekday = DateFormat.EEEE('pt_BR').format(day);
    final capitalizedWeekday =
        '${weekday[0].toUpperCase()}${weekday.substring(1)}';
    final month = DateFormat.MMMM('pt_BR').format(day);
    final capitalizedMonth = '${month[0].toUpperCase()}${month.substring(1)}';

    return '$capitalizedWeekday, ${day.day} de $capitalizedMonth';
  }
}

class _CardSectionLabel extends StatelessWidget {
  final String label;

  const _CardSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text(
      label,
      style: TextStyle(
        color: colors.textMedium,
        fontSize: 12,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ScheduleClassRow extends StatelessWidget {
  final ScheduleClassInfo classInfo;

  const _ScheduleClassRow({required this.classInfo});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: classInfo.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 37,
                decoration: BoxDecoration(
                  color: classInfo.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: classInfo.iconBackground,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: classInfo.iconColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  classInfo.icon,
                  color: classInfo.iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      classInfo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      classInfo.timeRange,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.05,
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

class _ScheduleEventRow extends StatelessWidget {
  final ScheduleEventInfo eventInfo;

  const _ScheduleEventRow({required this.eventInfo});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitleParts = [
      eventInfo.typeLabel,
      if (eventInfo.subject.isNotEmpty) eventInfo.subject,
      if (eventInfo.timeRange.isNotEmpty) eventInfo.timeRange,
    ];
    final subtitle = subtitleParts.join(' • ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: eventInfo.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: eventInfo.description.isEmpty ? 44 : 58,
                decoration: BoxDecoration(
                  color: eventInfo.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: eventInfo.iconBackground,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: eventInfo.iconColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  eventInfo.icon,
                  color: eventInfo.iconColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventInfo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.05,
                      ),
                    ),
                    if (eventInfo.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        eventInfo.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.25,
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
    );
  }
}

class _ScheduleTaskRow extends StatelessWidget {
  final ScheduleTaskInfo taskInfo;

  const _ScheduleTaskRow({required this.taskInfo});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = taskInfo.subject.isEmpty
        ? taskInfo.typeLabel
        : '${taskInfo.typeLabel} • ${taskInfo.subject}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: taskInfo.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 44,
                decoration: BoxDecoration(
                  color: taskInfo.isChecked
                      ? colors.success
                      : taskInfo.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: taskInfo.isChecked
                      ? colors.successSurface
                      : taskInfo.iconBackground,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (taskInfo.isChecked
                                  ? colors.success
                                  : taskInfo.iconColor)
                              .withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  taskInfo.isChecked
                      ? Icons.check_circle_outline_rounded
                      : taskInfo.icon,
                  color: taskInfo.isChecked
                      ? colors.success
                      : taskInfo.iconColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      taskInfo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        decoration: taskInfo.isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationThickness: 2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.05,
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

class _EmptyScheduleMessage extends StatelessWidget {
  const _EmptyScheduleMessage();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.surfaceTint,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        'Nenhum horário, evento ou tarefa para este dia',
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 13,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _RaisedCard extends StatelessWidget {
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _RaisedCard({
    required this.minHeight,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface.card(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      borderRadius: AppRadius.lg,
      child: child,
    );
  }
}
