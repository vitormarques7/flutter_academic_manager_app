import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  static const int defaultColorValue = 0xFF514EB6;
  static const int minTimeMinutes = 0;
  static const int maxTimeMinutes = 1439;
  static const int firstWeekdayIndex = 0;
  static const int lastWeekdayIndex = 6;

  final String id;
  final String? studyCycleId;
  final String disciplineName;
  final List<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;
  final int colorValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Schedule({
    required this.id,
    this.studyCycleId,
    required this.disciplineName,
    required this.weekdays,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
    required this.colorValue,
    this.createdAt,
    this.updatedAt,
  });

  factory Schedule.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return Schedule.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory Schedule.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return Schedule(
      id: id,
      studyCycleId: _readString(data['studyCycleId']),
      disciplineName: data['disciplineName'] as String? ?? '',
      weekdays: _normalizeWeekdays(data['weekdays']),
      startTimeMinutes: _normalizeTimeMinutes(data['startTimeMinutes']),
      endTimeMinutes: _normalizeTimeMinutes(data['endTimeMinutes']),
      colorValue: data['colorValue'] as int? ?? defaultColorValue,
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (studyCycleId != null) 'studyCycleId': studyCycleId,
      'disciplineName': disciplineName,
      'weekdays': weekdays,
      'startTimeMinutes': startTimeMinutes,
      'endTimeMinutes': endTimeMinutes,
      'colorValue': colorValue,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  bool occursOnWeekday(int weekdayIndex) {
    return weekdays.contains(weekdayIndex);
  }

  String get formattedStartTime => formatMinutes(startTimeMinutes);

  String get formattedEndTime => formatMinutes(endTimeMinutes);

  String get formattedTimeRange => '$formattedStartTime - $formattedEndTime';

  static String formatMinutes(int minutes) {
    final normalizedMinutes = _normalizeTimeMinutes(minutes);
    final hour = normalizedMinutes ~/ 60;
    final minute = normalizedMinutes % 60;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  static int compareByStartTime(Schedule a, Schedule b) {
    final startComparison = a.startTimeMinutes.compareTo(b.startTimeMinutes);
    if (startComparison != 0) return startComparison;

    final endComparison = a.endTimeMinutes.compareTo(b.endTimeMinutes);
    if (endComparison != 0) return endComparison;

    final nameComparison = a.disciplineName.compareTo(b.disciplineName);
    if (nameComparison != 0) return nameComparison;

    return a.id.compareTo(b.id);
  }

  static List<int> _normalizeWeekdays(Object? value) {
    if (value is! Iterable) return const [];

    final weekdays = value
        .whereType<int>()
        .where((weekday) {
          return weekday >= firstWeekdayIndex && weekday <= lastWeekdayIndex;
        })
        .toSet()
        .toList();

    weekdays.sort();
    return List.unmodifiable(weekdays);
  }

  static int _normalizeTimeMinutes(Object? value) {
    if (value is! int) return minTimeMinutes;

    if (value < minTimeMinutes || value > maxTimeMinutes) {
      return minTimeMinutes;
    }

    return value;
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

class ScheduleInput {
  final String? studyCycleId;
  final String disciplineName;
  final List<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;
  final int colorValue;

  const ScheduleInput({
    this.studyCycleId,
    required this.disciplineName,
    required this.weekdays,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
    required this.colorValue,
  });

  ScheduleInput copyWith({
    String? studyCycleId,
    String? disciplineName,
    List<int>? weekdays,
    int? startTimeMinutes,
    int? endTimeMinutes,
    int? colorValue,
  }) {
    return ScheduleInput(
      studyCycleId: studyCycleId ?? this.studyCycleId,
      disciplineName: disciplineName ?? this.disciplineName,
      weekdays: weekdays ?? this.weekdays,
      startTimeMinutes: startTimeMinutes ?? this.startTimeMinutes,
      endTimeMinutes: endTimeMinutes ?? this.endTimeMinutes,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {...toUpdateMap(), 'createdAt': FieldValue.serverTimestamp()};
  }

  Map<String, dynamic> toUpdateMap() {
    final normalizedStudyCycleId = Schedule._readString(studyCycleId);

    return {
      'studyCycleId': ?normalizedStudyCycleId,
      'disciplineName': disciplineName,
      'weekdays': Schedule._normalizeWeekdays(weekdays),
      'startTimeMinutes': Schedule._normalizeTimeMinutes(startTimeMinutes),
      'endTimeMinutes': Schedule._normalizeTimeMinutes(endTimeMinutes),
      'colorValue': colorValue,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
