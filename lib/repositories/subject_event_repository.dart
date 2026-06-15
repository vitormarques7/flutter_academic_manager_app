import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subject_event.dart';

class SubjectEventRepositoryException implements Exception {
  final String message;

  const SubjectEventRepositoryException(this.message);

  @override
  String toString() => message;
}

class SubjectEventRepository {
  SubjectEventRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _eventsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('subjectEvents');
  }

  Query<Map<String, dynamic>> _eventsQuery(
    String uid, {
    String? studyCycleId,
    String? disciplineId,
  }) {
    Query<Map<String, dynamic>> query = _eventsCollection(uid);
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    final normalizedDisciplineId = _normalizeString(disciplineId);

    if (normalizedStudyCycleId != null) {
      return query.where('studyCycleId', isEqualTo: normalizedStudyCycleId);
    }

    if (normalizedDisciplineId != null) {
      return query.where('disciplineId', isEqualTo: normalizedDisciplineId);
    }

    return query;
  }

  Stream<List<SubjectEvent>> watchEvents({
    String? studyCycleId,
    String? disciplineId,
    bool upcomingOnly = false,
  }) {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    final normalizedDisciplineId = _normalizeString(disciplineId);

    return _eventsQuery(
      uid,
      studyCycleId: studyCycleId,
      disciplineId: disciplineId,
    ).snapshots().map((snapshot) {
      var events = snapshot.docs.map(SubjectEvent.fromFirestore).where((event) {
        final matchesStudyCycle =
            normalizedStudyCycleId == null ||
            event.studyCycleId == normalizedStudyCycleId;
        final matchesDiscipline =
            normalizedDisciplineId == null ||
            event.disciplineId == normalizedDisciplineId;

        return matchesStudyCycle && matchesDiscipline;
      }).toList();

      if (upcomingOnly) {
        events = events.where((event) => event.isUpcoming).toList();
      }

      return _sortEvents(events);
    });
  }

  Future<void> createEvent(SubjectEventInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _eventsCollection(uid).add(input.toCreateMap());
    });
  }

  Future<void> deleteEvent(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _eventsCollection(uid).doc(id).delete();
    });
  }

  Future<void> updateEvent({required String id, required SubjectEventInput input}) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _eventsCollection(uid).doc(id).update(input.toUpdateMap());
    });
  }


  List<SubjectEvent> _sortEvents(List<SubjectEvent> events) {
    events.sort(SubjectEvent.compareByDate);
    return events;
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const SubjectEventRepositoryException(
        'Entre na sua conta para salvar eventos.',
      );
    }

    return user.uid;
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SubjectEventRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw SubjectEventRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const SubjectEventRepositoryException(
        'Não foi possível salvar o evento. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar eventos. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos esse evento.',
      _ => error.message ?? 'Não foi possível salvar o evento.',
    };
  }

  static String? _normalizeString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
