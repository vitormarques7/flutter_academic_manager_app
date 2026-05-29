import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/theme/app_colors.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  final Map<DateTime, List<String>> _activityReminders = {
    _dateOnly(DateTime(2026, 5, 14)): ['Entrega de atividade'],
  };

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _focusedDay = today;
    _selectedDay = today;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 39, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ScheduleHeader(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      onPreviousDay: () => _changeSelectedDay(-1),
                      onNextDay: () => _changeSelectedDay(1),
                    ),
                    const SizedBox(height: 31),
                    _CalendarCard(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      activityReminders: _activityReminders,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = _dateOnly(selectedDay);
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() => _focusedDay = focusedDay);
                      },
                    ),
                    const SizedBox(height: 16),
                    _ScheduleActionButton(
                      label: 'Adicionar Lembrete de atividade',
                      onPressed: () => _showComingSoon(
                        'Criação de lembrete em desenvolvimento.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ScheduleActionButton(
                      label: 'Ver grade de horários',
                      onPressed: () => _showComingSoon(
                        'Grade de horários em desenvolvimento.',
                      ),
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

  const _ScheduleHeader({
    required this.selectedDay,
    required this.focusedDay,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateTile(date: selectedDay),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
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
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedDayLabel(selectedDay),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Row(
            children: [
              _MonthButton(
                tooltip: 'Dia anterior',
                icon: Icons.chevron_left,
                onPressed: onPreviousDay,
              ),
              const SizedBox(width: 24),
              _MonthButton(
                tooltip: 'Próximo dia',
                icon: Icons.chevron_right,
                onPressed: onNextDay,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _monthTitle(DateTime day) {
    final month = DateFormat.MMMM('pt_BR').format(day);
    final capitalizedMonth = '${month[0].toUpperCase()}${month.substring(1)}';

    return '$capitalizedMonth ${day.year}';
  }

  String _selectedDayLabel(DateTime day) {
    if (isSameDay(day, DateTime.now())) return 'Hoje';

    final weekday = DateFormat.EEEE('pt_BR').format(day);
    final capitalizedWeekday =
        '${weekday[0].toUpperCase()}${weekday.substring(1)}';

    return capitalizedWeekday;
  }
}

class _DateTile extends StatelessWidget {
  final DateTime date;

  const _DateTile({required this.date});

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat.E('pt_BR').format(date);
    final capitalizedWeekday =
        '${weekday[0].toUpperCase()}${weekday.substring(1)}';

    return Container(
      width: 118,
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
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
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            '${date.day}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 60,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 0.95,
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
        color: AppColors.primary.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: const Color(0xFF1D1B20), size: 34),
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<String>> activityReminders;
  final OnDaySelected onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.activityReminders,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 392, minHeight: 484),
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<String>(
        locale: 'pt_BR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.horizontalSwipe,
        headerVisible: false,
        sixWeekMonthsEnforced: true,
        daysOfWeekHeight: 44,
        rowHeight: 60,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        eventLoader: (day) => activityReminders[_dateOnly(day)] ?? const [],
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (date, locale) => _shortWeekdayLabel(date),
          weekdayStyle: _calendarLabelStyle(),
          weekendStyle: _calendarLabelStyle(),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          cellMargin: const EdgeInsets.all(7),
          defaultTextStyle: _dayTextStyle(),
          weekendTextStyle: _dayTextStyle(),
          outsideTextStyle: _dayTextStyle().copyWith(
            color: const Color(0xFF656565),
          ),
          selectedTextStyle: _dayTextStyle(color: Colors.black),
          todayTextStyle: _dayTextStyle(),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,
          markersMaxCount: 1,
          markerSize: 5,
        ),
      ),
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static TextStyle _calendarLabelStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 15,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle _dayTextStyle({Color color = Colors.black}) {
    return TextStyle(
      color: color,
      fontSize: 15,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    );
  }

  static String _shortWeekdayLabel(DateTime date) {
    const labels = ['Se', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Do'];

    return labels[date.weekday - 1];
  }
}

class _ScheduleActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ScheduleActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 297),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
        elevation: 4,
        shadowColor: const Color(0x66587DBD),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: double.infinity,
            height: 39,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
