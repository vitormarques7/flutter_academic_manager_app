import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicSubject {
  final String id;
  final String name;
  final String teacher;
  final double frequency;
  final double average;
  final int workload;
  final List<Map<String, dynamic>> schedule;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AcademicSubject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.frequency,
    required this.average,
    required this.workload,
    required this.schedule,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory AcademicSubject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
    String userId,
  ) {
    return AcademicSubject.fromMap(
      id: document.id,
      userId: userId,
      data: document.data() ?? {},
    );
  }

  factory AcademicSubject.fromMap({
    required String id,
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return AcademicSubject(
      id: id,
      name: data['name'] as String? ?? '',
      teacher: data['teacher'] as String? ?? 'Professor não informado',
      frequency: (data['frequency'] as num?)?.toDouble() ?? 0,
      average: (data['average'] as num?)?.toDouble() ?? 0,
      workload: data['workload'] as int? ?? 0,
      schedule: _readSchedule(data['schedule']),
      userId: userId,
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  static List<Map<String, dynamic>> _readSchedule(Object? value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

class SubjectInput {
  final String name;
  final String teacher;
  final int workload;
  final List<Map<String, dynamic>> schedule;
  final double frequency;
  final double average;

  const SubjectInput({
    required this.name,
    this.teacher = 'Professor não informado',
    this.workload = 0,
    this.schedule = const [],
    this.frequency = 0,
    this.average = 0,
  });

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'teacher': teacher,
      'workload': workload,
      'schedule': schedule,
      'frequency': frequency,
      'average': average,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
