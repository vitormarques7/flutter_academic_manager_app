import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/assessment.dart';

class AssessmentRepositoryException implements Exception {
  final String message;

  const AssessmentRepositoryException(this.message);

  @override
  String toString() => message;
}

class AssessmentRepository {
  AssessmentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _assessmentsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('assessments');
  }

  Query<Map<String, dynamic>> _assessmentsQuery(
    String uid, {
    String? studyCycleId,
    String? disciplineId,
  }) {
    Query<Map<String, dynamic>> query = _assessmentsCollection(uid);
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

  Stream<List<Assessment>> watchAssessments({
    String? studyCycleId,
    String? disciplineId,
  }) {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    final normalizedDisciplineId = _normalizeString(disciplineId);

    return _assessmentsQuery(
      uid,
      studyCycleId: studyCycleId,
      disciplineId: disciplineId,
    ).snapshots().map((snapshot) {
      final assessments = snapshot.docs.map(Assessment.fromFirestore).where((
        assessment,
      ) {
        final matchesStudyCycle =
            normalizedStudyCycleId == null ||
            assessment.studyCycleId == normalizedStudyCycleId;
        final matchesDiscipline =
            normalizedDisciplineId == null ||
            assessment.disciplineId == normalizedDisciplineId;

        return matchesStudyCycle && matchesDiscipline;
      }).toList();

      return _sortAssessments(assessments);
    });
  }

  Future<void> createAssessment(AssessmentInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _assessmentsCollection(uid).add(input.toCreateMap());
    });
  }

  Future<void> updateAssessment({
    required String id,
    required AssessmentInput input,
  }) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _assessmentsCollection(uid).doc(id).update(input.toUpdateMap());
    });
  }

  Future<void> deleteAssessment(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _assessmentsCollection(uid).doc(id).delete();
    });
  }

  List<Assessment> _sortAssessments(List<Assessment> assessments) {
    assessments.sort(Assessment.compareByMostRecent);
    return assessments;
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AssessmentRepositoryException(
        'Entre na sua conta para salvar notas.',
      );
    }

    return user.uid;
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AssessmentRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw AssessmentRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const AssessmentRepositoryException(
        'Não foi possível salvar a nota. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar notas. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos essa nota.',
      _ => error.message ?? 'Não foi possível salvar a nota.',
    };
  }

  static String? _normalizeString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
