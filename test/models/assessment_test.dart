import 'package:academic_manager_app/models/assessment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Assessment', () {
    test('fromMap preserves valid fields', () {
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 10, 8));
      final updatedAt = Timestamp.fromDate(DateTime(2026, 6, 10, 9));

      final assessment = Assessment.fromMap(
        id: 'assessment-1',
        data: {
          'studyCycleId': ' cycle-1 ',
          'disciplineId': ' discipline-1 ',
          'disciplineName': 'Banco de Dados',
          'title': ' Prova 1 ',
          'dateLabel': '10/06/2026',
          'grade': 8.5,
          'weight': 2.5,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );

      expect(assessment.id, 'assessment-1');
      expect(assessment.studyCycleId, 'cycle-1');
      expect(assessment.disciplineId, 'discipline-1');
      expect(assessment.disciplineName, 'Banco de Dados');
      expect(assessment.title, 'Prova 1');
      expect(assessment.dateLabel, '10/06/2026');
      expect(assessment.grade, 8.5);
      expect(assessment.weight, 2.5);
      expect(assessment.formattedGrade, '8.5');
      expect(assessment.createdAt, createdAt.toDate());
      expect(assessment.updatedAt, updatedAt.toDate());
    });

    test('fromMap applies predictable defaults for missing fields', () {
      final assessment = Assessment.fromMap(id: 'assessment-1', data: const {});

      expect(assessment.studyCycleId, isNull);
      expect(assessment.disciplineId, isNull);
      expect(assessment.disciplineName, isEmpty);
      expect(assessment.title, isEmpty);
      expect(assessment.dateLabel, isEmpty);
      expect(assessment.displayDateLabel, 'Sem data');
      expect(assessment.grade, 0);
      expect(assessment.weight, 1.0);
      expect(assessment.createdAt, isNull);
      expect(assessment.updatedAt, isNull);
    });

    test('fromMap clamps invalid grade range', () {
      final high = Assessment.fromMap(
        id: 'assessment-1',
        data: const {'grade': 13},
      );
      final low = Assessment.fromMap(
        id: 'assessment-2',
        data: const {'grade': -2},
      );

      expect(high.grade, 10);
      expect(low.grade, 0);
    });

    test('fromMap defaults invalid weights to 1.0', () {
      final invalidNegative = Assessment.fromMap(
        id: 'assessment-1',
        data: const {'weight': -1.5},
      );
      final invalidZero = Assessment.fromMap(
        id: 'assessment-2',
        data: const {'weight': 0.0},
      );
      final invalidString = Assessment.fromMap(
        id: 'assessment-3',
        data: const {'weight': 'invalid'},
      );

      expect(invalidNegative.weight, 1.0);
      expect(invalidZero.weight, 1.0);
      expect(invalidString.weight, 1.0);
    });

    test('toFirestore can be reconstructed without semantic loss', () {
      final original = Assessment(
        id: 'assessment-1',
        studyCycleId: 'cycle-1',
        disciplineId: 'discipline-1',
        disciplineName: 'Calculo',
        title: 'Lista',
        dateLabel: '12/06/2026',
        grade: 7.25,
        weight: 3.0,
        createdAt: DateTime(2026, 6, 10, 8),
        updatedAt: DateTime(2026, 6, 10, 9),
      );

      final reconstructed = Assessment.fromMap(
        id: original.id,
        data: original.toFirestore(),
      );

      expect(reconstructed.id, original.id);
      expect(reconstructed.studyCycleId, original.studyCycleId);
      expect(reconstructed.disciplineId, original.disciplineId);
      expect(reconstructed.disciplineName, original.disciplineName);
      expect(reconstructed.title, original.title);
      expect(reconstructed.dateLabel, original.dateLabel);
      expect(reconstructed.grade, original.grade);
      expect(reconstructed.weight, original.weight);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.updatedAt, original.updatedAt);
    });
  });

  group('AssessmentInput', () {
    const input = AssessmentInput(
      studyCycleId: ' cycle-1 ',
      disciplineId: ' discipline-1 ',
      disciplineName: ' Banco de Dados ',
      title: ' Prova 1 ',
      dateLabel: ' 10/06/2026 ',
      grade: 11,
      weight: 1.5,
    );

    test('toCreateMap serializes fields for a new assessment', () {
      final map = input.toCreateMap();

      expect(map['studyCycleId'], 'cycle-1');
      expect(map['disciplineId'], 'discipline-1');
      expect(map['disciplineName'], 'Banco de Dados');
      expect(map['title'], 'Prova 1');
      expect(map['dateLabel'], '10/06/2026');
      expect(map['grade'], 10);
      expect(map['weight'], 1.5);
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('toUpdateMap serializes editable fields only', () {
      final map = input.toUpdateMap();

      expect(map['studyCycleId'], 'cycle-1');
      expect(map['disciplineId'], 'discipline-1');
      expect(map['disciplineName'], 'Banco de Dados');
      expect(map['title'], 'Prova 1');
      expect(map['dateLabel'], '10/06/2026');
      expect(map['grade'], 10);
      expect(map['weight'], 1.5);
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map.containsKey('createdAt'), isFalse);
    });
  });
}
