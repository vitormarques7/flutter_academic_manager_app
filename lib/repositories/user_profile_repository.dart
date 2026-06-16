import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileRepository {
  UserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<void> ensureUserDocument(String uid) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid != uid) return;

    await _firestore.collection('users').doc(uid).set({
      if (user.email != null) 'email': user.email,
      if (user.displayName != null) 'displayName': user.displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
