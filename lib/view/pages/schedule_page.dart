import 'package:flutter/material.dart';

import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_colors.dart';
import '../../models/schedule.dart';
import '../../models/study_cycle.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../widgets/common/floating_add_button.dart';
import '../widgets/dialogs/schedule_dialog.dart';
import '../widgets/schedules/course_schedule_view.dart';
import '../widgets/schedules/month_calendar.dart';
import '../widgets/schedules/schedule_header.dart';
import '../widgets/schedules/schedule_models.dart';
import '../widgets/schedules/selected_day_schedule_card.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final StudyCycleRepository _studyCycleRepository = StudyCycleRepository();
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
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

            final schedules = snapshot.data ?? [];
            final disciplineColors = _disciplineColorsForSchedules(schedules);
            final selectedClasses = _classesForDay(
              schedules,
              _selectedDay,
              disciplineColors,
            );
            final courseScheduleDays = _scheduleDaysFromSchedules(
              schedules,
              disciplineColors,
            );

            if (_isShowingCourseSchedule) {
              return CourseScheduleView(
                days: courseScheduleDays,
                subtitle: activeStudyCycleInfo.label,
                shiftLabel: _shiftLabelFromSchedules(schedules),
                onBack: () => setState(() => _isShowingCourseSchedule = false),
                onEdit: () =>
                    _showComingSoon('Edição da grade em desenvolvimento.'),
              );
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Stack(
                  children: [
                    ScrollConfiguration(
                      behavior: const AppScrollBehavior(),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 39, 20, 100),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ScheduleHeader(
                                  selectedDay: _selectedDay,
                                  focusedDay: _focusedDay,
                                  onPreviousDay: () => _changeSelectedDay(-1),
                                  onNextDay: () => _changeSelectedDay(1),
                                  onCourseScheduleTap: () {
                                    setState(
                                      () => _isShowingCourseSchedule = true,
                                    );
                                  },
                                ),
                                const SizedBox(height: 31),
                                MonthCalendar(
                                  focusedDay: _focusedDay,
                                  selectedDay: _selectedDay,
                                  classColorsByDay:
                                      _classColorsByDayInFocusedMonth(
                                        schedules,
                                        disciplineColors,
                                      ),
                                  onDaySelected: (day) {
                                    setState(() {
                                      _selectedDay = day;
                                      _focusedDay = day;
                                    });
                                  },
                                  onFocusedDayChanged: (day) {
                                    setState(() => _focusedDay = day);
                                  },
                                ),
                                const SizedBox(height: 16),
                                SelectedDayScheduleCard(
                                  selectedDay: _selectedDay,
                                  classes: selectedClasses,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 16,
                      child: FloatingAddButton(onTap: _openScheduleDialog),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openScheduleDialog() async {
    final result = await showDialog<ScheduleDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const ScheduleDialog(showDisciplineNameField: true),
    );

    if (result == null || result.weekdays.isEmpty || !mounted) return;

    final disciplineName = result.disciplineName?.trim();
    if (disciplineName == null || disciplineName.isEmpty) {
      _showError('Informe o nome da disciplina para salvar o horário.');
      return;
    }

    final activeStudyCycleInfo = await _activeStudyCycleInfoFuture;

    try {
      for (final timeRange in result.timeRanges) {
        await _scheduleRepository.createSchedule(
          ScheduleInput(
            studyCycleId: activeStudyCycleInfo.id,
            disciplineName: disciplineName,
            weekdays: result.weekdays,
            startTimeMinutes: timeRange.startTimeMinutes,
            endTimeMinutes: timeRange.endTimeMinutes,
            colorValue: Schedule.colorValueForDisciplineName(disciplineName),
          ),
        );
      }

      _showSuccess('Horário salvo com sucesso.');
    } on ScheduleRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar o horário. Tente novamente.');
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

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
          label: _activeStudyCycleLabel(studyCycle),
        );
      }
    }

    return const _ActiveStudyCycleInfo(label: 'Ciclo acadêmico ativo');
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
  ) {
    final weekdayIndex = _weekdayIndexFromDate(day);
    final classes =
        schedules
            .where((schedule) => schedule.occursOnWeekday(weekdayIndex))
            .toList()
          ..sort(Schedule.compareByStartTime);

    return classes
        .map((schedule) => _toClassInfo(schedule, disciplineColors))
        .toList();
  }

  Map<DateTime, List<Color>> _classColorsByDayInFocusedMonth(
    List<Schedule> schedules,
    Map<String, Color> disciplineColors,
  ) {
    final classColorsByDay = <DateTime, List<Color>>{};
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month);
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    for (var dayOffset = 0; dayOffset < daysInMonth; dayOffset++) {
      final day = firstDay.add(Duration(days: dayOffset));
      final weekdayIndex = _weekdayIndexFromDate(day);
      final schedulesForDay = schedules.where(
        (schedule) => schedule.occursOnWeekday(weekdayIndex),
      );

      final colors = schedulesForDay
          .map((schedule) => _scheduleColor(schedule, disciplineColors))
          .toSet()
          .toList(growable: false);
      if (colors.isNotEmpty) {
        classColorsByDay[_dateOnly(day)] = colors;
      }
    }

    return classColorsByDay;
  }

  List<ScheduleDay> _scheduleDaysFromSchedules(
    List<Schedule> schedules,
    Map<String, Color> disciplineColors,
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
                (schedule) =>
                    _toPeriodScheduleClass(schedule, disciplineColors),
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
  ) {
    final color = _scheduleColor(schedule, disciplineColors);

    return ScheduleClassInfo(
      title: schedule.disciplineName,
      timeRange: schedule.formattedTimeRange,
      icon: Icons.menu_book_outlined,
      accentColor: color,
      iconColor: color,
      iconBackground: color.withValues(alpha: 0.12),
    );
  }

  PeriodScheduleClass _toPeriodScheduleClass(
    Schedule schedule,
    Map<String, Color> disciplineColors,
  ) {
    final color = _scheduleColor(schedule, disciplineColors);

    return PeriodScheduleClass(
      timeRange: schedule.formattedTimeRange,
      title: schedule.disciplineName,
      shortTitle: _shortTitle(schedule.disciplineName),
      code: 'Horário',
      teacher: 'Cadastrado',
      color: color.withValues(alpha: 0.12),
      accentColor: color,
    );
  }

  Color _scheduleColor(Schedule schedule, Map<String, Color> disciplineColors) {
    final disciplineName = _normalizedDisciplineName(schedule.disciplineName);
    if (disciplineName == null) return Color(schedule.colorValue);

    return disciplineColors[disciplineName] ?? Color(schedule.colorValue);
  }

  Map<String, Color> _disciplineColorsForSchedules(List<Schedule> schedules) {
    final disciplineNames = schedules
        .map((schedule) => _normalizedDisciplineName(schedule.disciplineName))
        .nonNulls
        .toSet()
        .toList();

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
  final String label;

  const _ActiveStudyCycleInfo({
    this.id,
    this.label = 'Ciclo acadêmico não configurado',
  });
}

class _ScheduleLoadingScaffold extends StatelessWidget {
  const _ScheduleLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ScheduleErrorScaffold extends StatelessWidget {
  final VoidCallback onRetry;

  const _ScheduleErrorScaffold({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF0FB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E4F0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Não foi possível carregar seus horários.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF464552),
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
