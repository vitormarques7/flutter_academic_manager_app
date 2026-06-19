import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final DateTime studiedAt;
  final int durationMinutes;
  final List<String> topicIds;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudySession({
    required this.id,
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.studiedAt,
    required this.durationMinutes,
    this.topicIds = const [],
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory StudySession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return StudySession.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory StudySession.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return StudySession(
      id: id,
      studyCycleId: _readString(data['studyCycleId']),
      disciplineId: _readString(data['disciplineId']),
      disciplineName: _readString(data['disciplineName']) ?? '',
      studiedAt: _readDate(data['studiedAt']) ?? _dateOnly(DateTime.now()),
      durationMinutes: _readPositiveInt(data['durationMinutes']),
      topicIds: _readStringList(data['topicIds']),
      notes: _readString(data['notes']) ?? '',
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (studyCycleId != null) 'studyCycleId': studyCycleId,
      if (disciplineId != null) 'disciplineId': disciplineId,
      'disciplineName': disciplineName,
      'studiedAt': Timestamp.fromDate(_dateOnly(studiedAt)),
      'durationMinutes': durationMinutes,
      'topicIds': topicIds,
      'notes': notes,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  String get durationLabel {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours == 0) return '${minutes}min';
    if (minutes == 0) return '${hours}h';

    return '${hours}h ${minutes}min';
  }

  String get studiedAtLabel {
    final day = studiedAt.day.toString().padLeft(2, '0');
    final month = studiedAt.month.toString().padLeft(2, '0');

    return '$day/$month/${studiedAt.year}';
  }

  static int compareByMostRecent(StudySession a, StudySession b) {
    final studiedAtComparison = b.studiedAt.compareTo(a.studiedAt);
    if (studiedAtComparison != 0) return studiedAtComparison;

    final createdAtComparison = _compareNullableDate(b.createdAt, a.createdAt);
    if (createdAtComparison != 0) return createdAtComparison;

    return a.id.compareTo(b.id);
  }

  static int totalMinutes(List<StudySession> sessions) {
    return sessions.fold(
      0,
      (total, session) => total + session.durationMinutes,
    );
  }

  static int _compareNullableDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return a.compareTo(b);
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! Iterable) return const [];

    final result = value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

    return List.unmodifiable(result);
  }

  static int _readPositiveInt(Object? value) {
    if (value is! int || value <= 0) return 0;
    return value;
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return _dateOnly(value.toDate());
    if (value is DateTime) return _dateOnly(value);

    return null;
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class StudySessionInput {
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final DateTime studiedAt;
  final int durationMinutes;
  final List<String> topicIds;
  final String notes;

  const StudySessionInput({
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.studiedAt,
    required this.durationMinutes,
    this.topicIds = const [],
    this.notes = '',
  });

  StudySessionInput copyWith({
    String? studyCycleId,
    String? disciplineId,
    String? disciplineName,
    DateTime? studiedAt,
    int? durationMinutes,
    List<String>? topicIds,
    String? notes,
  }) {
    return StudySessionInput(
      studyCycleId: studyCycleId ?? this.studyCycleId,
      disciplineId: disciplineId ?? this.disciplineId,
      disciplineName: disciplineName ?? this.disciplineName,
      studiedAt: studiedAt ?? this.studiedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      topicIds: topicIds ?? this.topicIds,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {...toUpdateMap(), 'createdAt': FieldValue.serverTimestamp()};
  }

  Map<String, dynamic> toUpdateMap() {
    final normalizedStudyCycleId = StudySession._readString(studyCycleId);
    final normalizedDisciplineId = StudySession._readString(disciplineId);

    return {
      'studyCycleId': ?normalizedStudyCycleId,
      'disciplineId': ?normalizedDisciplineId,
      'disciplineName': disciplineName.trim(),
      'studiedAt': Timestamp.fromDate(StudySession._dateOnly(studiedAt)),
      'durationMinutes': durationMinutes < 0 ? 0 : durationMinutes,
      'topicIds': StudySession._readStringList(topicIds),
      'notes': notes.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
