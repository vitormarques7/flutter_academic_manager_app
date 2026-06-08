import 'package:academic_manager_app/models/study_cycle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudyCycleType', () {
    test('fromFirestore maps known values and defaults unknown values', () {
      expect(
        StudyCycleType.fromFirestore('university'),
        StudyCycleType.university,
      );
      expect(
        StudyCycleType.fromFirestore('highSchool'),
        StudyCycleType.highSchool,
      );
      expect(
        StudyCycleType.fromFirestore('independent'),
        StudyCycleType.independent,
      );
      expect(
        StudyCycleType.fromFirestore('unknown'),
        StudyCycleType.independent,
      );
      expect(StudyCycleType.fromFirestore(null), StudyCycleType.independent);
    });
  });

  group('StudyCycle', () {
    test('fromMap preserves valid fields', () {
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 8, 8));
      final updatedAt = Timestamp.fromDate(DateTime(2026, 6, 8, 9));

      final cycle = StudyCycle.fromMap(
        id: 'cycle-1',
        data: {
          'type': 'university',
          'courseName': ' Engenharia de Software ',
          'period': 6,
          'schoolYear': 2026,
          'goal': ' Passar em V&V ',
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );

      expect(cycle.id, 'cycle-1');
      expect(cycle.type, StudyCycleType.university);
      expect(cycle.courseName, 'Engenharia de Software');
      expect(cycle.period, 6);
      expect(cycle.schoolYear, 2026);
      expect(cycle.goal, 'Passar em V&V');
      expect(cycle.createdAt, createdAt.toDate());
      expect(cycle.updatedAt, updatedAt.toDate());
    });

    test('fromMap applies predictable defaults for missing fields', () {
      final cycle = StudyCycle.fromMap(id: 'cycle-1', data: const {});

      expect(cycle.type, StudyCycleType.independent);
      expect(cycle.courseName, isNull);
      expect(cycle.period, isNull);
      expect(cycle.schoolYear, isNull);
      expect(cycle.goal, isNull);
      expect(cycle.createdAt, isNull);
      expect(cycle.updatedAt, isNull);
    });

    test('fromMap ignores invalid optional values', () {
      final cycle = StudyCycle.fromMap(
        id: 'cycle-1',
        data: const {
          'courseName': ' ',
          'period': 0,
          'schoolYear': -1,
          'goal': '',
          'createdAt': 'invalid',
          'updatedAt': 'invalid',
        },
      );

      expect(cycle.courseName, isNull);
      expect(cycle.period, isNull);
      expect(cycle.schoolYear, isNull);
      expect(cycle.goal, isNull);
      expect(cycle.createdAt, isNull);
      expect(cycle.updatedAt, isNull);
    });

    test('toFirestore can be reconstructed without semantic loss', () {
      final original = StudyCycle(
        id: 'cycle-1',
        type: StudyCycleType.highSchool,
        schoolYear: 2,
        createdAt: DateTime(2026, 6, 8, 10),
        updatedAt: DateTime(2026, 6, 8, 11),
      );

      final reconstructed = StudyCycle.fromMap(
        id: original.id,
        data: original.toFirestore(),
      );

      expect(reconstructed.id, original.id);
      expect(reconstructed.type, original.type);
      expect(reconstructed.courseName, original.courseName);
      expect(reconstructed.period, original.period);
      expect(reconstructed.schoolYear, original.schoolYear);
      expect(reconstructed.goal, original.goal);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.updatedAt, original.updatedAt);
    });

    test('compareByMostRecent orders by updatedAt, createdAt, and id', () {
      final cycles = [
        StudyCycle(
          id: 'cycle-3',
          type: StudyCycleType.independent,
          createdAt: DateTime(2026, 6, 7),
        ),
        StudyCycle(
          id: 'cycle-2',
          type: StudyCycleType.independent,
          updatedAt: DateTime(2026, 6, 8, 9),
        ),
        StudyCycle(
          id: 'cycle-1',
          type: StudyCycleType.independent,
          updatedAt: DateTime(2026, 6, 8, 9),
        ),
        const StudyCycle(id: 'cycle-4', type: StudyCycleType.independent),
      ];

      cycles.sort(StudyCycle.compareByMostRecent);

      expect(cycles.map((cycle) => cycle.id), [
        'cycle-1',
        'cycle-2',
        'cycle-3',
        'cycle-4',
      ]);
    });
  });

  group('StudyCycleInput', () {
    test('toCreateMap serializes fields for a new study cycle', () {
      const input = StudyCycleInput(
        type: StudyCycleType.university,
        courseName: ' Engenharia de Software ',
        period: 6,
        schoolYear: 0,
        goal: ' ',
      );

      final map = input.toCreateMap();

      expect(map['type'], 'university');
      expect(map['courseName'], 'Engenharia de Software');
      expect(map['period'], 6);
      expect(map['schoolYear'], isNull);
      expect(map['goal'], isNull);
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('toUpdateMap serializes editable fields only', () {
      const input = StudyCycleInput(
        type: StudyCycleType.independent,
        goal: 'Concurso publico',
      );

      final map = input.toUpdateMap();

      expect(map['type'], 'independent');
      expect(map['courseName'], isNull);
      expect(map['period'], isNull);
      expect(map['schoolYear'], isNull);
      expect(map['goal'], 'Concurso publico');
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map.containsKey('createdAt'), isFalse);
    });
  });
}
