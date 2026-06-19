import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/discipline.dart';

class DisciplineRepositoryException implements Exception {
  final String message;

  const DisciplineRepositoryException(this.message);

  @override
  String toString() => message;
}

class DisciplineRepository {
  DisciplineRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _disciplinesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('disciplines');
  }

  CollectionReference<Map<String, dynamic>> _schedulesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('schedules');
  }

  CollectionReference<Map<String, dynamic>> _assessmentsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('assessments');
  }

  CollectionReference<Map<String, dynamic>> _studySessionsCollection(
    String uid,
  ) {
    return _firestore.collection('users').doc(uid).collection('studySessions');
  }

  CollectionReference<Map<String, dynamic>> _studyTopicsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('studyTopics');
  }

  Query<Map<String, dynamic>> _disciplinesQuery(
    String uid, {
    String? studyCycleId,
  }) {
    final collection = _disciplinesCollection(uid);
    final trimmedStudyCycleId = studyCycleId?.trim();

    if (trimmedStudyCycleId == null || trimmedStudyCycleId.isEmpty) {
      return collection;
    }

    return collection.where('studyCycleId', isEqualTo: trimmedStudyCycleId);
  }

  Stream<List<Discipline>> watchDisciplines({String? studyCycleId}) {
    final uid = _currentUserId;

    return _disciplinesQuery(uid, studyCycleId: studyCycleId).snapshots().map((
      snapshot,
    ) {
      return _sortDisciplines(
        snapshot.docs.map(Discipline.fromFirestore).toList(),
      );
    });
  }

  Future<List<Discipline>> fetchDisciplines({String? studyCycleId}) async {
    final uid = _currentUserId;

    final snapshot = await _guardFirestoreCall(() {
      return _disciplinesQuery(uid, studyCycleId: studyCycleId).get();
    });

    return _sortDisciplines(
      snapshot.docs.map(Discipline.fromFirestore).toList(),
    );
  }

  Future<String> createDiscipline(DisciplineInput input) async {
    final uid = _currentUserId;

    final document = await _guardFirestoreCall(() {
      return _disciplinesCollection(uid).add(input.toCreateMap());
    });

    return document.id;
  }

  Future<void> updateDiscipline({
    required String id,
    required DisciplineInput input,
  }) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _disciplinesCollection(uid).doc(id).update(input.toUpdateMap());
    });
  }

  Future<void> deleteDiscipline(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _disciplinesCollection(uid).doc(id).delete();
    });
  }

  Future<void> deleteDisciplineWithRelatedData(Discipline discipline) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() async {
      final normalizedStudyCycleId = _normalizeString(discipline.studyCycleId);
      final normalizedDisciplineName = _normalizeString(
        discipline.name,
      )?.toLowerCase();
      final schedulesQuery = normalizedStudyCycleId == null
          ? _schedulesCollection(uid)
          : _schedulesCollection(
              uid,
            ).where('studyCycleId', isEqualTo: normalizedStudyCycleId);
      final assessmentsQuery = normalizedStudyCycleId == null
          ? _assessmentsCollection(uid)
          : _assessmentsCollection(
              uid,
            ).where('studyCycleId', isEqualTo: normalizedStudyCycleId);
      final studySessionsQuery = normalizedStudyCycleId == null
          ? _studySessionsCollection(uid)
          : _studySessionsCollection(
              uid,
            ).where('studyCycleId', isEqualTo: normalizedStudyCycleId);
      final studyTopicsQuery = normalizedStudyCycleId == null
          ? _studyTopicsCollection(uid)
          : _studyTopicsCollection(
              uid,
            ).where('studyCycleId', isEqualTo: normalizedStudyCycleId);
      final schedulesSnapshot = await schedulesQuery.get();
      final assessmentsSnapshot = await assessmentsQuery.get();
      final studySessionsSnapshot = await studySessionsQuery.get();
      final studyTopicsSnapshot = await studyTopicsQuery.get();
      final referencesToDelete = <DocumentReference<Map<String, dynamic>>>[
        _disciplinesCollection(uid).doc(discipline.id),
      ];

      for (final scheduleDocument in schedulesSnapshot.docs) {
        final scheduleData = scheduleDocument.data();
        final scheduleDisciplineId = _normalizeString(
          scheduleData['disciplineId'],
        );
        final scheduleDisciplineName = _normalizeString(
          scheduleData['disciplineName'],
        )?.toLowerCase();
        final belongsToDiscipline =
            scheduleDisciplineId == discipline.id ||
            (scheduleDisciplineId == null &&
                normalizedDisciplineName != null &&
                scheduleDisciplineName == normalizedDisciplineName);

        if (belongsToDiscipline) {
          referencesToDelete.add(scheduleDocument.reference);
        }
      }

      for (final assessmentDocument in assessmentsSnapshot.docs) {
        final assessmentData = assessmentDocument.data();
        final assessmentDisciplineId = _normalizeString(
          assessmentData['disciplineId'],
        );
        final assessmentDisciplineName = _normalizeString(
          assessmentData['disciplineName'],
        )?.toLowerCase();
        final belongsToDiscipline =
            assessmentDisciplineId == discipline.id ||
            (assessmentDisciplineId == null &&
                normalizedDisciplineName != null &&
                assessmentDisciplineName == normalizedDisciplineName);

        if (belongsToDiscipline) {
          referencesToDelete.add(assessmentDocument.reference);
        }
      }

      for (final sessionDocument in studySessionsSnapshot.docs) {
        if (_documentBelongsToDiscipline(
          data: sessionDocument.data(),
          disciplineId: discipline.id,
          disciplineName: normalizedDisciplineName,
        )) {
          referencesToDelete.add(sessionDocument.reference);
        }
      }

      for (final topicDocument in studyTopicsSnapshot.docs) {
        if (_documentBelongsToDiscipline(
          data: topicDocument.data(),
          disciplineId: discipline.id,
          disciplineName: normalizedDisciplineName,
        )) {
          referencesToDelete.add(topicDocument.reference);
        }
      }

      for (var index = 0; index < referencesToDelete.length; index += 500) {
        final batch = _firestore.batch();
        final chunk = referencesToDelete.skip(index).take(500);

        for (final reference in chunk) {
          batch.delete(reference);
        }

        await batch.commit();
      }
    });
  }

  Future<void> deleteDisciplineWithSchedules(Discipline discipline) {
    return deleteDisciplineWithRelatedData(discipline);
  }

  Future<void> updateAbsences(String disciplineId, int absences) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _disciplinesCollection(uid).doc(disciplineId).update({
        'absences': absences < 0 ? 0 : absences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateMaxAbsences(String disciplineId, int maxAbsences) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _disciplinesCollection(uid).doc(disciplineId).update({
        'maxAbsences': maxAbsences < 0 ? 0 : maxAbsences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  List<Discipline> _sortDisciplines(List<Discipline> disciplines) {
    disciplines.sort(Discipline.compareByName);
    return disciplines;
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const DisciplineRepositoryException(
        'Entre na sua conta para salvar disciplinas.',
      );
    }

    return user.uid;
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DisciplineRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw DisciplineRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const DisciplineRepositoryException(
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
      'not-found' => 'Não encontramos essa disciplina para atualizar.',
      _ => error.message ?? 'Não foi possível salvar a disciplina.',
    };
  }

  static String? _normalizeString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool _documentBelongsToDiscipline({
    required Map<String, dynamic> data,
    required String disciplineId,
    required String? disciplineName,
  }) {
    final documentDisciplineId = _normalizeString(data['disciplineId']);
    final documentDisciplineName = _normalizeString(
      data['disciplineName'],
    )?.toLowerCase();

    return documentDisciplineId == disciplineId ||
        (documentDisciplineId == null &&
            disciplineName != null &&
            documentDisciplineName == disciplineName);
  }
}
