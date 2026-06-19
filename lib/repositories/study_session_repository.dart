import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/study_session.dart';
import 'user_profile_repository.dart';

class StudySessionRepositoryException implements Exception {
  final String message;

  const StudySessionRepositoryException(this.message);

  @override
  String toString() => message;
}

class StudySessionRepository {
  StudySessionRepository({
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

  CollectionReference<Map<String, dynamic>> _sessionsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('studySessions');
  }

  Query<Map<String, dynamic>> _sessionsQuery(
    String uid, {
    String? studyCycleId,
  }) {
    Query<Map<String, dynamic>> query = _sessionsCollection(uid);
    final normalizedStudyCycleId = _normalizeString(studyCycleId);

    if (normalizedStudyCycleId != null) {
      query = query.where('studyCycleId', isEqualTo: normalizedStudyCycleId);
    }

    return query;
  }

  Stream<List<StudySession>> watchSessions({
    String? studyCycleId,
    String? disciplineId,
  }) {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    final normalizedDisciplineId = _normalizeString(disciplineId);

    return _sessionsQuery(uid, studyCycleId: studyCycleId).snapshots().map((
      snapshot,
    ) {
      final sessions = snapshot.docs.map(StudySession.fromFirestore).where((
        session,
      ) {
        final matchesStudyCycle =
            normalizedStudyCycleId == null ||
            session.studyCycleId == normalizedStudyCycleId;
        final matchesDiscipline =
            normalizedDisciplineId == null ||
            session.disciplineId == normalizedDisciplineId;

        return matchesStudyCycle && matchesDiscipline;
      }).toList();

      return _sortSessions(sessions);
    });
  }

  Future<List<StudySession>> fetchSessions({
    String? studyCycleId,
    String? disciplineId,
  }) async {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    final normalizedDisciplineId = _normalizeString(disciplineId);

    final snapshot = await _guardFirestoreCall(() {
      return _sessionsQuery(uid, studyCycleId: studyCycleId).get();
    });

    final sessions = snapshot.docs.map(StudySession.fromFirestore).where((
      session,
    ) {
      final matchesStudyCycle =
          normalizedStudyCycleId == null ||
          session.studyCycleId == normalizedStudyCycleId;
      final matchesDiscipline =
          normalizedDisciplineId == null ||
          session.disciplineId == normalizedDisciplineId;

      return matchesStudyCycle && matchesDiscipline;
    }).toList();

    return _sortSessions(sessions);
  }

  Future<void> createSession(StudySessionInput input) async {
    final uid = _currentUserId;
    final sessionInput = await _withActiveStudyCycle(input);

    await _guardFirestoreCall(() {
      return _sessionsCollection(uid).add(sessionInput.toCreateMap());
    });
  }

  Future<void> updateSession({
    required String id,
    required StudySessionInput input,
  }) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _sessionsCollection(uid).doc(id).update(input.toUpdateMap());
    });
  }

  Future<void> deleteSession(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _sessionsCollection(uid).doc(id).delete();
    });
  }

  List<StudySession> _sortSessions(List<StudySession> sessions) {
    sessions.sort(StudySession.compareByMostRecent);
    return sessions;
  }

  Future<StudySessionInput> _withActiveStudyCycle(
    StudySessionInput input,
  ) async {
    if (_normalizeString(input.studyCycleId) != null) return input;

    final activeStudyCycleId = await _resolveActiveStudyCycleId();
    if (activeStudyCycleId == null) return input;

    return input.copyWith(studyCycleId: activeStudyCycleId);
  }

  Future<String?> _resolveActiveStudyCycleId() async {
    try {
      return await _userProfileRepository.resolveActiveStudyCycleId();
    } on UserProfileRepositoryException catch (error) {
      throw StudySessionRepositoryException(error.message);
    }
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const StudySessionRepositoryException(
        'Entre na sua conta para salvar sessões de estudo.',
      );
    }

    return user.uid;
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on StudySessionRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw StudySessionRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const StudySessionRepositoryException(
        'Não foi possível salvar a sessão de estudo. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar sessões de estudo. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos essa sessão de estudo.',
      _ => error.message ?? 'Não foi possível salvar a sessão de estudo.',
    };
  }

  static String? _normalizeString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
