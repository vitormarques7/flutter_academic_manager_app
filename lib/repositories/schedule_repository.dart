import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/schedule.dart';
import 'user_profile_repository.dart';

class ScheduleRepositoryException implements Exception {
  final String message;

  const ScheduleRepositoryException(this.message);

  @override
  String toString() => message;
}

class ScheduleRepository {
  ScheduleRepository({
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

  CollectionReference<Map<String, dynamic>> _schedulesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('schedules');
  }

  Query<Map<String, dynamic>> _schedulesQuery(
    String uid, {
    String? studyCycleId,
  }) {
    final collection = _schedulesCollection(uid);
    final normalizedStudyCycleId = _normalizeString(studyCycleId);

    if (normalizedStudyCycleId == null) return collection;

    return collection.where('studyCycleId', isEqualTo: normalizedStudyCycleId);
  }

  Stream<List<Schedule>> watchSchedules({String? studyCycleId}) {
    final uid = _currentUserId;

    return _schedulesQuery(uid, studyCycleId: studyCycleId).snapshots().map((
      snapshot,
    ) {
      return _sortSchedules(snapshot.docs.map(Schedule.fromFirestore).toList());
    });
  }

  Future<List<Schedule>> fetchSchedules({String? studyCycleId}) async {
    final uid = _currentUserId;

    final snapshot = await _guardFirestoreCall(() {
      return _schedulesQuery(uid, studyCycleId: studyCycleId).get();
    });

    return _sortSchedules(snapshot.docs.map(Schedule.fromFirestore).toList());
  }

  Future<void> createSchedule(ScheduleInput input) async {
    final uid = _currentUserId;
    final scheduleInput = await _withActiveStudyCycle(input);

    await _guardFirestoreCall(() {
      return _schedulesCollection(uid).add(scheduleInput.toCreateMap());
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

  Future<void> backfillStudyCycleId(String studyCycleId) {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    if (normalizedStudyCycleId == null) return Future.value();

    return _guardFirestoreCall(() async {
      final snapshot = await _schedulesCollection(uid).get();
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

  Future<ScheduleInput> _withActiveStudyCycle(ScheduleInput input) async {
    if (_normalizeString(input.studyCycleId) != null) return input;

    final activeStudyCycleId = await _resolveActiveStudyCycleId();
    if (activeStudyCycleId == null) return input;

    return input.copyWith(studyCycleId: activeStudyCycleId);
  }

  Future<String?> _resolveActiveStudyCycleId() async {
    try {
      return await _userProfileRepository.resolveActiveStudyCycleId();
    } on UserProfileRepositoryException catch (error) {
      throw ScheduleRepositoryException(error.message);
    }
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

  static String? _normalizeString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
