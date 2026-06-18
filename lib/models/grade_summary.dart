import 'assessment.dart';
import 'discipline.dart';

enum GradeStatus { noGrades, approved, attention, risk }

class DisciplineGradeSummary {
  final String disciplineId;
  final double? average;
  final int gradeCount;
  final double totalWeight;
  final GradeStatus status;

  const DisciplineGradeSummary({
    required this.disciplineId,
    required this.average,
    required this.gradeCount,
    required this.totalWeight,
    required this.status,
  });
}

class GradeSummary {
  final int totalGrades;
  final double totalWeights;
  final Map<String, DisciplineGradeSummary> disciplineSummaries;

  const GradeSummary({
    required this.totalGrades,
    required this.totalWeights,
    required this.disciplineSummaries,
  });

  factory GradeSummary.calculate({
    required List<Discipline> disciplines,
    required List<Assessment> assessments,
    required double passingGrade,
  }) {
    final disciplineIds = disciplines
        .map((discipline) => discipline.id)
        .toSet();
    final grouped = <String, List<Assessment>>{};
    for (final assessment in assessments) {
      final discId = assessment.disciplineId;
      if (discId != null && disciplineIds.contains(discId)) {
        grouped.putIfAbsent(discId, () => []).add(assessment);
      }
    }

    final disciplineSummaries = <String, DisciplineGradeSummary>{};
    var totalGrades = 0;
    var totalWeights = 0.0;

    for (final discipline in disciplines) {
      final list = grouped[discipline.id] ?? const [];
      totalGrades += list.length;

      var sumProduct = 0.0;
      var sumWeight = 0.0;
      for (final assessment in list) {
        sumProduct += assessment.grade * assessment.weight;
        sumWeight += assessment.weight;
      }
      totalWeights += sumWeight;

      final average = sumWeight > 0 ? (sumProduct / sumWeight) : null;
      disciplineSummaries[discipline.id] = DisciplineGradeSummary(
        disciplineId: discipline.id,
        average: average,
        gradeCount: list.length,
        totalWeight: sumWeight,
        status: statusForAverage(average, passingGrade),
      );
    }

    return GradeSummary(
      totalGrades: totalGrades,
      totalWeights: totalWeights,
      disciplineSummaries: disciplineSummaries,
    );
  }

  Iterable<DisciplineGradeSummary> get summaries => disciplineSummaries.values;

  double? averageFor(String disciplineId) {
    return disciplineSummaries[disciplineId]?.average;
  }

  int gradeCountFor(String disciplineId) {
    return disciplineSummaries[disciplineId]?.gradeCount ?? 0;
  }

  double totalWeightFor(String disciplineId) {
    return disciplineSummaries[disciplineId]?.totalWeight ?? 0;
  }

  GradeStatus statusFor(String disciplineId) {
    return disciplineSummaries[disciplineId]?.status ?? GradeStatus.noGrades;
  }

  int countByStatus(GradeStatus status) {
    return summaries.where((summary) => summary.status == status).length;
  }

  static GradeStatus statusForAverage(double? average, double passingGrade) {
    if (average == null) return GradeStatus.noGrades;
    if (average < passingGrade) return GradeStatus.risk;

    final attentionCeiling = (passingGrade + 0.5).clamp(0.0, 10.0).toDouble();
    if (average < attentionCeiling) return GradeStatus.attention;

    return GradeStatus.approved;
  }
}
