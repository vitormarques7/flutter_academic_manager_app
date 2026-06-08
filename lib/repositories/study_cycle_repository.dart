import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/study_cycle.dart';

class StudyCycleRepositoryException implements Exception {
  final String message;

  const StudyCycleRepositoryException(this.message);

  @override
  String toString() => message;
}

class StudyCycleRepository {
  StudyCycleRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _studyCyclesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('studyCycles');
  }

  Stream<List<StudyCycle>> watchStudyCycles() {
    final uid = _currentUserId;

    return _studyCyclesCollection(uid).snapshots().map((snapshot) {
      return _sortStudyCycles(
        snapshot.docs.map(StudyCycle.fromFirestore).toList(),
      );
    });
  }

  Future<List<StudyCycle>> fetchStudyCycles() async {
    final uid = _currentUserId;

    final snapshot = await _guardFirestoreCall(() {
      return _studyCyclesCollection(uid).get();
    });

    return _sortStudyCycles(
      snapshot.docs.map(StudyCycle.fromFirestore).toList(),
    );
  }

  Future<void> createStudyCycle(StudyCycleInput input) async {
    final uid = _currentUserId;

    await _guardFirestoreCall(() {
      return _studyCyclesCollection(uid).add(input.toCreateMap());
    });
  }

  Future<void> updateStudyCycle({
    required String id,
    required StudyCycleInput input,
  }) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _studyCyclesCollection(uid).doc(id).update(input.toUpdateMap());
    });
  }

  Future<void> deleteStudyCycle(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _studyCyclesCollection(uid).doc(id).delete();
    });
  }

  List<StudyCycle> _sortStudyCycles(List<StudyCycle> studyCycles) {
    studyCycles.sort(StudyCycle.compareByMostRecent);
    return studyCycles;
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const StudyCycleRepositoryException(
        'Entre na sua conta para salvar seu ciclo de estudos.',
      );
    }

    return user.uid;
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on StudyCycleRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw StudyCycleRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const StudyCycleRepositoryException(
        'Não foi possível salvar seu ciclo de estudos. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar ciclos de estudo. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos esse ciclo de estudos para atualizar.',
      _ => error.message ?? 'Não foi possível salvar seu ciclo de estudos.',
    };
  }
}
