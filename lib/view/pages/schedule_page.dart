import 'package:flutter/material.dart';

import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_colors.dart';
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
  static final DateTime _initialSelectedDay = _dateOnly(DateTime(2026, 5, 14));

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isShowingCourseSchedule = false;

  final Map<DateTime, List<ScheduleClassInfo>> _classesByDay = {
    _dateOnly(DateTime(2026, 5, 14)): const [
      ScheduleClassInfo(
        title: 'Banco de Dados',
        timeRange: '13:00 - 17:30',
        icon: Icons.computer_outlined,
        accentColor: Color(0xFF8A38F5),
        iconColor: Color(0xFF514EB6),
        iconBackground: Color(0xFFF0ECFF),
      ),
      ScheduleClassInfo(
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
      return CourseScheduleView(
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
                    ScheduleHeader(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      onPreviousDay: () => _changeSelectedDay(-1),
                      onNextDay: () => _changeSelectedDay(1),
                      onCourseScheduleTap: () {
                        setState(() => _isShowingCourseSchedule = true);
                      },
                    ),
                    const SizedBox(height: 31),
                    MonthCalendar(
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
