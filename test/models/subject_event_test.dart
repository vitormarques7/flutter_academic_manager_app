import 'package:academic_manager_app/models/subject_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubjectEventType', () {
    test('fromLabel resolves known labels and falls back to other', () {
      expect(SubjectEventType.fromLabel('Seminário'), SubjectEventType.seminar);
      expect(
        SubjectEventType.fromLabel('desconhecido'),
        SubjectEventType.other,
      );
      expect(SubjectEventType.fromLabel(null), SubjectEventType.other);
    });
  });

  group('SubjectEvent', () {
    test('fromMap preserves valid fields', () {
      final eventDate = Timestamp.fromDate(DateTime(2026, 6, 30, 14));
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 11, 8));
      final updatedAt = Timestamp.fromDate(DateTime(2026, 6, 11, 9));

      final event = SubjectEvent.fromMap(
        id: 'event-1',
        data: {
          'studyCycleId': ' cycle-1 ',
          'disciplineId': ' discipline-1 ',
          'disciplineName': 'Testes IV',
          'title': ' Prova final ',
          'type': 'Prova',
          'eventDate': eventDate,
          'description': ' Sala 203. ',
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );

      expect(event.id, 'event-1');
      expect(event.studyCycleId, 'cycle-1');
      expect(event.disciplineId, 'discipline-1');
      expect(event.disciplineName, 'Testes IV');
      expect(event.title, 'Prova final');
      expect(event.type, SubjectEventType.exam);
      expect(event.eventDate, DateTime(2026, 6, 30));
      expect(event.displayDateLabel, '30/06/2026');
      expect(event.description, 'Sala 203.');
      expect(event.createdAt, createdAt.toDate());
      expect(event.updatedAt, updatedAt.toDate());
    });

    test('fromMap applies predictable defaults for missing fields', () {
      final event = SubjectEvent.fromMap(id: 'event-1', data: const {});

      expect(event.studyCycleId, isNull);
      expect(event.disciplineId, isNull);
      expect(event.disciplineName, isEmpty);
      expect(event.title, isEmpty);
      expect(event.type, SubjectEventType.other);
      expect(event.description, isEmpty);
      expect(event.createdAt, isNull);
      expect(event.updatedAt, isNull);
    });

    test('toFirestore can be reconstructed without semantic loss', () {
      final original = SubjectEvent(
        id: 'event-1',
        studyCycleId: 'cycle-1',
        disciplineId: 'discipline-1',
        disciplineName: 'Arquitetura',
        title: 'Palestra convidada',
        type: SubjectEventType.lecture,
        eventDate: DateTime(2026, 7, 2),
        description: 'Auditório principal.',
        createdAt: DateTime(2026, 6, 11, 8),
        updatedAt: DateTime(2026, 6, 11, 9),
      );

      final reconstructed = SubjectEvent.fromMap(
        id: original.id,
        data: original.toFirestore(),
      );

      expect(reconstructed.id, original.id);
      expect(reconstructed.studyCycleId, original.studyCycleId);
      expect(reconstructed.disciplineId, original.disciplineId);
      expect(reconstructed.disciplineName, original.disciplineName);
      expect(reconstructed.title, original.title);
      expect(reconstructed.type, original.type);
      expect(reconstructed.eventDate, original.eventDate);
      expect(reconstructed.description, original.description);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.updatedAt, original.updatedAt);
    });

    test('compareByDate sorts by date, title, and id', () {
      final events = [
        SubjectEvent(
          id: 'b',
          disciplineName: 'Testes',
          title: 'Workshop',
          type: SubjectEventType.other,
          eventDate: DateTime(2026, 7, 2),
          description: '',
        ),
        SubjectEvent(
          id: 'a',
          disciplineName: 'Testes',
          title: 'Prova',
          type: SubjectEventType.exam,
          eventDate: DateTime(2026, 7),
          description: '',
        ),
      ]..sort(SubjectEvent.compareByDate);

      expect(events.map((event) => event.id), ['a', 'b']);
    });
  });

  group('SubjectEventInput', () {
    final input = SubjectEventInput(
      studyCycleId: ' cycle-1 ',
      disciplineId: ' discipline-1 ',
      disciplineName: ' Testes IV ',
      title: ' Prova final ',
      type: SubjectEventType.exam,
      eventDate: DateTime(2026, 6, 30, 14),
      description: ' Sala 203. ',
    );

    test('toCreateMap serializes fields for a new event', () {
      final map = input.toCreateMap();

      expect(map['studyCycleId'], 'cycle-1');
      expect(map['disciplineId'], 'discipline-1');
      expect(map['disciplineName'], 'Testes IV');
      expect(map['title'], 'Prova final');
      expect(map['type'], 'Prova');
      expect((map['eventDate'] as Timestamp).toDate(), DateTime(2026, 6, 30));
      expect(map['description'], 'Sala 203.');
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('toUpdateMap serializes editable fields only', () {
      final map = input.toUpdateMap();

      expect(map['studyCycleId'], 'cycle-1');
      expect(map['disciplineId'], 'discipline-1');
      expect(map['disciplineName'], 'Testes IV');
      expect(map['title'], 'Prova final');
      expect(map['type'], 'Prova');
      expect((map['eventDate'] as Timestamp).toDate(), DateTime(2026, 6, 30));
      expect(map['description'], 'Sala 203.');
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map.containsKey('createdAt'), isFalse);
    });
  });
}
