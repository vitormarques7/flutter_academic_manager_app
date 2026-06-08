import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicTask {
  final String id;
  final String title;
  final String subject;
  final String deadline;
  final String visualPriority;
  final bool isChecked;
  final String userId;
  final String? studyCycleId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AcademicTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.deadline,
    required this.visualPriority,
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
      subject: data['subject'] as String? ?? '',
      deadline: data['deadline'] as String? ?? '',
      visualPriority: data['visualPriority'] as String? ?? 'Trabalho',
      isChecked: data['isChecked'] as bool? ?? false,
      userId: userId,
      studyCycleId: _readString(data['studyCycleId']),
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  String get deadlineLabel => deadline.isEmpty ? 'Sem prazo' : deadline;

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
  final String subject;
  final String deadline;
  final String visualPriority;
  final String? studyCycleId;

  const TaskInput({
    required this.title,
    required this.subject,
    required this.deadline,
    required this.visualPriority,
    this.studyCycleId,
  });

  TaskInput copyWith({
    String? title,
    String? subject,
    String? deadline,
    String? visualPriority,
    String? studyCycleId,
  }) {
    return TaskInput(
      title: title ?? this.title,
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      visualPriority: visualPriority ?? this.visualPriority,
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

    return {
      'studyCycleId': ?normalizedStudyCycleId,
      'title': title,
      'subject': subject,
      'deadline': deadline,
      'visualPriority': visualPriority,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
