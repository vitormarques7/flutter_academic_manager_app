import 'package:cloud_firestore/cloud_firestore.dart';

const Object _copyWithSentinel = Object();

class AcademicTask {
  final String id;
  final String title;
  final String? disciplineId;
  final String subject;
  final String deadline;
  final String visualPriority;
  final String description;
  final bool isChecked;
  final String userId;
  final String? studyCycleId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AcademicTask({
    required this.id,
    required this.title,
    this.disciplineId,
    required this.subject,
    required this.deadline,
    required this.visualPriority,
    required this.description,
    required this.isChecked,
    required this.userId,
    this.studyCycleId,
    this.createdAt,
    this.updatedAt,
  });

  factory AcademicTask.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
    String userId,
  ) {
    return AcademicTask.fromMap(
      id: document.id,
      userId: userId,
      data: document.data() ?? {},
    );
  }

  factory AcademicTask.fromMap({
    required String id,
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return AcademicTask(
      id: id,
      title: data['title'] as String? ?? '',
      disciplineId: _readString(data['disciplineId']),
      subject: data['subject'] as String? ?? '',
      deadline: data['deadline'] as String? ?? '',
      visualPriority: data['visualPriority'] as String? ?? 'Trabalho',
      description: data['description'] as String? ?? '',
      isChecked: data['isChecked'] as bool? ?? false,
      userId: userId,
      studyCycleId: _readString(data['studyCycleId']),
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  String get deadlineLabel => deadline.isEmpty ? 'Sem prazo' : deadline;

  AcademicTask copyWith({
    String? id,
    String? title,
    Object? disciplineId = _copyWithSentinel,
    String? subject,
    String? deadline,
    String? visualPriority,
    String? description,
    bool? isChecked,
    String? userId,
    Object? studyCycleId = _copyWithSentinel,
    Object? createdAt = _copyWithSentinel,
    Object? updatedAt = _copyWithSentinel,
  }) {
    return AcademicTask(
      id: id ?? this.id,
      title: title ?? this.title,
      disciplineId: identical(disciplineId, _copyWithSentinel)
          ? this.disciplineId
          : disciplineId as String?,
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      visualPriority: visualPriority ?? this.visualPriority,
      description: description ?? this.description,
      isChecked: isChecked ?? this.isChecked,
      userId: userId ?? this.userId,
      studyCycleId: identical(studyCycleId, _copyWithSentinel)
          ? this.studyCycleId
          : studyCycleId as String?,
      createdAt: identical(createdAt, _copyWithSentinel)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _copyWithSentinel)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class TaskInput {
  final String title;
  final String? disciplineId;
  final String subject;
  final String deadline;
  final String visualPriority;
  final String description;
  final String? studyCycleId;

  const TaskInput({
    required this.title,
    this.disciplineId,
    required this.subject,
    required this.deadline,
    required this.visualPriority,
    this.description = '',
    this.studyCycleId,
  });

  TaskInput copyWith({
    String? title,
    String? disciplineId,
    String? subject,
    String? deadline,
    String? visualPriority,
    String? description,
    String? studyCycleId,
  }) {
    return TaskInput(
      title: title ?? this.title,
      disciplineId: disciplineId ?? this.disciplineId,
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      visualPriority: visualPriority ?? this.visualPriority,
      description: description ?? this.description,
      studyCycleId: studyCycleId ?? this.studyCycleId,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      ...toUpdateMap(),
      'isChecked': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final normalizedStudyCycleId = AcademicTask._readString(studyCycleId);
    final normalizedDisciplineId = AcademicTask._readString(disciplineId);

    return {
      'studyCycleId': ?normalizedStudyCycleId,
      'disciplineId': ?normalizedDisciplineId,
      'title': title,
      'subject': subject,
      'deadline': deadline,
      'visualPriority': visualPriority,
      'description': description.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
