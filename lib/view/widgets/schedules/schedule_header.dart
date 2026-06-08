import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                      style: const TextStyle(
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
