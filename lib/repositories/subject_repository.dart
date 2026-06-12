import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/academic_subject.dart';

class SubjectRepositoryException implements Exception {
  final String message;

  const SubjectRepositoryException(this.message);

  @override
  String toString() => message;
}

class SubjectRepository {
  SubjectRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _subjectsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('subjects');
  }

  Stream<List<AcademicSubject>> watchSubjects() {
    final uid = _currentUserId;

    return _subjectsCollection(uid).snapshots().map((snapshot) {
      final subjects = snapshot.docs
          .map((document) => AcademicSubject.fromFirestore(document, uid))
          .toList();

      subjects.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      return subjects;
    });
  }

  Future<void> createSubject(SubjectInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _subjectsCollection(uid).add(input.toCreateMap());
    });
  }

  Future<void> createSubjects(List<SubjectInput> inputs) async {
    if (inputs.isEmpty) return;

    final uid = _currentUserId;

    await _guardFirestoreCall(() async {
      final batch = _firestore.batch();

      for (final input in inputs) {
        final document = _subjectsCollection(uid).doc();
        batch.set(document, input.toCreateMap());
      }

      await batch.commit();
    });
  }

  Future<void> deleteSubject(String id) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _subjectsCollection(uid).doc(id).delete();
    });
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const SubjectRepositoryException(
        'Entre na sua conta para salvar disciplinas.',
      );
    }

    return user.uid;
  }

  Future<void> _guardFirestoreCall(Future<Object?> Function() action) async {
    try {
      await action();
    } on SubjectRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw SubjectRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const SubjectRepositoryException(
        'Não foi possível salvar a disciplina. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar disciplinas. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos essa disciplina para excluir.',
      _ => error.message ?? 'Não foi possível salvar a disciplina.',
    };
  }
}
