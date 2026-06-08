import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_colors.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static final DateTime _initialSelectedDay = _dateOnly(DateTime(2026, 5, 14));

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isShowingCourseSchedule = false;

  final Map<DateTime, List<_ScheduleClass>> _classesByDay = {
    _dateOnly(DateTime(2026, 5, 14)): const [
      _ScheduleClass(
        title: 'Banco de Dados',
        timeRange: '13:00 - 17:30',
        icon: Icons.computer_outlined,
        accentColor: Color(0xFF8A38F5),
        iconColor: Color(0xFF514EB6),
        iconBackground: Color(0xFFF0ECFF),
      ),
      _ScheduleClass(
        title: 'PLP',
        timeRange: '07:30 - 10:50',
        icon: Icons.storage_outlined,
        accentColor: Color(0x99CB09A1),
        iconColor: Color(0xFF1688DC),
        iconBackground: Color(0xFFEAF7FF),
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = _initialSelectedDay;
    _selectedDay = _initialSelectedDay;
  }

  @override
  Widget build(BuildContext context) {
    if (_isShowingCourseSchedule) {
      return _CourseScheduleView(
        onBack: () => setState(() => _isShowingCourseSchedule = false),
        onEdit: () => _showComingSoon('Edição da grade em desenvolvimento.'),
      );
    }

    final selectedClasses = _classesByDay[_selectedDay] ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 39, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ScheduleHeader(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      onPreviousDay: () => _changeSelectedDay(-1),
                      onNextDay: () => _changeSelectedDay(1),
                      onCourseScheduleTap: () {
                        setState(() => _isShowingCourseSchedule = true);
                      },
                    ),
                    const SizedBox(height: 31),
                    _MonthCalendar(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      daysWithClasses: _classesByDay.keys.toSet(),
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
                    _SelectedDayScheduleCard(
                      selectedDay: _selectedDay,
                      classes: selectedClasses,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _ScheduleHeader extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onCourseScheduleTap;

  const _ScheduleHeader({
    required this.selectedDay,
    required this.focusedDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onCourseScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortcutWidth = (constraints.maxWidth - 134).clamp(156.0, 224.0);

        return SizedBox(
          height: 128,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(left: 0, top: 0, child: _DateTile(date: selectedDay)),
              Positioned(
                left: 134,
                right: 118,
                top: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _monthTitle(focusedDay),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedDayLabel(selectedDay),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 19,
                child: Row(
                  children: [
                    _MonthButton(
                      tooltip: 'Dia anterior',
                      icon: Icons.chevron_left,
                      onPressed: onPreviousDay,
                    ),
                    const SizedBox(width: 18),
                    _MonthButton(
                      tooltip: 'Próximo dia',
                      icon: Icons.chevron_right,
                      onPressed: onNextDay,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 78,
                child: _CourseScheduleShortcut(
                  width: shortcutWidth,
                  onTap: onCourseScheduleTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _monthTitle(DateTime day) {
    final month = DateFormat.MMMM('pt_BR').format(day);
    final capitalizedMonth = '${month[0].toUpperCase()}${month.substring(1)}';

    return '$capitalizedMonth ${day.year}';
  }

  String _selectedDayLabel(DateTime day) {
    final today = DateTime.now();
    final isToday =
        day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
    final isMockToday =
        day.year == 2026 && day.month == DateTime.may && day.day == 14;

    if (isToday || isMockToday) return 'Hoje';

    final weekday = DateFormat.EEEE('pt_BR').format(day);
    return '${weekday[0].toUpperCase()}${weekday.substring(1)}';
  }
}

class _DateTile extends StatelessWidget {
  final DateTime date;

  const _DateTile({required this.date});

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat.E('pt_BR').format(date).replaceAll('.', '');
    final capitalizedWeekday =
        '${weekday[0].toUpperCase()}${weekday.substring(1)}.';

    return Container(
      width: 118,
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1FB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            capitalizedWeekday,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 60,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 0.9,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _MonthButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFEDE8FB),
        shape: const CircleBorder(),
        shadowColor: const Color(0x66587DBD),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: const Color(0xFF6F55D9), size: 35),
          ),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Set<DateTime> daysWithClasses;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onFocusedDayChanged;

  const _MonthCalendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.daysWithClasses,
    required this.onDaySelected,
    required this.onFocusedDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<int>(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      eventLoader: (day) =>
          daysWithClasses.contains(_dateOnly(day)) ? const [1] : const [],
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
      availableGestures: AvailableGestures.horizontalSwipe,
      headerVisible: false,
      daysOfWeekHeight: 38,
      rowHeight: 55,
      sixWeekMonthsEnforced: false,
      onDaySelected: (selectedDay, focusedDay) {
        onDaySelected(_dateOnly(selectedDay));
        onFocusedDayChanged(_dateOnly(focusedDay));
      },
      onPageChanged: (focusedDay) {
        onFocusedDayChanged(_dateOnly(focusedDay));
      },
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextFormatter: (date, locale) => _weekdayLabel(date),
        weekdayStyle: _weekdayStyle,
        weekendStyle: _weekdayStyle,
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: true,
        cellMargin: EdgeInsets.zero,
        cellPadding: EdgeInsets.zero,
        defaultTextStyle: _dayStyle,
        weekendTextStyle: _dayStyle,
        outsideTextStyle: _outsideDayStyle,
        selectedTextStyle: _selectedDayStyle,
        todayTextStyle: _dayStyle,
        selectedDecoration: BoxDecoration(
          color: Color(0xFF655DE1),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(color: Colors.transparent),
        markerDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerSize: 4,
        markersMaxCount: 1,
        markersAnchor: 0.78,
        markersAlignment: Alignment.bottomCenter,
      ),
      calendarBuilders: const CalendarBuilders<int>(
        selectedBuilder: _selectedDayBuilder,
        todayBuilder: _todayBuilder,
      ),
    );
  }

  static const TextStyle _weekdayStyle = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 1.1,
  );

  static const TextStyle _dayStyle = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 1,
  );

  static const TextStyle _outsideDayStyle = TextStyle(
    color: Color(0xFF656565),
    fontSize: 15,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 1,
  );

  static const TextStyle _selectedDayStyle = TextStyle(
    color: AppColors.background,
    fontSize: 15,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 1,
  );

  static Widget _selectedDayBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFF655DE1),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text('${day.day}', style: _selectedDayStyle)),
      ),
    );
  }

  static Widget _todayBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    return Center(child: Text('${day.day}', style: _dayStyle));
  }

  static String _weekdayLabel(DateTime date) {
    const labels = ['Se', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Do'];
    return labels[date.weekday - 1];
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _SelectedDayScheduleCard extends StatelessWidget {
  final DateTime selectedDay;
  final List<_ScheduleClass> classes;

  const _SelectedDayScheduleCard({
    required this.selectedDay,
    required this.classes,
  });

  @override
  Widget build(BuildContext context) {
    return _RaisedCard(
      minHeight: 218,
      padding: const EdgeInsets.fromLTRB(17, 24, 17, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedDayTitle(selectedDay),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          if (classes.isEmpty)
            const _EmptyScheduleMessage()
          else
            Column(
              children: List.generate(classes.length, (index) {
                final classInfo = classes[index];
                final isLast = index == classes.length - 1;

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                  child: _ScheduleClassRow(classInfo: classInfo),
                );
              }),
            ),
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

class _ScheduleClassRow extends StatelessWidget {
  final _ScheduleClass classInfo;

  const _ScheduleClassRow({required this.classInfo});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            border: Border.all(color: const Color(0x2ED1D1D1)),
            boxShadow: [
              BoxShadow(
                color: classInfo.iconColor.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(classInfo.icon, color: classInfo.iconColor, size: 26),
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
                style: const TextStyle(
                  color: Colors.black,
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
                style: const TextStyle(
                  color: Color(0xFF656565),
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
    );
  }
}

class _EmptyScheduleMessage extends StatelessWidget {
  const _EmptyScheduleMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Text(
        'Nenhuma aula cadastrada para este dia.',
        style: TextStyle(
          color: Color(0xFF656565),
          fontSize: 13,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _CourseScheduleShortcut extends StatelessWidget {
  final double width;
  final VoidCallback onTap;

  const _CourseScheduleShortcut({required this.width, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Abrir grade de horário',
      child: Material(
        color: const Color(0xFFF2F0FF),
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: const Color(0x33587DBD),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_note_outlined,
                    color: Color(0xFF8A38F5),
                    size: 22,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'Grade de Horário',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8A38F5),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
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

class _CourseScheduleView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const _CourseScheduleView({required this.onBack, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    _CourseScheduleHeader(onBack: onBack),
                    const SizedBox(height: 16),
                    const _ScheduleStats(),
                    const SizedBox(height: 14),
                    _CurrentPeriodSchedule(
                      days: _currentPeriodDays,
                      onEdit: onEdit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const List<_ScheduleDay> _currentPeriodDays = [
    _ScheduleDay(
      weekday: 'Segunda',
      classes: [
        _PeriodScheduleClass(
          timeRange: '07:30 - 10:00',
          title: 'Paradigmas de Linguagens de Programação',
          shortTitle: 'PLP',
          code: 'SOF0040G',
          teacher: 'Eraylson Galdino',
          note: 'Compartilhada com L.C',
          color: Color(0xFFE9E8FF),
          accentColor: Color(0xFF514EB6),
        ),
      ],
    ),
    _ScheduleDay(
      weekday: 'Terça',
      classes: [
        _PeriodScheduleClass(
          timeRange: '09:10 - 12:30',
          title: 'Redes de Computadores',
          shortTitle: 'Redes',
          code: 'SOF0038G',
          teacher: 'Cleiton Martins',
          note: 'Compartilhada com L.C',
          color: Color(0xFFEAF2FF),
          accentColor: Color(0xFF4C7DCC),
        ),
      ],
    ),
    _ScheduleDay(
      weekday: 'Quarta',
      classes: [
        _PeriodScheduleClass(
          timeRange: '07:30 - 09:10',
          title: 'DCEXT V',
          shortTitle: 'DCEXT V',
          code: 'SOF0056G',
          teacher: 'Mariana',
          color: Color(0xFFE8F6F8),
          accentColor: Color(0xFF2B9EAD),
        ),
        _PeriodScheduleClass(
          timeRange: '09:10 - 12:30',
          title: 'Verificação e Validação de Sistemas',
          shortTitle: 'V&V',
          code: 'SOF0041G',
          teacher: 'Ivaldir',
          color: Color(0xFFF0ECFF),
          accentColor: Color(0xFF6D5BD2),
        ),
      ],
    ),
    _ScheduleDay(
      weekday: 'Quinta',
      classes: [
        _PeriodScheduleClass(
          timeRange: '08:20 - 10:50',
          title: 'Projeto I',
          shortTitle: 'Projeto I',
          code: 'SOF0056G',
          teacher: 'Marcelo Mendonça',
          color: Color(0xFFF6ECFF),
          accentColor: Color(0xFF8A38F5),
        ),
      ],
    ),
    _ScheduleDay(
      weekday: 'Sexta',
      classes: [
        _PeriodScheduleClass(
          timeRange: '09:10 - 12:30',
          title: 'Programação para Dispositivos Móveis',
          shortTitle: 'Mobile',
          code: 'SOF0041G',
          teacher: 'Elisson Rocha',
          color: Color(0xFFEAF2FF),
          accentColor: Color(0xFF4C7DCC),
        ),
        _PeriodScheduleClass(
          timeRange: '13:30 - 16:50',
          title: 'Gerência de Projetos',
          shortTitle: 'GP',
          code: 'SOF0039G',
          teacher: 'Aêda Sousa',
          note: 'Compartilhada com L.C',
          color: Color(0xFFFFEDF5),
          accentColor: Color(0xFFE06AA5),
        ),
      ],
    ),
  ];
}

class _CourseScheduleHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _CourseScheduleHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1FB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
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
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Engenharia de Software',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
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
          const Text(
            '5º período',
            style: TextStyle(
              color: Color(0xFF656565),
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
  const _ScheduleStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ScheduleStatChip(
            icon: Icons.view_week_outlined,
            label: 'Semana',
            value: '7 aulas',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _ScheduleStatChip(
            icon: Icons.wb_sunny_outlined,
            label: 'Turnos',
            value: 'Manhã e tarde',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22587DBD),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF656565),
                    fontSize: 11,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
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

class _CurrentPeriodSchedule extends StatelessWidget {
  final List<_ScheduleDay> days;
  final VoidCallback onEdit;

  const _CurrentPeriodSchedule({required this.days, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33514EB6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33587DBD),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aulas do seu período',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Inspirado no quadro da faculdade, sem horários vazios.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
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
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primary,
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
    return Center(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScheduleDaySection extends StatelessWidget {
  final _ScheduleDay day;

  const _ScheduleDaySection({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0x24514EB6)),
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
                        const Divider(height: 1, color: Color(0x1F514EB6)),
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
  final _ScheduleDay day;

  const _DayLabel({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: const Color(0xFFE9E8FF),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.weekday.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${day.classes.length} ${day.classes.length == 1 ? 'aula' : 'aulas'}',
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.textMuted,
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
  final _PeriodScheduleClass classInfo;

  const _PeriodClassRow({required this.classInfo});

  @override
  Widget build(BuildContext context) {
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
                                style: const TextStyle(
                                  color: AppColors.textDark,
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
                          '${classInfo.code} • ${classInfo.teacher}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
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
    final parts = timeRange.split(' - ');

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x24514EB6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            parts.first,
            maxLines: 1,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Container(width: 18, height: 1, color: const Color(0x33514EB6)),
          const SizedBox(height: 3),
          Text(
            parts.length > 1 ? parts.last : '',
            maxLines: 1,
            style: const TextStyle(
              color: AppColors.textMuted,
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
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
    return Tooltip(
      message: 'Editar grade',
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: const Color(0x66587DBD),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.edit_outlined, color: Colors.white, size: 25),
          ),
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
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x33587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _ScheduleClass {
  final String title;
  final String timeRange;
  final IconData icon;
  final Color accentColor;
  final Color iconColor;
  final Color iconBackground;

  const _ScheduleClass({
    required this.title,
    required this.timeRange,
    required this.icon,
    required this.accentColor,
    required this.iconColor,
    required this.iconBackground,
  });
}

class _ScheduleDay {
  final String weekday;
  final List<_PeriodScheduleClass> classes;

  const _ScheduleDay({required this.weekday, required this.classes});
}

class _PeriodScheduleClass {
  final String timeRange;
  final String title;
  final String shortTitle;
  final String code;
  final String teacher;
  final String? note;
  final Color color;
  final Color accentColor;

  const _PeriodScheduleClass({
    required this.timeRange,
    required this.title,
    required this.shortTitle,
    required this.code,
    required this.teacher,
    required this.color,
    required this.accentColor,
    this.note,
  });
}
