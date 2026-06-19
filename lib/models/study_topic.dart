import 'package:cloud_firestore/cloud_firestore.dart';

enum StudyTopicStatus {
  todo('todo'),
  seen('seen');

  final String firestoreValue;

  const StudyTopicStatus(this.firestoreValue);

  static StudyTopicStatus fromFirestore(Object? value) {
    if (value is! String) return StudyTopicStatus.todo;

    return StudyTopicStatus.values.firstWhere(
      (status) => status.firestoreValue == value.trim(),
      orElse: () => StudyTopicStatus.todo,
    );
  }
}

class StudyTopic {
  final String id;
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final String title;
  final StudyTopicStatus status;
  final int position;
  final DateTime? seenAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudyTopic({
    required this.id,
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.title,
    this.status = StudyTopicStatus.todo,
    this.position = 0,
    this.seenAt,
    this.createdAt,
    this.updatedAt,
  });

  factory StudyTopic.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return StudyTopic.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory StudyTopic.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return StudyTopic(
      id: id,
      studyCycleId: _readString(data['studyCycleId']),
      disciplineId: _readString(data['disciplineId']),
      disciplineName: _readString(data['disciplineName']) ?? '',
      title: _readString(data['title']) ?? '',
      status: StudyTopicStatus.fromFirestore(data['status']),
      position: _readNonNegativeInt(data['position']),
      seenAt: _readTimestamp(data['seenAt']),
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
      'status': status.firestoreValue,
      'position': position,
      if (seenAt != null) 'seenAt': Timestamp.fromDate(seenAt!),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  bool get isSeen => status == StudyTopicStatus.seen;

  static int compareByPosition(StudyTopic a, StudyTopic b) {
    final positionComparison = a.position.compareTo(b.position);
    if (positionComparison != 0) return positionComparison;

    final titleComparison = a.title.toLowerCase().compareTo(
      b.title.toLowerCase(),
    );
    if (titleComparison != 0) return titleComparison;

    return a.id.compareTo(b.id);
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int _readNonNegativeInt(Object? value) {
    if (value is! int || value < 0) return 0;
    return value;
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

class StudyTopicInput {
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final String title;
  final StudyTopicStatus status;
  final int position;
  final DateTime? seenAt;

  const StudyTopicInput({
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.title,
    this.status = StudyTopicStatus.todo,
    this.position = 0,
    this.seenAt,
  });

  StudyTopicInput copyWith({
    String? studyCycleId,
    String? disciplineId,
    String? disciplineName,
    String? title,
    StudyTopicStatus? status,
    int? position,
    DateTime? seenAt,
  }) {
    return StudyTopicInput(
      studyCycleId: studyCycleId ?? this.studyCycleId,
      disciplineId: disciplineId ?? this.disciplineId,
      disciplineName: disciplineName ?? this.disciplineName,
      title: title ?? this.title,
      status: status ?? this.status,
      position: position ?? this.position,
      seenAt: seenAt ?? this.seenAt,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      ..._baseMap(includeSeenAtDeleteSentinel: false),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return _baseMap(includeSeenAtDeleteSentinel: true);
  }

  Map<String, dynamic> _baseMap({required bool includeSeenAtDeleteSentinel}) {
    final normalizedStudyCycleId = StudyTopic._readString(studyCycleId);
    final normalizedDisciplineId = StudyTopic._readString(disciplineId);
    final normalizedSeenAt = status == StudyTopicStatus.seen && seenAt != null;

    return {
      'studyCycleId': ?normalizedStudyCycleId,
      'disciplineId': ?normalizedDisciplineId,
      'disciplineName': disciplineName.trim(),
      'title': title.trim(),
      'status': status.firestoreValue,
      'position': position < 0 ? 0 : position,
      if (normalizedSeenAt)
        'seenAt': Timestamp.fromDate(seenAt!)
      else if (includeSeenAtDeleteSentinel)
        'seenAt': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
