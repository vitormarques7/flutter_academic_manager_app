import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/theme/app_colors.dart';
import '../../models/academic_subject.dart';
import '../../models/academic_task.dart';
import '../../repositories/subject_repository.dart';
import '../../repositories/task_repository.dart';
import '../../config/theme/app_theme_extension.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/page_header.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _taskRepository = TaskRepository();
  final _subjectRepository = SubjectRepository();

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _focusedDay = today;
    _selectedDay = today;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<AcademicSubject>>(
        stream: _subjectRepository.watchSubjects(),
        builder: (context, subjectsSnapshot) {
          return StreamBuilder<List<AcademicTask>>(
            stream: _taskRepository.watchTasks(),
            builder: (context, tasksSnapshot) {
              final isLoading =
                  (subjectsSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !subjectsSnapshot.hasData) ||
                  (tasksSnapshot.connectionState == ConnectionState.waiting &&
                      !tasksSnapshot.hasData);

              final subjects = subjectsSnapshot.data ?? [];
              final tasks = tasksSnapshot.data ?? [];
              final selectedActivities = _activitiesForDay(
                _selectedDay,
                subjects: subjects,
                tasks: tasks,
              );

              if (subjectsSnapshot.hasError || tasksSnapshot.hasError) {
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(title: 'Seu Horário'),
                        SizedBox(height: 24),
                        EmptyStateCard(
                          icon: Icons.cloud_off_outlined,
                          title: 'Erro ao carregar o horário',
                          subtitle:
                              'Não foi possível carregar suas aulas e tarefas agora.',
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PageHeader(title: 'Seu Horário'),
                      const SizedBox(height: 24),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else ...[
                        _CalendarCard(
                          focusedDay: _focusedDay,
                          selectedDay: _selectedDay,
                          calendarFormat: _calendarFormat,
                          subjects: subjects,
                          tasks: tasks,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = _dateOnly(selectedDay);
                              _focusedDay = focusedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() => _focusedDay = focusedDay);
                          },
                          onFormatChanged: (format) {
                            setState(() => _calendarFormat = format);
                          },
                        ),
                        const SizedBox(height: 24),
                        _DayActivitiesSection(
                          selectedDay: _selectedDay,
                          activities: selectedActivities,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class ScheduleActivity {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;

  const ScheduleActivity({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isCompleted = false,
  });
}

List<ScheduleActivity> _activitiesForDay(
  DateTime day, {
  required List<AcademicSubject> subjects,
  required List<AcademicTask> tasks,
}) {
  final normalizedDay = DateTime(day.year, day.month, day.day);
  final activities = <ScheduleActivity>[];

  for (final task in tasks) {
    final deadline = _parseDeadline(task.deadline);
    if (deadline == null || !isSameDay(deadline, normalizedDay)) continue;

    activities.add(
      ScheduleActivity(
        title: task.title,
        subtitle: task.isChecked
            ? 'Concluída · ${task.subject.isEmpty ? 'Tarefa' : task.subject}'
            : task.subject.isEmpty
                ? 'Tarefa'
                : 'Tarefa · ${task.subject}',
        icon: task.isChecked
            ? Icons.check_circle_outline
            : task.visualPriority == 'Prova'
                ? Icons.edit_square
                : Icons.assignment_outlined,
        isCompleted: task.isChecked,
      ),
    );
  }

  for (final subject in subjects) {
    for (final entry in subject.schedule) {
      if (!_scheduleMatchesDay(entry, normalizedDay)) continue;

      final startTime = entry['startTime'] as String? ?? '';
      final endTime = entry['endTime'] as String? ?? '';
      final timeLabel = startTime.isEmpty && endTime.isEmpty
          ? 'Aula'
          : 'Aula · $startTime${endTime.isEmpty ? '' : ' - $endTime'}';

      activities.add(
        ScheduleActivity(
          title: subject.name,
          subtitle: timeLabel,
          icon: Icons.school_outlined,
        ),
      );
    }
  }

  return activities;
}

bool _scheduleMatchesDay(Map<String, dynamic> entry, DateTime day) {
  final weekdayIndex = entry['weekdayIndex'];
  if (weekdayIndex is! int) return false;

  return _weekdayIndexFromDate(day) == weekdayIndex;
}

int _weekdayIndexFromDate(DateTime day) {
  return day.weekday == DateTime.sunday ? 0 : day.weekday;
}

DateTime? _parseDeadline(String deadline) {
  final parts = deadline.split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) return null;

  return DateTime(year, month, day);
}

class _CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final List<AcademicSubject> subjects;
  final List<AcademicTask> tasks;
  final OnDaySelected onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final ValueChanged<CalendarFormat> onFormatChanged;

  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.subjects,
    required this.tasks,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: appTheme.inputBorder),
        boxShadow: [
          BoxShadow(
            color: appTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<ScheduleActivity>(
        locale: 'pt_BR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarFormat: calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Mês',
          CalendarFormat.twoWeeks: '2 semanas',
        },
        availableGestures: AvailableGestures.horizontalSwipe,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        eventLoader: (day) => _activitiesForDay(
          day,
          subjects: subjects,
          tasks: tasks,
        ),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        onFormatChanged: onFormatChanged,
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: false,
          formatButtonDecoration: BoxDecoration(
            color: appTheme.badgeBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          formatButtonTextStyle: TextStyle(
            color: appTheme.textPrimary,
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
          titleTextStyle: TextStyle(
            color: appTheme.textPrimary,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: appTheme.textPrimary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: appTheme.textPrimary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: _calendarLabelStyle(
            color: appTheme.textMuted,
          ),
          weekendStyle: _calendarLabelStyle(color: AppColors.primary),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          cellMargin: const EdgeInsets.all(6),
          defaultTextStyle: _dayTextStyle(color: appTheme.textPrimary),
          weekendTextStyle: _dayTextStyle(color: AppColors.primary),
          outsideTextStyle: _dayTextStyle(color: appTheme.textMuted),
          selectedTextStyle: _dayTextStyle(color: Colors.white),
          todayTextStyle: _dayTextStyle(color: AppColors.primary),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,
          markersMaxCount: 4,
          markerSize: 5,
          markerMargin: const EdgeInsets.only(top: 4),
        ),
      ),
    );
  }

  static TextStyle _calendarLabelStyle({required Color color}) {
    return TextStyle(
      color: color,
      fontSize: 13,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle _dayTextStyle({required Color color}) {
    return TextStyle(
      color: color,
      fontSize: 15,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
    );
  }
}

class _DayActivitiesSection extends StatelessWidget {
  final DateTime selectedDay;
  final List<ScheduleActivity> activities;

  const _DayActivitiesSection({
    required this.selectedDay,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final dayLabel = _selectedDayLabel(selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dayLabel,
          style: TextStyle(
            color: appTheme.textPrimary,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          const _ActivityCard(
            title: 'Nenhuma atividade para este dia.',
            subtitle: 'Tarefas com prazo ou aulas cadastradas aparecerão aqui.',
            icon: Icons.event_busy_outlined,
            isPlaceholder: true,
          )
        else
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityCard(
                title: activity.title,
                subtitle: activity.subtitle,
                icon: activity.icon,
                isCompleted: activity.isCompleted,
              ),
            ),
          ),
      ],
    );
  }

  String _selectedDayLabel(DateTime day) {
    if (isSameDay(day, DateTime.now())) {
      return 'Atividades de hoje';
    }

    final formatted = DateFormat("d 'de' MMMM", 'pt_BR').format(day);
    return 'Atividades de $formatted';
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPlaceholder;
  final bool isCompleted;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPlaceholder = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Opacity(
      opacity: isCompleted ? 0.72 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isCompleted
              ? appTheme.inputFill
              : appTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.primary.withValues(alpha: 0.35)
                : appTheme.inputBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: appTheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPlaceholder
                  ? appTheme.textMuted
                  : isCompleted
                      ? AppColors.primary.withValues(alpha: 0.7)
                      : AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isPlaceholder
                          ? appTheme.textMuted
                          : appTheme.textPrimary,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: appTheme.textMuted,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isCompleted
                            ? AppColors.primary.withValues(alpha: 0.85)
                            : appTheme.textMuted,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: isCompleted
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isCompleted)
              Icon(
                Icons.check_circle,
                color: AppColors.primary.withValues(alpha: 0.85),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
