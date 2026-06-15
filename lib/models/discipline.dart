import 'package:cloud_firestore/cloud_firestore.dart';

class Discipline {
  static const int defaultColorValue = 0xFF514EB6;

  final String id;
  final String name;
  final String teacher;
  final int workload;
  final int colorValue;
  final String studyCycleId;
  final int absences;
  final int maxAbsences;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Discipline({
    required this.id,
    required this.name,
    required this.teacher,
    required this.workload,
    required this.colorValue,
    required this.studyCycleId,
    this.absences = 0,
    this.maxAbsences = 12,
    this.createdAt,
    this.updatedAt,
  });

  factory Discipline.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return Discipline.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory Discipline.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final workloadVal = _readNonNegativeInt(data['workload']);
    return Discipline(
      id: id,
      name: _readString(data['name']),
      teacher: _readString(data['teacher']),
      workload: workloadVal,
      colorValue: _readColorValue(data['colorValue']),
      studyCycleId: _readString(data['studyCycleId']),
      absences: _readNonNegativeInt(data['absences']),
      maxAbsences: data['maxAbsences'] is int
          ? data['maxAbsences'] as int
          : (workloadVal > 0 ? (workloadVal * 0.25).round() : 12),
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'teacher': teacher,
      'workload': workload,
      'colorValue': colorValue,
      'studyCycleId': studyCycleId,
      'absences': absences,
      'maxAbsences': maxAbsences,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Discipline copyWith({
    String? id,
    String? name,
    String? teacher,
    int? workload,
    int? colorValue,
    String? studyCycleId,
    int? absences,
    int? maxAbsences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Discipline(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      workload: workload ?? this.workload,
      colorValue: colorValue ?? this.colorValue,
      studyCycleId: studyCycleId ?? this.studyCycleId,
      absences: absences ?? this.absences,
      maxAbsences: maxAbsences ?? this.maxAbsences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int compareByName(Discipline a, Discipline b) {
    final nameComparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (nameComparison != 0) return nameComparison;

    return a.id.compareTo(b.id);
  }

  static String _readString(Object? value) {
    if (value is! String) return '';
    return value.trim();
  }

  static int _readNonNegativeInt(Object? value) {
    if (value is! int || value < 0) return 0;
    return value;
  }

  static int _readColorValue(Object? value) {
    if (value is! int || value < 0) return defaultColorValue;
    return value;
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

class DisciplineInput {
  final String name;
  final String teacher;
  final int workload;
  final int colorValue;
  final String studyCycleId;
  final int absences;
  final int maxAbsences;

  const DisciplineInput({
    required this.name,
    required this.teacher,
    required this.workload,
    required this.colorValue,
    required this.studyCycleId,
    this.absences = 0,
    this.maxAbsences = 12,
  });

  DisciplineInput copyWith({
    String? name,
    String? teacher,
    int? workload,
    int? colorValue,
    String? studyCycleId,
    int? absences,
    int? maxAbsences,
  }) {
    return DisciplineInput(
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      workload: workload ?? this.workload,
      colorValue: colorValue ?? this.colorValue,
      studyCycleId: studyCycleId ?? this.studyCycleId,
      absences: absences ?? this.absences,
      maxAbsences: maxAbsences ?? this.maxAbsences,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {...toUpdateMap(), 'createdAt': FieldValue.serverTimestamp()};
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name.trim(),
      'teacher': teacher.trim(),
      'workload': workload < 0 ? 0 : workload,
      'colorValue': colorValue < 0 ? Discipline.defaultColorValue : colorValue,
      'studyCycleId': studyCycleId.trim(),
      'absences': absences < 0 ? 0 : absences,
      'maxAbsences': maxAbsences <= 0
          ? (workload > 0 ? (workload * 0.25).round() : 12)
          : maxAbsences,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
