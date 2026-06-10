import 'package:academic_manager_app/models/academic_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AcademicTask', () {
    test('fromMap preserves the main fields', () {
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 3, 10));
      final updatedAt = Timestamp.fromDate(DateTime(2026, 6, 3, 11));

      final task = AcademicTask.fromMap(
        id: 'task-1',
        userId: 'user-1',
        data: {
          'title': 'Seminario de Java',
          'subject': 'Programacao',
          'deadline': '26/06/2026',
          'visualPriority': 'Trabalho',
          'description': 'Preparar slides e roteiro.',
          'isChecked': true,
          'studyCycleId': ' cycle-1 ',
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );

      expect(task.id, 'task-1');
      expect(task.userId, 'user-1');
      expect(task.title, 'Seminario de Java');
      expect(task.subject, 'Programacao');
      expect(task.deadline, '26/06/2026');
      expect(task.visualPriority, 'Trabalho');
      expect(task.description, 'Preparar slides e roteiro.');
      expect(task.isChecked, isTrue);
      expect(task.studyCycleId, 'cycle-1');
      expect(task.createdAt, createdAt.toDate());
      expect(task.updatedAt, updatedAt.toDate());
    });

    test('fromMap applies safe defaults for missing fields', () {
      final task = AcademicTask.fromMap(
        id: 'task-1',
        userId: 'user-1',
        data: const {},
      );

      expect(task.title, isEmpty);
      expect(task.subject, isEmpty);
      expect(task.deadline, isEmpty);
      expect(task.deadlineLabel, 'Sem prazo');
      expect(task.visualPriority, 'Trabalho');
      expect(task.description, isEmpty);
      expect(task.isChecked, isFalse);
      expect(task.studyCycleId, isNull);
      expect(task.createdAt, isNull);
      expect(task.updatedAt, isNull);
    });
  });

  group('TaskInput', () {
    const input = TaskInput(
      title: 'Lista de exercicios',
      subject: 'Calculo I',
      deadline: '10/06/2026',
      visualPriority: 'Prova',
      description: 'Resolver a lista antes da aula.',
      studyCycleId: 'cycle-1',
    );

    test('toCreateMap serializes fields for a new task', () {
      final map = input.toCreateMap();

      expect(map['title'], input.title);
      expect(map['subject'], input.subject);
      expect(map['deadline'], input.deadline);
      expect(map['visualPriority'], input.visualPriority);
      expect(map['description'], input.description);
      expect(map['studyCycleId'], input.studyCycleId);
      expect(map['isChecked'], isFalse);
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('toUpdateMap serializes editable fields only', () {
      final map = input.toUpdateMap();

      expect(map['title'], input.title);
      expect(map['subject'], input.subject);
      expect(map['deadline'], input.deadline);
      expect(map['visualPriority'], input.visualPriority);
      expect(map['description'], input.description);
      expect(map['studyCycleId'], input.studyCycleId);
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map.containsKey('isChecked'), isFalse);
      expect(map.containsKey('createdAt'), isFalse);
    });

    test('toUpdateMap keeps studyCycleId absent when it is not provided', () {
      const input = TaskInput(
        title: 'Lista de exercicios',
        subject: 'Calculo I',
        deadline: '10/06/2026',
        visualPriority: 'Prova',
      );

      final map = input.toUpdateMap();

      expect(map.containsKey('studyCycleId'), isFalse);
    });
  });
}
