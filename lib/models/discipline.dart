import 'package:cloud_firestore/cloud_firestore.dart';

class Discipline {
  static const int defaultColorValue = 0xFF514EB6;

  final String id;
  final String name;
  final String teacher;
  final int workload;
  final int colorValue;
  final String studyCycleId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Discipline({
    required this.id,
    required this.name,
    required this.teacher,
    required this.workload,
    required this.colorValue,
    required this.studyCycleId,
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
    return Discipline(
      id: id,
      name: _readString(data['name']),
      teacher: _readString(data['teacher']),
      workload: _readNonNegativeInt(data['workload']),
      colorValue: _readColorValue(data['colorValue']),
      studyCycleId: _readString(data['studyCycleId']),
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
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
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

  const DisciplineInput({
    required this.name,
    required this.teacher,
    required this.workload,
    required this.colorValue,
    required this.studyCycleId,
  });

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
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
