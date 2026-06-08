import 'package:cloud_firestore/cloud_firestore.dart';

enum StudyCycleType {
  university('university'),
  highSchool('highSchool'),
  independent('independent');

  final String firestoreValue;

  const StudyCycleType(this.firestoreValue);

  static StudyCycleType fromFirestore(Object? value) {
    if (value is! String) return StudyCycleType.independent;

    return StudyCycleType.values.firstWhere(
      (type) => type.firestoreValue == value,
      orElse: () => StudyCycleType.independent,
    );
  }
}

class StudyCycle {
  final String id;
  final StudyCycleType type;
  final String? courseName;
  final int? period;
  final int? schoolYear;
  final String? goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudyCycle({
    required this.id,
    required this.type,
    this.courseName,
    this.period,
    this.schoolYear,
    this.goal,
    this.createdAt,
    this.updatedAt,
  });

  factory StudyCycle.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return StudyCycle.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory StudyCycle.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return StudyCycle(
      id: id,
      type: StudyCycleType.fromFirestore(data['type']),
      courseName: _readString(data['courseName']),
      period: _readPositiveInt(data['period']),
      schoolYear: _readPositiveInt(data['schoolYear']),
      goal: _readString(data['goal']),
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.firestoreValue,
      'courseName': courseName,
      'period': period,
      'schoolYear': schoolYear,
      'goal': goal,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static int compareByMostRecent(StudyCycle a, StudyCycle b) {
    final aDate = a.updatedAt ?? a.createdAt;
    final bDate = b.updatedAt ?? b.createdAt;

    if (aDate == null && bDate == null) return a.id.compareTo(b.id);
    if (aDate == null) return 1;
    if (bDate == null) return -1;

    final dateComparison = bDate.compareTo(aDate);
    if (dateComparison != 0) return dateComparison;

    return a.id.compareTo(b.id);
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _readPositiveInt(Object? value) {
    if (value is! int || value <= 0) return null;
    return value;
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

class StudyCycleInput {
  final StudyCycleType type;
  final String? courseName;
  final int? period;
  final int? schoolYear;
  final String? goal;

  const StudyCycleInput({
    required this.type,
    this.courseName,
    this.period,
    this.schoolYear,
    this.goal,
  });

  Map<String, dynamic> toCreateMap() {
    return {...toUpdateMap(), 'createdAt': FieldValue.serverTimestamp()};
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'type': type.firestoreValue,
      'courseName': _normalizeString(courseName),
      'period': _normalizePositiveInt(period),
      'schoolYear': _normalizePositiveInt(schoolYear),
      'goal': _normalizeString(goal),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String? _normalizeString(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static int? _normalizePositiveInt(int? value) {
    if (value == null || value <= 0) return null;
    return value;
  }
}
