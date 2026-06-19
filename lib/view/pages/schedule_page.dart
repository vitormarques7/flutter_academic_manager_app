import 'package:flutter/material.dart';

import '../../config/routes/app_routes.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../models/academic_task.dart';
import '../../models/discipline.dart';
import '../../models/schedule.dart';
import '../../models/study_cycle.dart';
import '../../models/study_topic.dart';
import '../../models/subject_event.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/study_topic_repository.dart';
import '../../repositories/subject_event_repository.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'subject_details_page.dart';
import 'subject_event_details_page.dart';
import 'task_details_page.dart';
import '../widgets/common/floating_add_button.dart';
import '../widgets/dialogs/schedule_event_dialog.dart';
import '../widgets/dialogs/task_dialog.dart';
import '../widgets/schedules/course_schedule_view.dart';
import '../widgets/schedules/month_calendar.dart';
import '../widgets/schedules/schedule_header.dart';
import '../widgets/schedules/schedule_editor_sheet.dart';
import '../widgets/schedules/schedule_models.dart';
import '../widgets/schedules/selected_day_schedule_card.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final DisciplineRepository _disciplineRepository = DisciplineRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final SubjectEventRepository _eventRepository = SubjectEventRepository();
  final StudyCycleRepository _studyCycleRepository = StudyCycleRepository();
  final StudyTopicRepository _studyTopicRepository = StudyTopicRepository();
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final TaskRepository _taskRepository = TaskRepository();
  late Future<_ActiveStudyCycleInfo> _activeStudyCycleInfoFuture;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isShowingCourseSchedule = false;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _focusedDay = today;
    _selectedDay = today;
    _activeStudyCycleInfoFuture = _loadActiveStudyCycleInfo();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return FutureBuilder<_ActiveStudyCycleInfo>(
      future: _activeStudyCycleInfoFuture,
      builder: (context, activeCycleSnapshot) {
        if (activeCycleSnapshot.connectionState == ConnectionState.waiting) {
          return const _ScheduleLoadingScaffold();
        }

        if (activeCycleSnapshot.hasError) {
          return _ScheduleErrorScaffold(onRetry: _reloadActiveStudyCycle);
        }

        final activeStudyCycleInfo =
            activeCycleSnapshot.data ?? const _ActiveStudyCycleInfo();
        final isIndependent =
            activeStudyCycleInfo.type == StudyCycleType.independent;

        return StreamBuilder<List<Schedule>>(
          stream: _scheduleRepository.watchSchedules(
            studyCycleId: activeStudyCycleInfo.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _ScheduleLoadingScaffold();
            }

            if (snapshot.hasError) {
              return _ScheduleErrorScaffold(onRetry: _reloadActiveStudyCycle);
            }

            final schedules = isIndependent
                ? const <Schedule>[]
                : (snapshot.data ?? []);

            return StreamBuilder<List<Discipline>>(
              stream: _disciplineRepository.watchDisciplines(
                studyCycleId: activeStudyCycleInfo.id,
              ),
              builder: (context, disciplineSnapshot) {
                final disciplines =
                    disciplineSnapshot.data ?? const <Discipline>[];
                final disciplineColors = _disciplineColorsForSchedules(
                  schedules,
                  disciplines,
                );
                final courseScheduleDays = _scheduleDaysFromSchedules(
                  schedules,
                  disciplineColors,
                  disciplines,
                );

                if (_isShowingCourseSchedule && !isIndependent) {
                  return CourseScheduleView(
                    days: courseScheduleDays,
                    subtitle: activeStudyCycleInfo.label,
                    shiftLabel: _shiftLabelFromSchedules(schedules),
                    onBack: () =>
                        setState(() => _isShowingCourseSchedule = false),
                    onEdit: () => _openScheduleEditor(
                      activeStudyCycleInfo: activeStudyCycleInfo,
                      schedules: schedules,
                      disciplines: disciplines,
                    ),
                  );
                }

                return StreamBuilder<List<SubjectEvent>>(
                  stream: _eventRepository.watchEvents(
                    studyCycleId: activeStudyCycleInfo.id,
                    upcomingOnly: true,
                  ),
                  builder: (context, eventSnapshot) {
                    final events = eventSnapshot.data ?? const <SubjectEvent>[];
                    final selectedClasses = _classesForDay(
                      schedules,
                      _selectedDay,
                      disciplineColors,
                      disciplines,
                    );
                    final selectedEvents = _eventsForDay(
                      events,
                      _selectedDay,
                      disciplineColors,
                    );

                    return StreamBuilder<List<AcademicTask>>(
                      stream: _taskRepository.watchTasks(
                        studyCycleId: activeStudyCycleInfo.id,
                      ),
                      builder: (context, taskSnapshot) {
                        final tasks =
                            taskSnapshot.data ?? const <AcademicTask>[];
                        final selectedTasks = _tasksForDay(
                          tasks,
                          _selectedDay,
                          disciplineColors,
                          disciplines,
                        );

                        return Scaffold(
                          backgroundColor: colors.background,
                          body: SafeArea(
                            child: Stack(
                              children: [
                                ScrollConfiguration(
                                  behavior: const AppScrollBehavior(),
                                  child: SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      39,
                                      20,
                                      100,
                                    ),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 400,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ScheduleHeader(
                                              selectedDay: _selectedDay,
                                              focusedDay: _focusedDay,
                                              onPreviousDay: () =>
                                                  _changeSelectedDay(-1),
                                              onNextDay: () =>
                                                  _changeSelectedDay(1),
                                              showCourseScheduleShortcut:
                                                  !isIndependent,
                                              onCourseScheduleTap: () {
                                                if (isIndependent) return;
                                                setState(
                                                  () =>
                                                      _isShowingCourseSchedule =
                                                          true,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 31),
                                            MonthCalendar(
                                              focusedDay: _focusedDay,
                                              selectedDay: _selectedDay,
                                              markerColorsByDay:
                                                  _calendarMarkersByDayInFocusedMonth(
                                                    schedules,
                                                    events,
                                                    tasks,
                                                    disciplineColors,
                                                    disciplines,
                                                  ),
                                              onDaySelected: (day) {
                                                setState(() {
                                                  _selectedDay = day;
                                                  _focusedDay = day;
                                                });
                                              },
                                              onFocusedDayChanged: (day) {
                                                setState(
                                                  () => _focusedDay = day,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            SelectedDayScheduleCard(
                                              selectedDay: _selectedDay,
                                              classes: selectedClasses,
                                              events: selectedEvents,
                                              tasks: selectedTasks,
                                            ),
                                            if (eventSnapshot.hasError ||
                                                disciplineSnapshot.hasError ||
                                                taskSnapshot.hasError) ...[
                                              const SizedBox(height: 12),
                                              const _ScheduleDataWarning(),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 24,
                                  bottom: 16,
                                  child: FloatingAddButton(
                                    onTap: () => _openEventDialog(disciplines),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openEventDialog(List<Discipline> disciplines) async {
    final activeStudyCycleInfo = await _activeStudyCycleInfoFuture;
    if (!mounted) return;

    if (activeStudyCycleInfo.id == null) {
      _showError('Configure um ciclo de estudos antes de criar eventos.');
      return;
    }

    var topics = const <StudyTopic>[];
    if (activeStudyCycleInfo.type == StudyCycleType.independent) {
      try {
        topics = await _studyTopicRepository.fetchTopics(
          studyCycleId: activeStudyCycleInfo.id,
        );
      } on StudyTopicRepositoryException catch (error) {
        _showError(error.message);
        return;
      } catch (_) {
        _showError('Não foi possível carregar seus assuntos.');
        return;
      }
    }

    if (!mounted) return;

    final result = await showDialog<ScheduleEventDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => ScheduleEventDialog(
        disciplines: disciplines,
        topics: topics,
        initialDate: _selectedDay,
      ),
    );

    if (result == null || !mounted) return;

    try {
      await _eventRepository.createEvent(
        SubjectEventInput(
          studyCycleId: activeStudyCycleInfo.id,
          disciplineId: result.disciplineId,
          disciplineName: result.disciplineName,
          title: result.title,
          type: result.type,
          eventDate: result.eventDate,
          startTimeMinutes: result.startTimeMinutes,
          endTimeMinutes: result.endTimeMinutes,
          topicIds: result.topicIds,
          description: result.description,
        ),
      );
      _showSuccess('Evento salvo com sucesso.');
    } on SubjectEventRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar o evento. Tente novamente.');
    }
  }

  void _changeSelectedDay(int dayDelta) {
    final updatedSelectedDay = _dateOnly(
      _selectedDay.add(Duration(days: dayDelta)),
    );

    setState(() {
      _selectedDay = updatedSelectedDay;
      _focusedDay = updatedSelectedDay;
    });
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openScheduleEditor({
    required _ActiveStudyCycleInfo activeStudyCycleInfo,
    required List<Schedule> schedules,
    required List<Discipline> disciplines,
  }) async {
    final activeStudyCycleId = activeStudyCycleInfo.id;
    if (activeStudyCycleId == null) {
      _showError('Configure um ciclo de estudos antes de editar a grade.');
      return;
    }

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ScheduleEditorSheet(
          studyCycleId: activeStudyCycleId,
          schedules: schedules,
          disciplines: disciplines,
          onCreate: _scheduleRepository.createSchedule,
          onUpdate: (scheduleId, input) =>
              _scheduleRepository.updateSchedule(id: scheduleId, input: input),
          onDelete: _scheduleRepository.deleteSchedule,
        );
      },
    );
  }

  void _reloadActiveStudyCycle() {
    setState(() {
      _activeStudyCycleInfoFuture = _loadActiveStudyCycleInfo();
    });
  }

  Future<_ActiveStudyCycleInfo> _loadActiveStudyCycleInfo() async {
    final activeStudyCycleId = await _userProfileRepository
        .resolveActiveStudyCycleId();
    if (activeStudyCycleId == null) {
      return const _ActiveStudyCycleInfo();
    }

    final studyCycles = await _studyCycleRepository.fetchStudyCycles();

    for (final studyCycle in studyCycles) {
      if (studyCycle.id == activeStudyCycleId) {
        return _ActiveStudyCycleInfo(
          id: activeStudyCycleId,
          type: studyCycle.type,
          label: _activeStudyCycleLabel(studyCycle),
        );
      }
    }

    return const _ActiveStudyCycleInfo(label: 'Ciclo não encontrado');
  }

  String _activeStudyCycleLabel(StudyCycle studyCycle) {
    return switch (studyCycle.type) {
      StudyCycleType.university =>
        studyCycle.period == null
            ? 'Período não informado'
            : '${studyCycle.period}º período',
      StudyCycleType.highSchool =>
        studyCycle.schoolYear == null
            ? 'Ano letivo não informado'
            : '${studyCycle.schoolYear}º ano',
      StudyCycleType.independent => studyCycle.goal ?? 'Meta não informada',
    };
  }

  List<ScheduleClassInfo> _classesForDay(
    List<Schedule> schedules,
    DateTime day,
    Map<String, Color> disciplineColors,
    List<Discipline> disciplines,
  ) {
    final weekdayIndex = _weekdayIndexFromDate(day);
    final classes =
        schedules
            .where((schedule) => schedule.occursOnWeekday(weekdayIndex))
            .toList()
          ..sort(Schedule.compareByStartTime);

    return classes
        .map(
          (schedule) => _toClassInfo(schedule, disciplineColors, disciplines),
        )
        .toList();
  }

  Map<DateTime, List<ScheduleCalendarMarker>>
  _calendarMarkersByDayInFocusedMonth(
    List<Schedule> schedules,
    List<SubjectEvent> events,
    List<AcademicTask> tasks,
    Map<String, Color> disciplineColors,
    List<Discipline> disciplines,
  ) {
    final markersByDay = <DateTime, List<ScheduleCalendarMarker>>{};
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month);
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    final colors = context.appColors;

    for (var dayOffset = 0; dayOffset < daysInMonth; dayOffset++) {
      final day = firstDay.add(Duration(days: dayOffset));
      final weekdayIndex = _weekdayIndexFromDate(day);
      final schedulesForDay = schedules.where(
        (schedule) => schedule.occursOnWeekday(weekdayIndex),
      );

      for (final schedule in schedulesForDay) {
        _addCalendarMarker(
          markersByDay,
          day,
          ScheduleCalendarMarker(
            color: _scheduleColor(schedule, disciplineColors),
            kind: ScheduleCalendarMarkerKind.classSchedule,
          ),
        );
      }
    }

    for (final event in events) {
      final eventDay = _dateOnly(event.eventDate);
      if (eventDay.year != _focusedDay.year ||
          eventDay.month != _focusedDay.month) {
        continue;
      }

      _addCalendarMarker(
        markersByDay,
        eventDay,
        ScheduleCalendarMarker(
          color: _subjectEventColor(event, disciplineColors),
          kind: ScheduleCalendarMarkerKind.subjectEvent,
        ),
      );
    }

    for (final task in tasks) {
      final deadlineDate = _parseBrazilianDate(task.deadline);
      if (deadlineDate == null) continue;

      final taskDay = _dateOnly(deadlineDate);
      if (taskDay.year != _focusedDay.year ||
          taskDay.month != _focusedDay.month) {
        continue;
      }

      final color = _taskColor(
        task,
        disciplineColors,
        disciplines,
        fallbackColor: colors.success,
      );

      _addCalendarMarker(
        markersByDay,
        taskDay,
        ScheduleCalendarMarker(
          color: color,
          kind: ScheduleCalendarMarkerKind.academicTask,
        ),
      );
    }

    return markersByDay;
  }

  void _addCalendarMarker(
    Map<DateTime, List<ScheduleCalendarMarker>> markersByDay,
    DateTime day,
    ScheduleCalendarMarker marker,
  ) {
    final normalizedDay = _dateOnly(day);
    final markers = markersByDay.putIfAbsent(normalizedDay, () => []);
    final alreadyExists = markers.any(
      (existingMarker) =>
          existingMarker.kind == marker.kind &&
          existingMarker.color == marker.color,
    );

    if (!alreadyExists) markers.add(marker);
  }

  List<ScheduleDay> _scheduleDaysFromSchedules(
    List<Schedule> schedules,
    Map<String, Color> disciplineColors,
    List<Discipline> disciplines,
  ) {
    final days = <ScheduleDay>[];

    for (var weekdayIndex = 0; weekdayIndex <= 6; weekdayIndex++) {
      final schedulesForDay =
          schedules
              .where((schedule) => schedule.occursOnWeekday(weekdayIndex))
              .toList()
            ..sort(Schedule.compareByStartTime);

      if (schedulesForDay.isEmpty) continue;

      days.add(
        ScheduleDay(
          weekday: _weekdayName(weekdayIndex),
          classes: schedulesForDay
              .map(
                (schedule) => _toPeriodScheduleClass(
                  schedule,
                  disciplineColors,
                  disciplines,
                ),
              )
              .toList(),
        ),
      );
    }

    return days;
  }

  ScheduleClassInfo _toClassInfo(
    Schedule schedule,
    Map<String, Color> disciplineColors,
    List<Discipline> disciplines,
  ) {
    final color = _scheduleColor(schedule, disciplineColors);

    return ScheduleClassInfo(
      title: schedule.disciplineName,
      timeRange: schedule.formattedTimeRange,
      icon: Icons.menu_book_outlined,
      accentColor: color,
      iconColor: color,
      iconBackground: color.withValues(alpha: 0.12),
      onTap: () => _openDisciplineDetails(schedule, disciplines),
    );
  }

  List<ScheduleEventInfo> _eventsForDay(
    List<SubjectEvent> events,
    DateTime day,
    Map<String, Color> disciplineColors,
  ) {
    final selectedDay = _dateOnly(day);
    final eventsForDay =
        events
            .where((event) => _dateOnly(event.eventDate) == selectedDay)
            .toList()
          ..sort(SubjectEvent.compareByDate);

    return eventsForDay
        .map((event) => _toEventInfo(event, disciplineColors))
        .toList();
  }

  ScheduleEventInfo _toEventInfo(
    SubjectEvent event,
    Map<String, Color> disciplineColors,
  ) {
    final color = _subjectEventColor(event, disciplineColors);

    return ScheduleEventInfo(
      title: event.title,
      subject: event.disciplineName,
      typeLabel: event.type.label,
      timeRange: event.hasTimeRange ? event.timeRangeLabel : '',
      description: event.description,
      icon: _eventIcon(event.type),
      accentColor: color,
      iconColor: color,
      iconBackground: color.withValues(alpha: 0.12),
      onTap: () => _openEventDetails(event, color),
    );
  }

  IconData _eventIcon(SubjectEventType type) {
    return switch (type) {
      SubjectEventType.exam => Icons.edit_square,
      SubjectEventType.revision => Icons.event_repeat_outlined,
      SubjectEventType.lecture => Icons.record_voice_over_outlined,
      SubjectEventType.seminar => Icons.co_present_outlined,
      SubjectEventType.deadline => Icons.assignment_turned_in_outlined,
      SubjectEventType.extraClass => Icons.school_outlined,
      SubjectEventType.other => Icons.event_note_outlined,
    };
  }

  void _openDisciplineDetails(Schedule schedule, List<Discipline> disciplines) {
    final discipline = _findDisciplineForSchedule(schedule, disciplines);
    if (discipline == null) {
      _showError('Não foi possível localizar os detalhes dessa disciplina.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectDetailsPage(
          disciplineId: discipline.id,
          studyCycleId: discipline.studyCycleId,
          name: discipline.name,
          teacher: discipline.teacher.isEmpty
              ? 'Professor não informado'
              : discipline.teacher,
          average: 0,
          workload: discipline.workload,
          colorValue: discipline.colorValue,
        ),
      ),
    );
  }

  void _openEventDetails(SubjectEvent event, Color accentColor) {
    Navigator.of(context).push(
      AppRoutes.detailRoute(
        page: SubjectEventDetailsPage(
          event: event,
          accentColor: accentColor,
          onDelete: _deleteEvent,
        ),
      ),
    );
  }

  void _openTaskDetails(AcademicTask task, List<Discipline> disciplines) {
    Navigator.of(context).push(
      AppRoutes.detailRoute(
        page: TaskDetailsPage(
          task: task,
          subjects: _taskSubjectsFromDisciplines(
            disciplines: disciplines,
            task: task,
          ),
          activeStudyCycleId: task.studyCycleId,
        ),
      ),
    );
  }

  Future<void> _deleteEvent(SubjectEvent event) {
    return _eventRepository.deleteEvent(event.id);
  }

  List<TaskDialogSubject> _taskSubjectsFromDisciplines({
    required List<Discipline> disciplines,
    required AcademicTask task,
  }) {
    final subjects = disciplines
        .where((discipline) => discipline.name.trim().isNotEmpty)
        .map(
          (discipline) => TaskDialogSubject(
            id: discipline.id,
            name: discipline.name.trim(),
          ),
        )
        .toList();

    final currentDisciplineId = task.disciplineId?.trim();
    final currentSubject = task.subject.trim();
    final hasCurrentDiscipline =
        currentDisciplineId != null &&
        currentDisciplineId.isNotEmpty &&
        subjects.any((subject) => subject.id == currentDisciplineId);
    final hasCurrentSubject =
        currentSubject.isNotEmpty &&
        subjects.any(
          (subject) =>
              subject.name.trim().toLowerCase() == currentSubject.toLowerCase(),
        );

    if (!hasCurrentDiscipline &&
        !hasCurrentSubject &&
        currentSubject.isNotEmpty) {
      subjects.add(TaskDialogSubject(name: currentSubject));
    }

    subjects.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return subjects;
  }

  Discipline? _findDisciplineForSchedule(
    Schedule schedule,
    List<Discipline> disciplines,
  ) {
    final disciplineId = schedule.disciplineId;
    if (disciplineId != null) {
      for (final discipline in disciplines) {
        if (discipline.id == disciplineId) return discipline;
      }
    }

    final scheduleName = _normalizedDisciplineName(schedule.disciplineName);
    if (scheduleName == null) return null;

    for (final discipline in disciplines) {
      if (_normalizedDisciplineName(discipline.name) == scheduleName) {
        return discipline;
      }
    }

    return null;
  }

  PeriodScheduleClass _toPeriodScheduleClass(
    Schedule schedule,
    Map<String, Color> disciplineColors,
    List<Discipline> disciplines,
  ) {
    final color = _scheduleColor(schedule, disciplineColors);
    final discipline = _findDisciplineForSchedule(schedule, disciplines);
    final teacher = discipline?.teacher.trim();

    return PeriodScheduleClass(
      timeRange: schedule.formattedTimeRange,
      title: schedule.disciplineName,
      shortTitle: _shortTitle(schedule.disciplineName),
      detail: teacher == null || teacher.isEmpty
          ? 'Professor não informado'
          : teacher,
      color: color.withValues(alpha: 0.12),
      accentColor: color,
    );
  }

  Color _scheduleColor(Schedule schedule, Map<String, Color> disciplineColors) {
    final disciplineName = _normalizedDisciplineName(schedule.disciplineName);
    if (disciplineName == null) return Color(schedule.colorValue);

    return disciplineColors[disciplineName] ?? Color(schedule.colorValue);
  }

  Color _subjectEventColor(
    SubjectEvent event,
    Map<String, Color> disciplineColors,
  ) {
    final disciplineName = _normalizedDisciplineName(event.disciplineName);
    if (disciplineName == null) return context.appColors.primary;

    return disciplineColors[disciplineName] ??
        Color(Schedule.colorValueForDisciplineName(disciplineName));
  }

  Color _taskColor(
    AcademicTask task,
    Map<String, Color> disciplineColors,
    List<Discipline> disciplines, {
    required Color fallbackColor,
  }) {
    final disciplineName = _normalizedTaskDisciplineName(task, disciplines);
    if (disciplineName == null) return fallbackColor;

    return disciplineColors[disciplineName] ??
        Color(Schedule.colorValueForDisciplineName(disciplineName));
  }

  String? _normalizedTaskDisciplineName(
    AcademicTask task,
    List<Discipline> disciplines,
  ) {
    final disciplineId = task.disciplineId;
    if (disciplineId != null) {
      for (final discipline in disciplines) {
        if (discipline.id == disciplineId) {
          return _normalizedDisciplineName(discipline.name);
        }
      }
    }

    return _normalizedDisciplineName(task.subject);
  }

  Map<String, Color> _disciplineColorsForSchedules(
    List<Schedule> schedules,
    List<Discipline> disciplines,
  ) {
    final disciplineNames = {
      ...schedules
          .map((schedule) => _normalizedDisciplineName(schedule.disciplineName))
          .nonNulls,
      ...disciplines
          .map((discipline) => _normalizedDisciplineName(discipline.name))
          .nonNulls,
    }.toList();

    disciplineNames.sort((a, b) {
      final preferredColorComparison = _preferredPaletteIndex(
        a,
      ).compareTo(_preferredPaletteIndex(b));
      if (preferredColorComparison != 0) return preferredColorComparison;

      return a.compareTo(b);
    });

    final disciplineColors = <String, Color>{};
    final usedPaletteIndexes = <int>{};
    final palette = Schedule.disciplineColorPalette;

    for (var i = 0; i < disciplineNames.length; i++) {
      final disciplineName = disciplineNames[i];
      final disciplineColor = _disciplineColorValue(
        disciplineName,
        disciplines,
      );
      if (disciplineColor != null) {
        disciplineColors[disciplineName] = Color(disciplineColor);
        continue;
      }

      final preferredIndex = _preferredPaletteIndex(disciplineName);
      final colorIndex = _availablePaletteIndex(
        preferredIndex: preferredIndex,
        fallbackIndex: i,
        usedPaletteIndexes: usedPaletteIndexes,
      );

      disciplineColors[disciplineName] = Color(palette[colorIndex]);
    }

    return disciplineColors;
  }

  int? _disciplineColorValue(
    String disciplineName,
    List<Discipline> disciplines,
  ) {
    for (final discipline in disciplines) {
      if (_normalizedDisciplineName(discipline.name) == disciplineName) {
        return discipline.colorValue;
      }
    }

    return null;
  }

  int _availablePaletteIndex({
    required int preferredIndex,
    required int fallbackIndex,
    required Set<int> usedPaletteIndexes,
  }) {
    final paletteLength = Schedule.disciplineColorPalette.length;

    for (var offset = 0; offset < paletteLength; offset++) {
      final candidateIndex = (preferredIndex + offset) % paletteLength;
      if (usedPaletteIndexes.add(candidateIndex)) return candidateIndex;
    }

    return fallbackIndex % paletteLength;
  }

  int _preferredPaletteIndex(String disciplineName) {
    final colorValue = Schedule.colorValueForDisciplineName(disciplineName);
    final paletteIndex = Schedule.disciplineColorPalette.indexOf(colorValue);

    return paletteIndex == -1 ? 0 : paletteIndex;
  }

  String? _normalizedDisciplineName(String disciplineName) {
    final normalizedName = disciplineName.trim().toLowerCase();

    return normalizedName.isEmpty ? null : normalizedName;
  }

  String _shiftLabelFromSchedules(List<Schedule> schedules) {
    if (schedules.isEmpty) return 'Sem aulas';

    final shifts = <_ScheduleShift>{};

    for (final schedule in schedules) {
      shifts.add(_shiftFromTime(schedule.startTimeMinutes));
    }

    const orderedShifts = [
      _ScheduleShift.morning,
      _ScheduleShift.afternoon,
      _ScheduleShift.night,
    ];

    final labels = orderedShifts
        .where(shifts.contains)
        .map((shift) => shift.label)
        .toList();

    if (labels.length <= 1) return labels.first;
    if (labels.length == 2) return '${labels.first} e ${labels.last}';

    return '${labels[0]}, ${labels[1]} e ${labels[2]}';
  }

  _ScheduleShift _shiftFromTime(int startTimeMinutes) {
    if (startTimeMinutes < 12 * 60) return _ScheduleShift.morning;
    if (startTimeMinutes < 18 * 60) return _ScheduleShift.afternoon;

    return _ScheduleShift.night;
  }

  String _shortTitle(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'Aula';

    final initials = words
        .where((word) => word.isNotEmpty)
        .take(3)
        .map((word) => word[0].toUpperCase())
        .join();

    return initials.isEmpty ? words.first : initials;
  }

  String _weekdayName(int weekdayIndex) {
    return switch (weekdayIndex) {
      0 => 'Domingo',
      1 => 'Segunda',
      2 => 'Terça',
      3 => 'Quarta',
      4 => 'Quinta',
      5 => 'Sexta',
      6 => 'Sábado',
      _ => '',
    };
  }

  int _weekdayIndexFromDate(DateTime date) {
    return date.weekday % 7;
  }

  List<ScheduleTaskInfo> _tasksForDay(
    List<AcademicTask> tasks,
    DateTime day,
    Map<String, Color> disciplineColors,
    List<Discipline> disciplines,
  ) {
    final selectedDate = _dateOnly(day);
    final tasksForDay = tasks.where((task) {
      final deadlineDate = _parseBrazilianDate(task.deadline);
      if (deadlineDate == null) return false;
      return _dateOnly(deadlineDate) == selectedDate;
    }).toList();

    return tasksForDay.map((task) {
      final color = _taskColor(
        task,
        disciplineColors,
        disciplines,
        fallbackColor: context.appColors.primary,
      );

      return ScheduleTaskInfo(
        title: task.title,
        subject: task.subject,
        typeLabel: task.visualPriority,
        isChecked: task.isChecked,
        icon: _taskIcon(task.visualPriority),
        accentColor: color,
        iconColor: color,
        iconBackground: color.withValues(alpha: 0.12),
        onTap: () => _openTaskDetails(task, disciplines),
      );
    }).toList();
  }

  IconData _taskIcon(String visualPriority) {
    return switch (visualPriority) {
      'Prova' => Icons.edit_square,
      'Estudo' => Icons.school_outlined,
      'Seminário' => Icons.co_present_outlined,
      'Leitura' => Icons.menu_book_outlined,
      'Pesquisa' => Icons.search_outlined,
      _ => Icons.assignment_outlined,
    };
  }

  DateTime? _parseBrazilianDate(String value) {
    try {
      final parts = value.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

enum _ScheduleShift {
  morning('Manhã'),
  afternoon('Tarde'),
  night('Noite');

  final String label;

  const _ScheduleShift(this.label);
}

class _ActiveStudyCycleInfo {
  final String? id;
  final StudyCycleType? type;
  final String label;

  const _ActiveStudyCycleInfo({
    this.id,
    this.type,
    this.label = 'Ciclo acadêmico não configurado',
  });
}

class _ScheduleLoadingScaffold extends StatelessWidget {
  const _ScheduleLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(child: CircularProgressIndicator(color: colors.primary)),
      ),
    );
  }
}

class _ScheduleErrorScaffold extends StatelessWidget {
  final VoidCallback onRetry;

  const _ScheduleErrorScaffold({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.surfaceTint,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: colors.primary, size: 30),
                  const SizedBox(height: 12),
                  Text(
                    'Não foi possível carregar seus horários.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textDark,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleDataWarning extends StatelessWidget {
  const _ScheduleDataWarning();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.warningSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy_outlined, color: colors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Não foi possível carregar todos os detalhes do calendário.',
              style: TextStyle(
                color: colors.warning,
                fontSize: 13,
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
