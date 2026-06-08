import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final String? activeStudyCycleId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.activeStudyCycleId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return UserProfile.fromMap(id: document.id, data: document.data() ?? {});
  }

  factory UserProfile.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return UserProfile(
      id: id,
      displayName: _readString(data['displayName']),
      email: _readString(data['email']),
      activeStudyCycleId: _readString(data['activeStudyCycleId']),
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'activeStudyCycleId': activeStudyCycleId,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
