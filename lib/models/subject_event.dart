import 'package:cloud_firestore/cloud_firestore.dart';

enum SubjectEventType {
  exam('Prova'),
  lecture('Palestra'),
  seminar('Seminário'),
  deadline('Entrega'),
  extraClass('Aula extra'),
  other('Outro');

  final String label;

  const SubjectEventType(this.label);

  static SubjectEventType fromLabel(Object? value) {
    if (value is! String) return SubjectEventType.other;

    return SubjectEventType.values.firstWhere(
      (type) => type.label == value.trim(),
      orElse: () => SubjectEventType.other,
    );
  }
}

class SubjectEvent {
  final String id;
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final String title;
  final SubjectEventType type;
  final DateTime eventDate;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubjectEvent({
    required this.id,
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.title,
    required this.type,
    required this.eventDate,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return SubjectEvent.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory SubjectEvent.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return SubjectEvent(
      id: id,
      studyCycleId: _readString(data['studyCycleId']),
      disciplineId: _readString(data['disciplineId']),
      disciplineName: _readString(data['disciplineName']) ?? '',
      title: _readString(data['title']) ?? '',
      type: SubjectEventType.fromLabel(data['type']),
      eventDate: _readDate(data['eventDate']) ?? _dateOnly(DateTime.now()),
      description: _readString(data['description']) ?? '',
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
      'type': type.label,
      'eventDate': Timestamp.fromDate(eventDate),
      'description': description,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  String get displayDateLabel {
    final day = eventDate.day.toString().padLeft(2, '0');
    final month = eventDate.month.toString().padLeft(2, '0');

    return '$day/$month/${eventDate.year}';
  }

  bool get isUpcoming {
    final today = _dateOnly(DateTime.now());

    return !eventDate.isBefore(today);
  }

  static int compareByDate(SubjectEvent a, SubjectEvent b) {
    final dateComparison = a.eventDate.compareTo(b.eventDate);
    if (dateComparison != 0) return dateComparison;

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

class SubjectEventInput {
  final String? studyCycleId;
  final String? disciplineId;
  final String disciplineName;
  final String title;
  final SubjectEventType type;
  final DateTime eventDate;
  final String description;

  const SubjectEventInput({
    this.studyCycleId,
    this.disciplineId,
    required this.disciplineName,
    required this.title,
    required this.type,
    required this.eventDate,
    this.description = '',
  });

  Map<String, dynamic> toCreateMap() {
    return {...toUpdateMap(), 'createdAt': FieldValue.serverTimestamp()};
  }

  Map<String, dynamic> toUpdateMap() {
    final normalizedStudyCycleId = SubjectEvent._readString(studyCycleId);
    final normalizedDisciplineId = SubjectEvent._readString(disciplineId);
    final normalizedEventDate = SubjectEvent._dateOnly(eventDate);

    return {
      'studyCycleId': ?normalizedStudyCycleId,
      'disciplineId': ?normalizedDisciplineId,
      'disciplineName': disciplineName.trim(),
      'title': title.trim(),
      'type': type.label,
      'eventDate': Timestamp.fromDate(normalizedEventDate),
      'description': description.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
