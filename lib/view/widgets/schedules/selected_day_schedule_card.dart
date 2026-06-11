import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import 'schedule_models.dart';

class SelectedDayScheduleCard extends StatelessWidget {
  final DateTime selectedDay;
  final List<ScheduleClassInfo> classes;
  final List<ScheduleEventInfo> events;

  const SelectedDayScheduleCard({
    super.key,
    required this.selectedDay,
    required this.classes,
    this.events = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasClasses = classes.isNotEmpty;
    final hasEvents = events.isNotEmpty;

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
          if (!hasClasses && !hasEvents)
            const _EmptyScheduleMessage()
          else ...[
            if (hasClasses) ...[
              const _CardSectionLabel('Aulas'),
              const SizedBox(height: 12),
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
            if (hasClasses && hasEvents) ...[
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E4F0)),
              const SizedBox(height: 18),
            ],
            if (hasEvents) ...[
              const _CardSectionLabel('Eventos'),
              const SizedBox(height: 12),
              Column(
                children: List.generate(events.length, (index) {
                  final eventInfo = events[index];
                  final isLast = index == events.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                    child: _ScheduleEventRow(eventInfo: eventInfo),
                  );
                }),
              ),
            ],
          ],
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

class _CardSectionLabel extends StatelessWidget {
  final String label;

  const _CardSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF464552),
        fontSize: 12,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ScheduleClassRow extends StatelessWidget {
  final ScheduleClassInfo classInfo;

  const _ScheduleClassRow({required this.classInfo});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: classInfo.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
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
                child: Icon(
                  classInfo.icon,
                  color: classInfo.iconColor,
                  size: 26,
                ),
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
          ),
        ),
      ),
    );
  }
}

class _ScheduleEventRow extends StatelessWidget {
  final ScheduleEventInfo eventInfo;

  const _ScheduleEventRow({required this.eventInfo});

  @override
  Widget build(BuildContext context) {
    final subtitle = eventInfo.subject.isEmpty
        ? eventInfo.typeLabel
        : '${eventInfo.typeLabel} • ${eventInfo.subject}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: eventInfo.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: eventInfo.description.isEmpty ? 44 : 58,
                decoration: BoxDecoration(
                  color: eventInfo.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: eventInfo.iconBackground,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: const Color(0x2ED1D1D1)),
                  boxShadow: [
                    BoxShadow(
                      color: eventInfo.iconColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  eventInfo.icon,
                  color: eventInfo.iconColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventInfo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF656565),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.05,
                      ),
                    ),
                    if (eventInfo.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        eventInfo.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF656565),
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.25,
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
        'Nenhum horário ou evento para este dia',
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
