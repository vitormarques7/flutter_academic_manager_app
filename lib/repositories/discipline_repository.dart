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

  Future<void> createDiscipline(DisciplineInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _disciplinesCollection(uid).add(input.toCreateMap());
    });
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
}
