import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subject_note.dart';

class SubjectNoteRepositoryException implements Exception {
  final String message;

  const SubjectNoteRepositoryException(this.message);

  @override
  String toString() => message;
}

class SubjectNoteRepository {
  SubjectNoteRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _notesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('subjectNotes');
  }

  Query<Map<String, dynamic>> _notesQuery(
    String uid, {
    String? studyCycleId,
    String? disciplineId,
  }) {
    Query<Map<String, dynamic>> query = _notesCollection(uid);
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

  Stream<List<SubjectNote>> watchNotes({
    String? studyCycleId,
    String? disciplineId,
  }) {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    final normalizedDisciplineId = _normalizeString(disciplineId);

    return _notesQuery(
      uid,
      studyCycleId: studyCycleId,
      disciplineId: disciplineId,
    ).snapshots().map((snapshot) {
      final notes = snapshot.docs.map(SubjectNote.fromFirestore).where((note) {
        final matchesStudyCycle =
            normalizedStudyCycleId == null ||
            note.studyCycleId == normalizedStudyCycleId;
        final matchesDiscipline =
            normalizedDisciplineId == null ||
            note.disciplineId == normalizedDisciplineId;

        return matchesStudyCycle && matchesDiscipline;
      }).toList();

      return _sortNotes(notes);
    });
  }

  Future<void> createNote(SubjectNoteInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _notesCollection(uid).add(input.toCreateMap());
    });
  }

  Future<void> deleteNote(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _notesCollection(uid).doc(id).delete();
    });
  }

  Future<void> updateNote({required String id, required SubjectNoteInput input}) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _notesCollection(uid).doc(id).update(input.toUpdateMap());
    });
  }


  List<SubjectNote> _sortNotes(List<SubjectNote> notes) {
    notes.sort(SubjectNote.compareByMostRecent);
    return notes;
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const SubjectNoteRepositoryException(
        'Entre na sua conta para salvar anotações.',
      );
    }

    return user.uid;
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SubjectNoteRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw SubjectNoteRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const SubjectNoteRepositoryException(
        'Não foi possível salvar a anotação. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar anotações. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos essa anotação.',
      _ => error.message ?? 'Não foi possível salvar a anotação.',
    };
  }

  static String? _normalizeString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
