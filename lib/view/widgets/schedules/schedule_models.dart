import 'package:flutter/material.dart';

class ScheduleClassInfo {
  final String title;
  final String timeRange;
  final IconData icon;
  final Color accentColor;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;

  const ScheduleClassInfo({
    required this.title,
    required this.timeRange,
    required this.icon,
    required this.accentColor,
    required this.iconColor,
    required this.iconBackground,
    this.onTap,
  });
}

enum ScheduleCalendarMarkerKind { classSchedule, subjectEvent, academicTask }

class ScheduleCalendarMarker {
  final Color color;
  final ScheduleCalendarMarkerKind kind;

  const ScheduleCalendarMarker({required this.color, required this.kind});
}

class ScheduleEventInfo {
  final String title;
  final String subject;
  final String typeLabel;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;

  const ScheduleEventInfo({
    required this.title,
    required this.subject,
    required this.typeLabel,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.iconColor,
    required this.iconBackground,
    this.onTap,
  });
}

class ScheduleDay {
  final String weekday;
  final List<PeriodScheduleClass> classes;

  const ScheduleDay({required this.weekday, required this.classes});
}

class PeriodScheduleClass {
  final String timeRange;
  final String title;
  final String shortTitle;
  final String detail;
  final String? note;
  final Color color;
  final Color accentColor;

  const PeriodScheduleClass({
    required this.timeRange,
    required this.title,
    required this.shortTitle,
    required this.detail,
    required this.color,
    required this.accentColor,
    this.note,
  });
}

class ScheduleTaskInfo {
  final String title;
  final String subject;
  final String typeLabel;
  final bool isChecked;
  final IconData icon;
  final Color accentColor;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;

  const ScheduleTaskInfo({
    required this.title,
    required this.subject,
    required this.typeLabel,
    required this.isChecked,
    required this.icon,
    required this.accentColor,
    required this.iconColor,
    required this.iconBackground,
    this.onTap,
  });
}
