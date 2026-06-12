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

  Future<String> createStudyCycle(StudyCycleInput input) async {
    final uid = _currentUserId;

    final document = await _guardFirestoreCall(() {
      return _studyCyclesCollection(uid).add(input.toCreateMap());
    });

    return document.id;
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

  Future<void> renameUniversityCourse({
    required String currentName,
    required String newName,
  }) async {
    final uid = _currentUserId;
    final normalizedCurrentName = _normalizeString(currentName);
    final normalizedNewName = _normalizeString(newName);

    if (normalizedCurrentName == null || normalizedNewName == null) {
      throw const StudyCycleRepositoryException('Informe o nome do curso.');
    }

    if (_courseNameKey(normalizedCurrentName) ==
        _courseNameKey(normalizedNewName)) {
      return;
    }

    await _guardFirestoreCall(() async {
      final snapshot = await _studyCyclesCollection(uid).get();
      final matchingDocuments = snapshot.docs.where((document) {
        final studyCycle = StudyCycle.fromFirestore(document);
        return studyCycle.type == StudyCycleType.university &&
            studyCycle.courseName != null &&
            _courseNameKey(studyCycle.courseName!) ==
                _courseNameKey(normalizedCurrentName);
      }).toList();

      if (matchingDocuments.isEmpty) return;

      final batch = _firestore.batch();
      for (final document in matchingDocuments) {
        batch.update(document.reference, {
          'courseName': normalizedNewName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
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

  static String? _normalizeString(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static String _courseNameKey(String value) {
    return value.trim().toLowerCase();
  }
}
