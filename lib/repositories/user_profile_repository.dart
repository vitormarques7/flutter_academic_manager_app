import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  String? get _uid => _firebaseAuth.currentUser?.uid;

  Stream<UserProfile> watchProfile() {
    final uid = _uid;
    if (uid == null) {
      return Stream.value(const UserProfile());
    }

    return _userDoc(uid).snapshots().map((snapshot) {
      return UserProfile.fromMap(snapshot.data());
    });
  }

  Future<void> ensureUserDocument(String uid) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid != uid) return;

    await _userDoc(uid).set({
      if (user.email != null) 'email': user.email,
      if (user.displayName != null) 'displayName': user.displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveProfile(UserProfileInput input) async {
    final uid = _uid;
    if (uid == null) return;

    await ensureUserDocument(uid);
    await _userDoc(uid).set({
      ...input.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updatePersonalData({
    required String displayName,
    String? course,
    String? periodLabel,
  }) async {
    final user = _firebaseAuth.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    final trimmedName = displayName.trim();
    if (trimmedName.isNotEmpty && trimmedName != user!.displayName) {
      await user.updateDisplayName(trimmedName);
    }

    await saveProfile(
      UserProfileInput(
        course: course?.trim(),
        periodLabel: periodLabel?.trim(),
      ),
    );

    if (trimmedName.isNotEmpty) {
      await _userDoc(uid).set({
        'displayName': trimmedName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
