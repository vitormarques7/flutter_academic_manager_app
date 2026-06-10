import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../config/theme/app_colors.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<Color>> classColorsByDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onFocusedDayChanged;

  const MonthCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.classColorsByDay,
    required this.onDaySelected,
    required this.onFocusedDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Color>(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      eventLoader: (day) => classColorsByDay[_dateOnly(day)] ?? const [],
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
        markerSize: 4,
        markersMaxCount: 3,
        markersAnchor: 0.78,
        markersAlignment: Alignment.bottomCenter,
      ),
      calendarBuilders: const CalendarBuilders<Color>(
        selectedBuilder: _selectedDayBuilder,
        todayBuilder: _todayBuilder,
        markerBuilder: _markerBuilder,
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

  static Widget _markerBuilder(
    BuildContext context,
    DateTime day,
    List<Color> events,
  ) {
    if (events.isEmpty) return const SizedBox.shrink();

    final markerColors = events.take(3).toList();

    return Positioned(
      bottom: 7,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: markerColors.map((color) {
          return Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        }).toList(),
      ),
    );
  }

  static String _weekdayLabel(DateTime date) {
    const labels = ['Se', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Do'];
    return labels[date.weekday - 1];
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
