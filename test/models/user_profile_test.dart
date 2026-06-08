import 'package:academic_manager_app/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    test('fromMap preserves valid fields', () {
      final createdAt = Timestamp.fromDate(DateTime(2026, 6, 8, 16));
      final updatedAt = Timestamp.fromDate(DateTime(2026, 6, 8, 17));

      final profile = UserProfile.fromMap(
        id: 'user-1',
        data: {
          'displayName': ' Goku ',
          'email': ' goku@example.com ',
          'activeStudyCycleId': ' cycle-1 ',
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );

      expect(profile.id, 'user-1');
      expect(profile.displayName, 'Goku');
      expect(profile.email, 'goku@example.com');
      expect(profile.activeStudyCycleId, 'cycle-1');
      expect(profile.createdAt, createdAt.toDate());
      expect(profile.updatedAt, updatedAt.toDate());
    });

    test('fromMap applies predictable defaults for missing fields', () {
      final profile = UserProfile.fromMap(id: 'user-1', data: const {});

      expect(profile.displayName, isNull);
      expect(profile.email, isNull);
      expect(profile.activeStudyCycleId, isNull);
      expect(profile.createdAt, isNull);
      expect(profile.updatedAt, isNull);
    });

    test('toFirestore can be reconstructed without semantic loss', () {
      final original = UserProfile(
        id: 'user-1',
        displayName: 'Goku',
        email: 'goku@example.com',
        activeStudyCycleId: 'cycle-1',
        createdAt: DateTime(2026, 6, 8, 16),
        updatedAt: DateTime(2026, 6, 8, 17),
      );

      final reconstructed = UserProfile.fromMap(
        id: original.id,
        data: original.toFirestore(),
      );

      expect(reconstructed.id, original.id);
      expect(reconstructed.displayName, original.displayName);
      expect(reconstructed.email, original.email);
      expect(reconstructed.activeStudyCycleId, original.activeStudyCycleId);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.updatedAt, original.updatedAt);
    });
  });
}
