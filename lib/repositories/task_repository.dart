import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/academic_task.dart';
import 'user_profile_repository.dart';

class TaskRepositoryException implements Exception {
  final String message;

  const TaskRepositoryException(this.message);

  @override
  String toString() => message;
}

class TaskRepository {
  TaskRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    UserProfileRepository? userProfileRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _userProfileRepository =
           userProfileRepository ??
           UserProfileRepository(
             firestore: firestore,
             firebaseAuth: firebaseAuth,
           );

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final UserProfileRepository _userProfileRepository;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<AcademicTask>> watchTasks({String? studyCycleId}) {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);

    return _tasksCollection(uid).snapshots().map((snapshot) {
      final tasks = snapshot.docs
          .map((document) => AcademicTask.fromFirestore(document, uid))
          .where((task) {
            if (normalizedStudyCycleId == null) return true;

            return task.studyCycleId == null ||
                task.studyCycleId == normalizedStudyCycleId;
          })
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
    final taskInput = await _withActiveStudyCycle(input);

    await _guardFirestoreCall(() {
      return _tasksCollection(uid).add(taskInput.toCreateMap());
    });
  }

  Future<void> updateTask({required String id, required TaskInput input}) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _tasksCollection(uid).doc(id).update(input.toUpdateMap());
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

  Future<void> deleteTask(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _tasksCollection(uid).doc(id).delete();
    });
  }

  Future<void> backfillStudyCycleId(String studyCycleId) {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    if (normalizedStudyCycleId == null) return Future.value();

    return _guardFirestoreCall(() async {
      final snapshot = await _tasksCollection(uid).get();
      final batch = _firestore.batch();
      var hasWrites = false;

      for (final document in snapshot.docs) {
        final currentStudyCycleId = _normalizeString(
          document.data()['studyCycleId'],
        );
        if (currentStudyCycleId != null) continue;

        batch.update(document.reference, {
          'studyCycleId': normalizedStudyCycleId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        hasWrites = true;
      }

      if (hasWrites) {
        await batch.commit();
      }
    });
  }

  Future<TaskInput> _withActiveStudyCycle(TaskInput input) async {
    if (_normalizeString(input.studyCycleId) != null) return input;

    final activeStudyCycleId = await _resolveActiveStudyCycleId();
    if (activeStudyCycleId == null) return input;

    return input.copyWith(studyCycleId: activeStudyCycleId);
  }

  Future<String?> _resolveActiveStudyCycleId() async {
    try {
      return await _userProfileRepository.resolveActiveStudyCycleId();
    } on UserProfileRepositoryException catch (error) {
      throw TaskRepositoryException(error.message);
    }
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

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
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

  static String? _normalizeString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
