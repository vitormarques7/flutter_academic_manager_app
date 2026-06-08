import 'package:academic_manager_app/models/discipline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Discipline', () {
    test('fromMap preserves valid fields', () {
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 8, 8));
      final updatedAt = Timestamp.fromDate(DateTime(2026, 6, 8, 9));

      final discipline = Discipline.fromMap(
        id: 'discipline-1',
        data: {
          'name': ' Programacao Mobile ',
          'teacher': ' Elisson Rocha ',
          'workload': 60,
          'colorValue': 0xFFEAF2FF,
          'studyCycleId': ' cycle-1 ',
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );

      expect(discipline.id, 'discipline-1');
      expect(discipline.name, 'Programacao Mobile');
      expect(discipline.teacher, 'Elisson Rocha');
      expect(discipline.workload, 60);
      expect(discipline.colorValue, 0xFFEAF2FF);
      expect(discipline.studyCycleId, 'cycle-1');
      expect(discipline.createdAt, createdAt.toDate());
      expect(discipline.updatedAt, updatedAt.toDate());
    });

    test('fromMap applies predictable defaults for missing fields', () {
      final discipline = Discipline.fromMap(id: 'discipline-1', data: const {});

      expect(discipline.name, isEmpty);
      expect(discipline.teacher, isEmpty);
      expect(discipline.workload, 0);
      expect(discipline.colorValue, Discipline.defaultColorValue);
      expect(discipline.studyCycleId, isEmpty);
      expect(discipline.createdAt, isNull);
      expect(discipline.updatedAt, isNull);
    });

    test('fromMap ignores invalid numeric and timestamp values', () {
      final discipline = Discipline.fromMap(
        id: 'discipline-1',
        data: const {
          'workload': -1,
          'colorValue': -10,
          'createdAt': 'invalid',
          'updatedAt': 'invalid',
        },
      );

      expect(discipline.workload, 0);
      expect(discipline.colorValue, Discipline.defaultColorValue);
      expect(discipline.createdAt, isNull);
      expect(discipline.updatedAt, isNull);
    });

    test('toFirestore can be reconstructed without semantic loss', () {
      final original = Discipline(
        id: 'discipline-1',
        name: 'Banco de Dados',
        teacher: 'Cleiton Martins',
        workload: 80,
        colorValue: 0xFFF0ECFF,
        studyCycleId: 'cycle-1',
        createdAt: DateTime(2026, 6, 8, 10),
        updatedAt: DateTime(2026, 6, 8, 11),
      );

      final reconstructed = Discipline.fromMap(
        id: original.id,
        data: original.toFirestore(),
      );

      expect(reconstructed.id, original.id);
      expect(reconstructed.name, original.name);
      expect(reconstructed.teacher, original.teacher);
      expect(reconstructed.workload, original.workload);
      expect(reconstructed.colorValue, original.colorValue);
      expect(reconstructed.studyCycleId, original.studyCycleId);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.updatedAt, original.updatedAt);
    });

    test('compareByName orders by normalized name and id', () {
      final disciplines = [
        const Discipline(
          id: 'discipline-3',
          name: 'calculo',
          teacher: '',
          workload: 0,
          colorValue: Discipline.defaultColorValue,
          studyCycleId: 'cycle-1',
        ),
        const Discipline(
          id: 'discipline-2',
          name: 'Banco de Dados',
          teacher: '',
          workload: 0,
          colorValue: Discipline.defaultColorValue,
          studyCycleId: 'cycle-1',
        ),
        const Discipline(
          id: 'discipline-1',
          name: 'banco de dados',
          teacher: '',
          workload: 0,
          colorValue: Discipline.defaultColorValue,
          studyCycleId: 'cycle-1',
        ),
      ];

      disciplines.sort(Discipline.compareByName);

      expect(disciplines.map((discipline) => discipline.id), [
        'discipline-1',
        'discipline-2',
        'discipline-3',
      ]);
    });
  });

  group('DisciplineInput', () {
    test('toCreateMap serializes fields for a new discipline', () {
      const input = DisciplineInput(
        name: ' Programacao Mobile ',
        teacher: ' Elisson Rocha ',
        workload: 60,
        colorValue: 0xFFEAF2FF,
        studyCycleId: ' cycle-1 ',
      );

      final map = input.toCreateMap();

      expect(map['name'], 'Programacao Mobile');
      expect(map['teacher'], 'Elisson Rocha');
      expect(map['workload'], 60);
      expect(map['colorValue'], 0xFFEAF2FF);
      expect(map['studyCycleId'], 'cycle-1');
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('toUpdateMap serializes editable fields only', () {
      const input = DisciplineInput(
        name: 'Calculo',
        teacher: '',
        workload: -1,
        colorValue: -1,
        studyCycleId: 'cycle-1',
      );

      final map = input.toUpdateMap();

      expect(map['name'], 'Calculo');
      expect(map['teacher'], isEmpty);
      expect(map['workload'], 0);
      expect(map['colorValue'], Discipline.defaultColorValue);
      expect(map['studyCycleId'], 'cycle-1');
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map.containsKey('createdAt'), isFalse);
    });
  });
}
