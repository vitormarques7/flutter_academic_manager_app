import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_theme_colors.dart';

class ScheduleHeader extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onCourseScheduleTap;

  const ScheduleHeader({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onCourseScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
                      style: TextStyle(
                        color: colors.textDark,
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
                        color: colors.textMedium,
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

    if (isToday) return 'Hoje';

    final weekday = DateFormat.EEEE('pt_BR').format(day);
    return '${weekday[0].toUpperCase()}${weekday.substring(1)}';
  }
}

class _DateTile extends StatelessWidget {
  final DateTime date;

  const _DateTile({required this.date});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final weekday = DateFormat.E('pt_BR').format(date).replaceAll('.', '');
    final capitalizedWeekday =
        '${weekday[0].toUpperCase()}${weekday.substring(1)}.';

    return Container(
      width: 118,
      height: 112,
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
        boxShadow: colors.subtleShadows,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            capitalizedWeekday,
            style: TextStyle(
              color: colors.textMedium,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: TextStyle(
              color: colors.textDark,
              fontSize: 60,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
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
    final colors = context.appColors;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.primarySurface,
        shape: const CircleBorder(),
        shadowColor: colors.primary.withValues(alpha: 0.18),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: colors.primary, size: 35),
          ),
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
    final colors = context.appColors;

    return Tooltip(
      message: 'Abrir grade de horário',
      child: Material(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: colors.primary.withValues(alpha: 0.14),
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
                  Icon(
                    Icons.event_note_outlined,
                    color: colors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'Grade de Horário',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primary,
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
