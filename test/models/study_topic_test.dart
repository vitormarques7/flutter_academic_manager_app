import 'package:academic_manager_app/models/study_topic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudyTopicStatus', () {
    test('fromFirestore resolves known values and falls back to todo', () {
      expect(StudyTopicStatus.fromFirestore('seen'), StudyTopicStatus.seen);
      expect(StudyTopicStatus.fromFirestore('unknown'), StudyTopicStatus.todo);
      expect(StudyTopicStatus.fromFirestore(null), StudyTopicStatus.todo);
    });
  });

  group('StudyTopic', () {
    test('fromMap preserves valid fields', () {
      final seenAt = Timestamp.fromDate(DateTime(2026, 6, 19, 10));
      final topic = StudyTopic.fromMap(
        id: 'topic-1',
        data: {
          'studyCycleId': ' cycle-1 ',
          'disciplineId': ' discipline-1 ',
          'disciplineName': ' História ',
          'title': ' Brasil Império ',
          'status': 'seen',
          'position': 3,
          'seenAt': seenAt,
        },
      );

      expect(topic.id, 'topic-1');
      expect(topic.studyCycleId, 'cycle-1');
      expect(topic.disciplineId, 'discipline-1');
      expect(topic.disciplineName, 'História');
      expect(topic.title, 'Brasil Império');
      expect(topic.status, StudyTopicStatus.seen);
      expect(topic.position, 3);
      expect(topic.seenAt, seenAt.toDate());
      expect(topic.isSeen, isTrue);
    });

    test('compareByPosition orders by position, title, and id', () {
      final topics = [
        const StudyTopic(
          id: 'c',
          disciplineName: 'Mat',
          title: 'Trig',
          position: 2,
        ),
        const StudyTopic(
          id: 'b',
          disciplineName: 'Mat',
          title: 'Beta',
          position: 1,
        ),
        const StudyTopic(
          id: 'a',
          disciplineName: 'Mat',
          title: 'Alfa',
          position: 1,
        ),
      ]..sort(StudyTopic.compareByPosition);

      expect(topics.map((topic) => topic.id), ['a', 'b', 'c']);
    });
  });

  group('StudyTopicInput', () {
    test(
      'toCreateMap serializes todo topic without seenAt delete sentinel',
      () {
        const input = StudyTopicInput(
          studyCycleId: ' cycle-1 ',
          disciplineId: ' discipline-1 ',
          disciplineName: ' História ',
          title: ' Brasil Império ',
          position: 2,
        );

        final map = input.toCreateMap();

        expect(map['studyCycleId'], 'cycle-1');
        expect(map['disciplineId'], 'discipline-1');
        expect(map['disciplineName'], 'História');
        expect(map['title'], 'Brasil Império');
        expect(map['status'], 'todo');
        expect(map['position'], 2);
        expect(map.containsKey('seenAt'), isFalse);
        expect(map['createdAt'], isA<FieldValue>());
        expect(map['updatedAt'], isA<FieldValue>());
      },
    );

    test('toUpdateMap deletes seenAt when status returns to todo', () {
      const input = StudyTopicInput(
        disciplineName: 'História',
        title: 'Brasil Império',
      );

      final map = input.toUpdateMap();

      expect(map['seenAt'], isA<FieldValue>());
    });
  });
}
