import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/academic_subject.dart';
import 'user_profile_repository.dart';

class SubjectRepositoryException implements Exception {
  final String message;

  const SubjectRepositoryException(this.message);

  @override
  String toString() => message;
}

class SubjectRepository {
  SubjectRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    UserProfileRepository? userProfileRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _userProfileRepository =
           userProfileRepository ?? UserProfileRepository();

  static const _subjectsField = 'subjects';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final UserProfileRepository _userProfileRepository;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Stream<List<AcademicSubject>> watchSubjects() {
    final uid = _currentUserId;

    return _userDoc(uid).snapshots().map((snapshot) {
      final subjects = _parseSubjects(snapshot, uid);
      _sortSubjects(subjects);
      return subjects;
    });
  }

  Future<void> createSubject(SubjectInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() async {
      await _userProfileRepository.ensureUserDocument(uid);

      final docRef = _userDoc(uid);
      final subjectId = docRef.collection('_ids').doc().id;

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final subjects = _readSubjectsMap(snapshot.data());

        subjects[subjectId] = input.toCreateMap();
        transaction.set(
          docRef,
          {_subjectsField: subjects},
          SetOptions(merge: true),
        );
      });
    });
  }

  Future<void> createSubjects(List<SubjectInput> inputs) async {
    if (inputs.isEmpty) return;

    final uid = _currentUserId;

    await _guardFirestoreCall(() async {
      await _userProfileRepository.ensureUserDocument(uid);

      final docRef = _userDoc(uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final subjects = _readSubjectsMap(snapshot.data());

        for (final input in inputs) {
          final subjectId = docRef.collection('_ids').doc().id;
          subjects[subjectId] = input.toCreateMap();
        }

        transaction.set(
          docRef,
          {_subjectsField: subjects},
          SetOptions(merge: true),
        );
      });
    });
  }

  Future<void> deleteSubject(String id) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() async {
      final docRef = _userDoc(uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final subjects = _readSubjectsMap(snapshot.data());

        if (!subjects.containsKey(id)) {
          throw const SubjectRepositoryException(
            'Não encontramos essa disciplina para excluir.',
          );
        }

        subjects.remove(id);
        transaction.set(
          docRef,
          {_subjectsField: subjects},
          SetOptions(merge: true),
        );
      });
    });
  }

  List<AcademicSubject> _parseSubjects(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String uid,
  ) {
    if (!snapshot.exists) return [];

    return _readSubjectsMap(snapshot.data())
        .entries
        .map((entry) {
          final data = entry.value;
          if (data is! Map) return null;

          return AcademicSubject.fromMap(
            id: entry.key,
            userId: uid,
            data: Map<String, dynamic>.from(data),
          );
        })
        .whereType<AcademicSubject>()
        .toList();
  }

  Map<String, dynamic> _readSubjectsMap(Map<String, dynamic>? data) {
    final rawSubjects = data?[_subjectsField];
    if (rawSubjects is! Map) return {};

    return Map<String, dynamic>.from(rawSubjects);
  }

  void _sortSubjects(List<AcademicSubject> subjects) {
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
        'Sem permissão para salvar disciplinas. Saia da conta, entre novamente '
        'e tente outra vez. Se continuar, peça ao responsável pelo Firebase '
        'para publicar as regras do arquivo firestore.rules.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos essa disciplina para excluir.',
      _ => error.message ?? 'Não foi possível salvar a disciplina.',
    };
  }
}
