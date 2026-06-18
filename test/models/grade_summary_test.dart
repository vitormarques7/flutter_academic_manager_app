import 'package:academic_manager_app/models/assessment.dart';
import 'package:academic_manager_app/models/discipline.dart';
import 'package:academic_manager_app/models/grade_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GradeSummary', () {
    final disciplines = [
      const Discipline(
        id: 'disc-1',
        name: 'Cálculo I',
        teacher: 'Professor A',
        workload: 60,
        colorValue: 0xFF123456,
        studyCycleId: 'cycle-1',
      ),
      const Discipline(
        id: 'disc-2',
        name: 'Física I',
        teacher: 'Professor B',
        workload: 60,
        colorValue: 0xFF654321,
        studyCycleId: 'cycle-1',
      ),
      const Discipline(
        id: 'disc-3',
        name: 'Álgebra Linear',
        teacher: 'Professor C',
        workload: 45,
        colorValue: 0xFFABCDEF,
        studyCycleId: 'cycle-1',
      ),
    ];

    test('calculates weighted average per discipline correctly', () {
      final assessments = [
        const Assessment(
          id: 'a1',
          disciplineId: 'disc-1',
          disciplineName: 'Cálculo I',
          title: 'Prova 1',
          dateLabel: '10/06/2026',
          grade: 8.0,
          weight: 1.0,
        ),
        const Assessment(
          id: 'a2',
          disciplineId: 'disc-1',
          disciplineName: 'Cálculo I',
          title: 'Prova 2',
          dateLabel: '20/06/2026',
          grade: 6.0,
          weight: 3.0,
        ),
        const Assessment(
          id: 'a3',
          disciplineId: 'disc-2',
          disciplineName: 'Física I',
          title: 'Prova 1',
          dateLabel: '15/06/2026',
          grade: 9.0,
          weight: 2.0,
        ),
      ];

      final summary = GradeSummary.calculate(
        disciplines: disciplines,
        assessments: assessments,
        passingGrade: 7.0,
      );

      expect(summary.averageFor('disc-1'), closeTo(6.5, 0.001));
      expect(summary.gradeCountFor('disc-1'), 2);
      expect(summary.totalWeightFor('disc-1'), 4.0);
      expect(summary.statusFor('disc-1'), GradeStatus.risk);

      expect(summary.averageFor('disc-2'), closeTo(9.0, 0.001));
      expect(summary.gradeCountFor('disc-2'), 1);
      expect(summary.totalWeightFor('disc-2'), 2.0);
      expect(summary.statusFor('disc-2'), GradeStatus.approved);

      expect(summary.averageFor('disc-3'), isNull);
      expect(summary.statusFor('disc-3'), GradeStatus.noGrades);
    });

    test('keeps totals scoped to known disciplines', () {
      final assessments = [
        const Assessment(
          id: 'a1',
          disciplineId: 'disc-1',
          disciplineName: 'Cálculo I',
          title: 'Prova 1',
          dateLabel: '10/06/2026',
          grade: 5.0,
          weight: 1.0,
        ),
        const Assessment(
          id: 'orphan',
          disciplineId: 'deleted-disc',
          disciplineName: 'Disciplina removida',
          title: 'Prova antiga',
          dateLabel: '15/06/2026',
          grade: 10.0,
          weight: 4.0,
        ),
      ];

      final summary = GradeSummary.calculate(
        disciplines: disciplines,
        assessments: assessments,
        passingGrade: 7.0,
      );

      expect(summary.totalGrades, 1);
      expect(summary.totalWeights, 1.0);
      expect(summary.averageFor('deleted-disc'), isNull);
    });

    test('supports fallback weight of 1.0 for legacy assessments', () {
      final assessments = [
        const Assessment(
          id: 'a1',
          disciplineId: 'disc-1',
          disciplineName: 'Cálculo I',
          title: 'Prova 1',
          dateLabel: '10/06/2026',
          grade: 8.0,
        ),
        const Assessment(
          id: 'a2',
          disciplineId: 'disc-1',
          disciplineName: 'Cálculo I',
          title: 'Prova 2',
          dateLabel: '20/06/2026',
          grade: 10.0,
          weight: 2.0,
        ),
      ];

      final summary = GradeSummary.calculate(
        disciplines: disciplines,
        assessments: assessments,
        passingGrade: 7.0,
      );

      expect(summary.averageFor('disc-1'), closeTo(9.333, 0.001));
      expect(summary.totalWeightFor('disc-1'), 3.0);
    });

    test('handles discipline with no assessments correctly', () {
      final summary = GradeSummary.calculate(
        disciplines: disciplines,
        assessments: const [],
        passingGrade: 7.0,
      );

      expect(summary.totalGrades, 0);
      expect(summary.totalWeights, 0.0);
      expect(summary.averageFor('disc-1'), isNull);
      expect(summary.statusFor('disc-1'), GradeStatus.noGrades);
      expect(summary.countByStatus(GradeStatus.noGrades), 3);
    });

    test('determines individual status using configurable passing grade', () {
      final testCases = [
        (average: 6.9, passingGrade: 7.0, expectedStatus: GradeStatus.risk),
        (
          average: 7.0,
          passingGrade: 7.0,
          expectedStatus: GradeStatus.attention,
        ),
        (
          average: 7.4,
          passingGrade: 7.0,
          expectedStatus: GradeStatus.attention,
        ),
        (average: 7.5, passingGrade: 7.0, expectedStatus: GradeStatus.approved),
        (average: 5.9, passingGrade: 6.0, expectedStatus: GradeStatus.risk),
        (
          average: 6.0,
          passingGrade: 6.0,
          expectedStatus: GradeStatus.attention,
        ),
        (
          average: 6.4,
          passingGrade: 6.0,
          expectedStatus: GradeStatus.attention,
        ),
        (average: 6.5, passingGrade: 6.0, expectedStatus: GradeStatus.approved),
        (
          average: 10.0,
          passingGrade: 9.8,
          expectedStatus: GradeStatus.approved,
        ),
      ];

      for (final tc in testCases) {
        final assessments = [
          Assessment(
            id: 'a1',
            disciplineId: 'disc-1',
            disciplineName: 'Cálculo I',
            title: 'Prova 1',
            dateLabel: '10/06/2026',
            grade: tc.average,
            weight: 1.0,
          ),
        ];

        final summary = GradeSummary.calculate(
          disciplines: disciplines,
          assessments: assessments,
          passingGrade: tc.passingGrade,
        );

        expect(
          summary.statusFor('disc-1'),
          tc.expectedStatus,
          reason:
              'Failed for average: ${tc.average} and passing grade: ${tc.passingGrade}',
        );
      }
    });
  });
}
