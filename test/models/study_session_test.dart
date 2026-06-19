import 'package:academic_manager_app/models/study_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudySession', () {
    test('fromMap preserves valid fields', () {
      final studiedAt = Timestamp.fromDate(DateTime(2026, 6, 19, 14));
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 19, 15));

      final session = StudySession.fromMap(
        id: 'session-1',
        data: {
          'studyCycleId': ' cycle-1 ',
          'disciplineId': ' discipline-1 ',
          'disciplineName': ' Matemática ',
          'studiedAt': studiedAt,
          'durationMinutes': 95,
          'topicIds': [' topic-1 ', 'topic-2', 'topic-1'],
          'notes': ' Álgebra. ',
          'createdAt': createdAt,
        },
      );

      expect(session.id, 'session-1');
      expect(session.studyCycleId, 'cycle-1');
      expect(session.disciplineId, 'discipline-1');
      expect(session.disciplineName, 'Matemática');
      expect(session.studiedAt, DateTime(2026, 6, 19));
      expect(session.durationMinutes, 95);
      expect(session.topicIds, ['topic-1', 'topic-2']);
      expect(session.notes, 'Álgebra.');
      expect(session.createdAt, createdAt.toDate());
      expect(session.durationLabel, '1h 35min');
    });

    test('fromMap applies safe defaults', () {
      final session = StudySession.fromMap(id: 'session-1', data: const {});

      expect(session.studyCycleId, isNull);
      expect(session.disciplineId, isNull);
      expect(session.disciplineName, isEmpty);
      expect(session.durationMinutes, 0);
      expect(session.topicIds, isEmpty);
      expect(session.notes, isEmpty);
    });

    test('totalMinutes sums session durations', () {
      final sessions = [
        StudySession(
          id: 'a',
          disciplineName: 'Matemática',
          studiedAt: DateTime(2026, 6, 19),
          durationMinutes: 30,
        ),
        StudySession(
          id: 'b',
          disciplineName: 'Português',
          studiedAt: DateTime(2026, 6, 19),
          durationMinutes: 45,
        ),
      ];

      expect(StudySession.totalMinutes(sessions), 75);
    });
  });

  group('StudySessionInput', () {
    test('toCreateMap serializes normalized fields', () {
      final input = StudySessionInput(
        studyCycleId: ' cycle-1 ',
        disciplineId: ' discipline-1 ',
        disciplineName: ' Matemática ',
        studiedAt: DateTime(2026, 6, 19, 22),
        durationMinutes: 70,
        topicIds: const [' topic-1 ', 'topic-2'],
        notes: ' Funções. ',
      );

      final map = input.toCreateMap();

      expect(map['studyCycleId'], 'cycle-1');
      expect(map['disciplineId'], 'discipline-1');
      expect(map['disciplineName'], 'Matemática');
      expect((map['studiedAt'] as Timestamp).toDate(), DateTime(2026, 6, 19));
      expect(map['durationMinutes'], 70);
      expect(map['topicIds'], ['topic-1', 'topic-2']);
      expect(map['notes'], 'Funções.');
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });
  });
}
