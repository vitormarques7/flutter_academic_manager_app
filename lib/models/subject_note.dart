import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectNote {
  final String id;
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubjectNote({
    required this.id,
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectNote.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return SubjectNote.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory SubjectNote.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return SubjectNote(
      id: id,
      studyCycleId: _readString(data['studyCycleId']),
      disciplineId: _readString(data['disciplineId']),
      disciplineName: _readString(data['disciplineName']) ?? '',
      title: _readString(data['title']) ?? '',
      content: _readString(data['content']) ?? '',
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
      'content': content,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static int compareByMostRecent(SubjectNote a, SubjectNote b) {
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

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

class SubjectNoteInput {
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final String title;
  final String content;

  const SubjectNoteInput({
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toCreateMap() {
    return {...toUpdateMap(), 'createdAt': FieldValue.serverTimestamp()};
  }

  Map<String, dynamic> toUpdateMap() {
    final normalizedStudyCycleId = SubjectNote._readString(studyCycleId);
    final normalizedDisciplineId = SubjectNote._readString(disciplineId);

    return {
      'studyCycleId': ?normalizedStudyCycleId,
      'disciplineId': ?normalizedDisciplineId,
      'disciplineName': disciplineName.trim(),
      'title': title.trim(),
      'content': content.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
