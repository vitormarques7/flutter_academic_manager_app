import 'package:academic_manager_app/models/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Schedule', () {
    test('fromMap preserves valid fields', () {
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 8, 8));
      final updatedAt = Timestamp.fromDate(DateTime(2026, 6, 8, 9));

      final schedule = Schedule.fromMap(
        id: 'schedule-1',
        data: {
          'studyCycleId': ' cycle-1 ',
          'disciplineName': 'Programacao Mobile',
          'weekdays': [1, 3, 5],
          'startTimeMinutes': 450,
          'endTimeMinutes': 630,
          'colorValue': 0xFFEAF2FF,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );

      expect(schedule.id, 'schedule-1');
      expect(schedule.studyCycleId, 'cycle-1');
      expect(schedule.disciplineName, 'Programacao Mobile');
      expect(schedule.weekdays, [1, 3, 5]);
      expect(schedule.startTimeMinutes, 450);
      expect(schedule.endTimeMinutes, 630);
      expect(schedule.colorValue, 0xFFEAF2FF);
      expect(schedule.createdAt, createdAt.toDate());
      expect(schedule.updatedAt, updatedAt.toDate());
    });

    test('fromMap applies predictable defaults for missing fields', () {
      final schedule = Schedule.fromMap(id: 'schedule-1', data: const {});

      expect(schedule.disciplineName, isEmpty);
      expect(schedule.studyCycleId, isNull);
      expect(schedule.weekdays, isEmpty);
      expect(schedule.startTimeMinutes, 0);
      expect(schedule.endTimeMinutes, 0);
      expect(schedule.colorValue, Schedule.defaultColorValue);
      expect(schedule.createdAt, isNull);
      expect(schedule.updatedAt, isNull);
    });

    test('fromMap normalizes invalid weekdays and time values', () {
      final schedule = Schedule.fromMap(
        id: 'schedule-1',
        data: {
          'weekdays': [-1, 5, 2, 2, 8, '3', 0],
          'startTimeMinutes': -20,
          'endTimeMinutes': 1440,
        },
      );

      expect(schedule.weekdays, [0, 2, 5]);
      expect(schedule.startTimeMinutes, 0);
      expect(schedule.endTimeMinutes, 0);
    });

    test('toFirestore can be reconstructed without semantic loss', () {
      final original = Schedule(
        id: 'schedule-1',
        studyCycleId: 'cycle-1',
        disciplineName: 'Banco de Dados',
        weekdays: const [2, 4],
        startTimeMinutes: 780,
        endTimeMinutes: 1050,
        colorValue: 0xFFF0ECFF,
        createdAt: DateTime(2026, 6, 8, 10),
        updatedAt: DateTime(2026, 6, 8, 11),
      );

      final reconstructed = Schedule.fromMap(
        id: original.id,
        data: original.toFirestore(),
      );

      expect(reconstructed.id, original.id);
      expect(reconstructed.studyCycleId, original.studyCycleId);
      expect(reconstructed.disciplineName, original.disciplineName);
      expect(reconstructed.weekdays, original.weekdays);
      expect(reconstructed.startTimeMinutes, original.startTimeMinutes);
      expect(reconstructed.endTimeMinutes, original.endTimeMinutes);
      expect(reconstructed.colorValue, original.colorValue);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.updatedAt, original.updatedAt);
    });

    test('occursOnWeekday supports multiple weekdays', () {
      final schedule = Schedule.fromMap(
        id: 'schedule-1',
        data: const {
          'weekdays': [1, 3, 6],
        },
      );

      expect(schedule.occursOnWeekday(1), isTrue);
      expect(schedule.occursOnWeekday(3), isTrue);
      expect(schedule.occursOnWeekday(6), isTrue);
      expect(schedule.occursOnWeekday(2), isFalse);
    });

    test('formats minutes and time range', () {
      final schedule = Schedule.fromMap(
        id: 'schedule-1',
        data: const {'startTimeMinutes': 450, 'endTimeMinutes': 630},
      );

      expect(Schedule.formatMinutes(0), '00:00');
      expect(Schedule.formatMinutes(450), '07:30');
      expect(Schedule.formatMinutes(1439), '23:59');
      expect(Schedule.formatMinutes(1440), '00:00');
      expect(schedule.formattedStartTime, '07:30');
      expect(schedule.formattedEndTime, '10:30');
      expect(schedule.formattedTimeRange, '07:30 - 10:30');
    });

    test('compareByStartTime orders by start, end, name, and id', () {
      final schedules = [
        const Schedule(
          id: 'schedule-4',
          disciplineName: 'Calculo',
          weekdays: [],
          startTimeMinutes: 500,
          endTimeMinutes: 620,
          colorValue: Schedule.defaultColorValue,
        ),
        const Schedule(
          id: 'schedule-3',
          disciplineName: 'Algebra',
          weekdays: [],
          startTimeMinutes: 450,
          endTimeMinutes: 630,
          colorValue: Schedule.defaultColorValue,
        ),
        const Schedule(
          id: 'schedule-2',
          disciplineName: 'Banco de Dados',
          weekdays: [],
          startTimeMinutes: 450,
          endTimeMinutes: 600,
          colorValue: Schedule.defaultColorValue,
        ),
        const Schedule(
          id: 'schedule-1',
          disciplineName: 'Banco de Dados',
          weekdays: [],
          startTimeMinutes: 450,
          endTimeMinutes: 600,
          colorValue: Schedule.defaultColorValue,
        ),
      ];

      schedules.sort(Schedule.compareByStartTime);

      expect(schedules.map((schedule) => schedule.id), [
        'schedule-1',
        'schedule-2',
        'schedule-3',
        'schedule-4',
      ]);
    });
  });

  group('ScheduleInput', () {
    const input = ScheduleInput(
      studyCycleId: 'cycle-1',
      disciplineName: 'Programacao Mobile',
      weekdays: [3, 1, 3],
      startTimeMinutes: 450,
      endTimeMinutes: 630,
      colorValue: 0xFFEAF2FF,
    );

    test('toCreateMap serializes fields for a new schedule', () {
      final map = input.toCreateMap();

      expect(map['disciplineName'], input.disciplineName);
      expect(map['studyCycleId'], input.studyCycleId);
      expect(map['weekdays'], [1, 3]);
      expect(map['startTimeMinutes'], input.startTimeMinutes);
      expect(map['endTimeMinutes'], input.endTimeMinutes);
      expect(map['colorValue'], input.colorValue);
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('toUpdateMap serializes editable fields only', () {
      final map = input.toUpdateMap();

      expect(map['disciplineName'], input.disciplineName);
      expect(map['studyCycleId'], input.studyCycleId);
      expect(map['weekdays'], [1, 3]);
      expect(map['startTimeMinutes'], input.startTimeMinutes);
      expect(map['endTimeMinutes'], input.endTimeMinutes);
      expect(map['colorValue'], input.colorValue);
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map.containsKey('createdAt'), isFalse);
    });

    test('toUpdateMap keeps studyCycleId absent when it is not provided', () {
      const input = ScheduleInput(
        disciplineName: 'Programacao Mobile',
        weekdays: [1, 3],
        startTimeMinutes: 450,
        endTimeMinutes: 630,
        colorValue: 0xFFEAF2FF,
      );

      final map = input.toUpdateMap();

      expect(map.containsKey('studyCycleId'), isFalse);
    });
  });
}
