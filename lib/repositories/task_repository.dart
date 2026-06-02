import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/academic_task.dart';

class TaskRepositoryException implements Exception {
  final String message;

  const TaskRepositoryException(this.message);

  @override
  String toString() => message;
}

class TaskRepository {
  TaskRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<AcademicTask>> watchTasks() {
    final uid = _currentUserId;

    return _tasksCollection(uid).snapshots().map((snapshot) {
      final tasks = snapshot.docs
          .map((document) => AcademicTask.fromFirestore(document, uid))
          .toList();

      tasks.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      return tasks;
    });
  }

  Future<void> createTask(TaskInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _tasksCollection(uid).add({
        'title': input.title,
        'subject': input.subject,
        'deadline': input.deadline,
        'visualPriority': input.visualPriority,
        'isChecked': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateTask({required String id, required TaskInput input}) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _tasksCollection(uid).doc(id).update({
        'title': input.title,
        'subject': input.subject,
        'deadline': input.deadline,
        'visualPriority': input.visualPriority,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateCompletion({required String id, required bool isChecked}) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _tasksCollection(uid).doc(id).update({
        'isChecked': isChecked,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const TaskRepositoryException(
        'Entre na sua conta para salvar tarefas.',
      );
    }

    return user.uid;
  }

  Future<void> _guardFirestoreCall(Future<Object?> Function() action) async {
    try {
      await action();
    } on TaskRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw TaskRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const TaskRepositoryException(
        'Não foi possível salvar a tarefa. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar tarefas. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos essa tarefa para atualizar.',
      _ => error.message ?? 'Não foi possível salvar a tarefa.',
    };
  }
}
