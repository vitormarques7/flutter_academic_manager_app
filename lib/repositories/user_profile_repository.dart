import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/study_cycle.dart';
import '../models/user_profile.dart';

class UserProfileRepositoryException implements Exception {
  final String message;

  const UserProfileRepositoryException(this.message);

  @override
  String toString() => message;
}

class UserProfileRepository {
  UserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> _studyCyclesCollection(String uid) {
    return _userDocument(uid).collection('studyCycles');
  }

  Future<void> ensureCurrentUserDocument({
    String? displayName,
    String? email,
  }) async {
    final user = _currentUser;
    final resolvedDisplayName =
        _normalizeString(displayName) ?? _normalizeString(user.displayName);
    final resolvedEmail =
        _normalizeString(email) ?? _normalizeString(user.email);

    await _guardFirestoreCall(() {
      return _upsertUserDocument(user.uid, {
        'displayName': ?resolvedDisplayName,
        'email': ?resolvedEmail,
      });
    });
  }

  Stream<UserProfile?> watchCurrentUserProfile() {
    final user = _currentUser;

    return _userDocument(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromFirestore(snapshot);
    });
  }

  Future<UserProfile?> fetchCurrentUserProfile() async {
    final user = _currentUser;

    return _guardFirestoreCall(() async {
      final snapshot = await _userDocument(user.uid).get();
      if (!snapshot.exists) return null;
      return UserProfile.fromFirestore(snapshot);
    });
  }

  Future<String?> resolveActiveStudyCycleId() async {
    final user = _currentUser;

    return _guardFirestoreCall(() async {
      final userSnapshot = await _userDocument(user.uid).get();
      final profile = UserProfile.fromMap(
        id: user.uid,
        data: userSnapshot.data() ?? {},
      );

      if (profile.activeStudyCycleId != null) {
        return profile.activeStudyCycleId;
      }

      final studyCyclesSnapshot = await _studyCyclesCollection(user.uid).get();
      if (studyCyclesSnapshot.docs.isEmpty) return null;

      final studyCycles =
          studyCyclesSnapshot.docs.map(StudyCycle.fromFirestore).toList()
            ..sort(StudyCycle.compareByMostRecent);
      final activeStudyCycleId = studyCycles.first.id;

      await _upsertUserDocument(user.uid, {
        'activeStudyCycleId': activeStudyCycleId,
      });

      return activeStudyCycleId;
    });
  }

  Future<void> setActiveStudyCycleId(String studyCycleId) async {
    final user = _currentUser;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    if (normalizedStudyCycleId == null) return;

    await _guardFirestoreCall(() async {
      final studyCycleSnapshot = await _studyCyclesCollection(
        user.uid,
      ).doc(normalizedStudyCycleId).get();

      if (!studyCycleSnapshot.exists) {
        throw const UserProfileRepositoryException(
          'Este ciclo não está disponível para ativação.',
        );
      }

      return _upsertUserDocument(user.uid, {
        'activeStudyCycleId': normalizedStudyCycleId,
      });
    });
  }

  Future<void> updateCurrentUserProfile({
    String? displayName,
    String? email,
  }) async {
    final user = _currentUser;
    final normalizedDisplayName = _normalizeString(displayName);
    final normalizedEmail = _normalizeString(email);

    await _guardFirestoreCall(() {
      return _upsertUserDocument(user.uid, {
        'displayName': ?normalizedDisplayName,
        'email': ?normalizedEmail,
      });
    });
  }

  User get _currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const UserProfileRepositoryException(
        'Entre na sua conta para salvar seus dados.',
      );
    }

    return user;
  }

  Future<void> _upsertUserDocument(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    final document = _userDocument(uid);
    final snapshot = await document.get();

    await document.set({
      ...fields,
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UserProfileRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw UserProfileRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const UserProfileRepositoryException(
        'Não foi possível salvar seus dados. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar dados do usuário. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      _ => error.message ?? 'Não foi possível salvar seus dados.',
    };
  }

  static String? _normalizeString(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
