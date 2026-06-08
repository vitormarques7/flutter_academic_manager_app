import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/schedule.dart';

class ScheduleRepositoryException implements Exception {
  final String message;

  const ScheduleRepositoryException(this.message);

  @override
  String toString() => message;
}

class ScheduleRepository {
  ScheduleRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _schedulesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('schedules');
  }

  Stream<List<Schedule>> watchSchedules() {
    final uid = _currentUserId;

    return _schedulesCollection(uid).snapshots().map((snapshot) {
      return _sortSchedules(snapshot.docs.map(Schedule.fromFirestore).toList());
    });
  }

  Future<List<Schedule>> fetchSchedules() async {
    final uid = _currentUserId;

    final snapshot = await _guardFirestoreCall(() {
      return _schedulesCollection(uid).get();
    });

    return _sortSchedules(snapshot.docs.map(Schedule.fromFirestore).toList());
  }

  Future<void> createSchedule(ScheduleInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _schedulesCollection(uid).add(input.toCreateMap());
    });
  }

  Future<void> updateSchedule({
    required String id,
    required ScheduleInput input,
  }) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _schedulesCollection(uid).doc(id).update(input.toUpdateMap());
    });
  }

  Future<void> deleteSchedule(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _schedulesCollection(uid).doc(id).delete();
    });
  }

  List<Schedule> _sortSchedules(List<Schedule> schedules) {
    schedules.sort(Schedule.compareByStartTime);
    return schedules;
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ScheduleRepositoryException(
        'Entre na sua conta para salvar horários.',
      );
    }

    return user.uid;
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ScheduleRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw ScheduleRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const ScheduleRepositoryException(
        'Não foi possível salvar o horário. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar horários. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos esse horário para atualizar.',
      _ => error.message ?? 'Não foi possível salvar o horário.',
    };
  }
}
