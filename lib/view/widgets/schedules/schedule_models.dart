import 'package:flutter/material.dart';

class ScheduleClassInfo {
  final String title;
  final String timeRange;
  final IconData icon;
  final Color accentColor;
  final Color iconColor;
  final Color iconBackground;

  const ScheduleClassInfo({
    required this.title,
    required this.timeRange,
    required this.icon,
    required this.accentColor,
    required this.iconColor,
    required this.iconBackground,
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
  final String code;
  final String teacher;
  final String? note;
  final Color color;
  final Color accentColor;

  const PeriodScheduleClass({
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
