import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../config/theme/app_theme_colors.dart';
import 'schedule_models.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<ScheduleCalendarMarker>> markerColorsByDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onFocusedDayChanged;

  const MonthCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.markerColorsByDay,
    required this.onDaySelected,
    required this.onFocusedDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final weekdayStyle = TextStyle(
      color: colors.textMedium,
      fontSize: 15,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      height: 1.1,
    );
    final dayStyle = TextStyle(
      color: colors.textDark,
      fontSize: 15,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      height: 1,
    );

    return TableCalendar<ScheduleCalendarMarker>(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      eventLoader: (day) => markerColorsByDay[_dateOnly(day)] ?? const [],
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
      availableGestures: AvailableGestures.horizontalSwipe,
      headerVisible: false,
      pageAnimationEnabled: true,
      pageAnimationCurve: Curves.easeOutCubic,
      pageAnimationDuration: const Duration(milliseconds: 300),
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
        weekdayStyle: weekdayStyle,
        weekendStyle: weekdayStyle,
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        cellMargin: EdgeInsets.zero,
        cellPadding: EdgeInsets.zero,
        defaultTextStyle: dayStyle,
        weekendTextStyle: dayStyle,
        outsideTextStyle: dayStyle.copyWith(color: colors.textSubtle),
        selectedTextStyle: dayStyle.copyWith(color: colors.textOnPrimary),
        todayTextStyle: dayStyle,
        selectedDecoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(color: Colors.transparent),
        markerSize: 4,
        markersMaxCount: 1,
        markersAnchor: 0.78,
        markersAlignment: Alignment.bottomCenter,
      ),
      calendarBuilders: const CalendarBuilders<ScheduleCalendarMarker>(
        selectedBuilder: _selectedDayBuilder,
        todayBuilder: _todayBuilder,
        markerBuilder: _markerBuilder,
      ),
    );
  }

  static Widget _selectedDayBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    final colors = context.appColors;

    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: colors.textOnPrimary,
              fontSize: 15,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _todayBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    final colors = context.appColors;

    return Center(
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: colors.textDark,
          fontSize: 15,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
          height: 1,
        ),
      ),
    );
  }

  static Widget _markerBuilder(
    BuildContext context,
    DateTime day,
    List<ScheduleCalendarMarker> events,
  ) {
    if (events.isEmpty) return const SizedBox.shrink();

    final hasClass = events.any(
      (event) => event.kind == ScheduleCalendarMarkerKind.classSchedule,
    );
    final hasEvent = events.any(
      (event) => event.kind == ScheduleCalendarMarkerKind.subjectEvent,
    );
    final hasTask = events.any(
      (event) => event.kind == ScheduleCalendarMarkerKind.academicTask,
    );

    final colors = context.appColors;
    final activeSegments = <Widget>[];

    final activeKinds = [
      if (hasClass) ScheduleCalendarMarkerKind.classSchedule,
      if (hasEvent) ScheduleCalendarMarkerKind.subjectEvent,
      if (hasTask) ScheduleCalendarMarkerKind.academicTask,
    ];

    if (activeKinds.isEmpty) return const SizedBox.shrink();

    final double segmentWidth = 20.0 / activeKinds.length;

    for (int i = 0; i < activeKinds.length; i++) {
      final kind = activeKinds[i];
      final color = switch (kind) {
        ScheduleCalendarMarkerKind.classSchedule => colors.primary,
        ScheduleCalendarMarkerKind.subjectEvent => colors.event,
        ScheduleCalendarMarkerKind.academicTask => colors.success,
      };

      activeSegments.add(
        _ActivitySegment(
          width: segmentWidth,
          color: color,
          leftRadius: i == 0,
          rightRadius: i == activeKinds.length - 1,
        ),
      );
    }

    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: activeSegments,
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

class _ActivitySegment extends StatelessWidget {
  final double width;
  final Color color;
  final bool leftRadius;
  final bool rightRadius;

  const _ActivitySegment({
    required this.width,
    required this.color,
    required this.leftRadius,
    required this.rightRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(leftRadius ? 999 : 0),
          right: Radius.circular(rightRadius ? 999 : 0),
        ),
      ),
    );
  }
}
