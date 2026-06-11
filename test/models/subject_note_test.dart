import 'package:academic_manager_app/models/subject_note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubjectNote', () {
    test('fromMap preserves valid fields', () {
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 11, 8));
      final updatedAt = Timestamp.fromDate(DateTime(2026, 6, 11, 9));

      final note = SubjectNote.fromMap(
        id: 'note-1',
        data: {
          'studyCycleId': ' cycle-1 ',
          'disciplineId': ' discipline-1 ',
          'disciplineName': 'Testes IV',
          'title': ' Dúvidas da aula ',
          'content': ' Revisar mocks e fixtures. ',
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );

      expect(note.id, 'note-1');
      expect(note.studyCycleId, 'cycle-1');
      expect(note.disciplineId, 'discipline-1');
      expect(note.disciplineName, 'Testes IV');
      expect(note.title, 'Dúvidas da aula');
      expect(note.content, 'Revisar mocks e fixtures.');
      expect(note.createdAt, createdAt.toDate());
      expect(note.updatedAt, updatedAt.toDate());
    });

    test('fromMap applies predictable defaults for missing fields', () {
      final note = SubjectNote.fromMap(id: 'note-1', data: const {});

      expect(note.studyCycleId, isNull);
      expect(note.disciplineId, isNull);
      expect(note.disciplineName, isEmpty);
      expect(note.title, isEmpty);
      expect(note.content, isEmpty);
      expect(note.createdAt, isNull);
      expect(note.updatedAt, isNull);
    });

    test('toFirestore can be reconstructed without semantic loss', () {
      final original = SubjectNote(
        id: 'note-1',
        studyCycleId: 'cycle-1',
        disciplineId: 'discipline-1',
        disciplineName: 'Testes IV',
        title: 'Resumo',
        content: 'Anotar critérios de cobertura.',
        createdAt: DateTime(2026, 6, 11, 8),
        updatedAt: DateTime(2026, 6, 11, 9),
      );

      final reconstructed = SubjectNote.fromMap(
        id: original.id,
        data: original.toFirestore(),
      );

      expect(reconstructed.id, original.id);
      expect(reconstructed.studyCycleId, original.studyCycleId);
      expect(reconstructed.disciplineId, original.disciplineId);
      expect(reconstructed.disciplineName, original.disciplineName);
      expect(reconstructed.title, original.title);
      expect(reconstructed.content, original.content);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.updatedAt, original.updatedAt);
    });
  });

  group('SubjectNoteInput', () {
    const input = SubjectNoteInput(
      studyCycleId: ' cycle-1 ',
      disciplineId: ' discipline-1 ',
      disciplineName: ' Testes IV ',
      title: ' Resumo ',
      content: ' Revisar mocks. ',
    );

    test('toCreateMap serializes fields for a new note', () {
      final map = input.toCreateMap();

      expect(map['studyCycleId'], 'cycle-1');
      expect(map['disciplineId'], 'discipline-1');
      expect(map['disciplineName'], 'Testes IV');
      expect(map['title'], 'Resumo');
      expect(map['content'], 'Revisar mocks.');
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('toUpdateMap serializes editable fields only', () {
      final map = input.toUpdateMap();

      expect(map['studyCycleId'], 'cycle-1');
      expect(map['disciplineId'], 'discipline-1');
      expect(map['disciplineName'], 'Testes IV');
      expect(map['title'], 'Resumo');
      expect(map['content'], 'Revisar mocks.');
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map.containsKey('createdAt'), isFalse);
    });
  });
}
