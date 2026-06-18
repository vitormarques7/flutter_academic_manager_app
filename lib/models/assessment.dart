import 'package:cloud_firestore/cloud_firestore.dart';

class Assessment {
  final String id;
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final String title;
  final String dateLabel;
  final double grade;
  final double weight;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Assessment({
    required this.id,
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.title,
    required this.dateLabel,
    required this.grade,
    this.weight = 1.0,
    this.createdAt,
    this.updatedAt,
  });

  factory Assessment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return Assessment.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory Assessment.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return Assessment(
      id: id,
      studyCycleId: _readString(data['studyCycleId']),
      disciplineId: _readString(data['disciplineId']),
      disciplineName: _readString(data['disciplineName']) ?? '',
      title: _readString(data['title']) ?? '',
      dateLabel: _readString(data['dateLabel']) ?? '',
      grade: _readGrade(data['grade']),
      weight: _readWeight(data['weight']),
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (studyCycleId != null) 'studyCycleId': studyCycleId,
      if (disciplineId != null) 'disciplineId': disciplineId,
      'disciplineName': disciplineName,
      'title': title,
      'dateLabel': dateLabel,
      'grade': grade,
      'weight': weight,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  String get formattedGrade => grade.toStringAsFixed(1);

  String get displayDateLabel => dateLabel.isEmpty ? 'Sem data' : dateLabel;

  static int compareByMostRecent(Assessment a, Assessment b) {
    final dateComparison = _compareNullableDate(
      _readDateLabel(b.dateLabel),
      _readDateLabel(a.dateLabel),
    );
    if (dateComparison != 0) return dateComparison;

    final createdAtComparison = _compareNullableDate(b.createdAt, a.createdAt);
    if (createdAtComparison != 0) return createdAtComparison;

    final titleComparison = a.title.toLowerCase().compareTo(
      b.title.toLowerCase(),
    );
    if (titleComparison != 0) return titleComparison;

    return a.id.compareTo(b.id);
  }

  static int _compareNullableDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return a.compareTo(b);
  }

  static DateTime? _readDateLabel(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final parsed = DateTime(year, month, day);
    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return null;
    }

    return parsed;
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double _readGrade(Object? value) {
    if (value is! num) return 0;

    return value.clamp(0, 10).toDouble();
  }

  static double _readWeight(Object? value) {
    if (value is! num || value <= 0) return 1.0;

    return value.toDouble();
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

class AssessmentInput {
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final String title;
  final String dateLabel;
  final double grade;
  final double weight;

  const AssessmentInput({
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.title,
    required this.dateLabel,
    required this.grade,
    this.weight = 1.0,
  });

  Map<String, dynamic> toCreateMap() {
    return {...toUpdateMap(), 'createdAt': FieldValue.serverTimestamp()};
  }

  Map<String, dynamic> toUpdateMap() {
    final normalizedStudyCycleId = Assessment._readString(studyCycleId);
    final normalizedDisciplineId = Assessment._readString(disciplineId);

    return {
      'studyCycleId': ?normalizedStudyCycleId,
      'disciplineId': ?normalizedDisciplineId,
      'disciplineName': disciplineName.trim(),
      'title': title.trim(),
      'dateLabel': dateLabel.trim(),
      'grade': grade.clamp(0, 10).toDouble(),
      'weight': weight > 0 ? weight : 1.0,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
