import 'package:academic_manager_app/config/theme/app_theme.dart';
import 'package:academic_manager_app/config/theme/app_theme_colors.dart';
import 'package:academic_manager_app/view/widgets/schedules/month_calendar.dart';
import 'package:academic_manager_app/view/widgets/schedules/schedule_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  Widget buildTestableWidget({
    required DateTime focusedDay,
    required DateTime selectedDay,
    required Map<DateTime, List<ScheduleCalendarMarker>> markerColorsByDay,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: MonthCalendar(
          focusedDay: focusedDay,
          selectedDay: selectedDay,
          markerColorsByDay: markerColorsByDay,
          onDaySelected: (_) {},
          onFocusedDayChanged: (_) {},
        ),
      ),
    );
  }

  group('MonthCalendar Markers', () {
    testWidgets('renders single classSchedule marker with width 20', (tester) async {
      final day = DateTime(2026, 6, 15);
      final markers = {
        day: const [
          ScheduleCalendarMarker(
            color: Colors.purple,
            kind: ScheduleCalendarMarkerKind.classSchedule,
          ),
        ],
      };

      await tester.pumpWidget(
        buildTestableWidget(
          focusedDay: day,
          selectedDay: day.add(const Duration(days: 2)),
          markerColorsByDay: markers,
        ),
      );

      final containerFinder = find.byType(Container);
      bool foundSegment = false;

      final containers = tester.widgetList<Container>(containerFinder);
      for (final container in containers) {
        if (container.constraints?.maxHeight == 4 && container.decoration is BoxDecoration) {
          final boxDec = container.decoration as BoxDecoration;
          if (boxDec.color == AppThemeColors.light.primary) {
            foundSegment = true;
          }
        }
      }

      expect(foundSegment, isTrue);
    });

    testWidgets('renders dual markers (classSchedule + subjectEvent) with width 10 each', (tester) async {
      final day = DateTime(2026, 6, 15);
      final markers = {
        day: const [
          ScheduleCalendarMarker(
            color: Colors.purple,
            kind: ScheduleCalendarMarkerKind.classSchedule,
          ),
          ScheduleCalendarMarker(
            color: Colors.red,
            kind: ScheduleCalendarMarkerKind.subjectEvent,
          ),
        ],
      };

      await tester.pumpWidget(
        buildTestableWidget(
          focusedDay: day,
          selectedDay: day.add(const Duration(days: 2)),
          markerColorsByDay: markers,
        ),
      );

      final containerFinder = find.byType(Container);
      int foundClassSegments = 0;
      int foundEventSegments = 0;

      final containers = tester.widgetList<Container>(containerFinder);
      for (final container in containers) {
        if (container.constraints?.maxHeight == 4 && container.decoration is BoxDecoration) {
          final boxDec = container.decoration as BoxDecoration;
          if (boxDec.color == AppThemeColors.light.primary) {
            foundClassSegments++;
          } else if (boxDec.color == AppThemeColors.light.event) {
            foundEventSegments++;
          }
        }
      }

      expect(foundClassSegments, equals(1));
      expect(foundEventSegments, equals(1));
    });

    testWidgets('renders triple markers (classSchedule + subjectEvent + academicTask) divided by 3', (tester) async {
      final day = DateTime(2026, 6, 15);
      final markers = {
        day: const [
          ScheduleCalendarMarker(
            color: Colors.purple,
            kind: ScheduleCalendarMarkerKind.classSchedule,
          ),
          ScheduleCalendarMarker(
            color: Colors.red,
            kind: ScheduleCalendarMarkerKind.subjectEvent,
          ),
          ScheduleCalendarMarker(
            color: Colors.green,
            kind: ScheduleCalendarMarkerKind.academicTask,
          ),
        ],
      };

      await tester.pumpWidget(
        buildTestableWidget(
          focusedDay: day,
          selectedDay: day.add(const Duration(days: 2)),
          markerColorsByDay: markers,
        ),
      );

      final containerFinder = find.byType(Container);
      int foundClassSegments = 0;
      int foundEventSegments = 0;
      int foundTaskSegments = 0;

      final containers = tester.widgetList<Container>(containerFinder);
      for (final container in containers) {
        if (container.constraints?.maxHeight == 4 && container.decoration is BoxDecoration) {
          final boxDec = container.decoration as BoxDecoration;
          if (boxDec.color == AppThemeColors.light.primary) {
            foundClassSegments++;
          } else if (boxDec.color == AppThemeColors.light.event) {
            foundEventSegments++;
          } else if (boxDec.color == AppThemeColors.light.success) {
            foundTaskSegments++;
          }
        }
      }

      expect(foundClassSegments, equals(1));
      expect(foundEventSegments, equals(1));
      expect(foundTaskSegments, equals(1));
    });

  });
}
