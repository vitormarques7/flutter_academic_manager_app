import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import 'schedule_models.dart';

class SelectedDayScheduleCard extends StatelessWidget {
  final DateTime selectedDay;
  final List<ScheduleClassInfo> classes;

  const SelectedDayScheduleCard({
    super.key,
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
  final ScheduleClassInfo classInfo;

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
