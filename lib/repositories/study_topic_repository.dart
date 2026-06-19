import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/study_topic.dart';
import 'user_profile_repository.dart';

class StudyTopicRepositoryException implements Exception {
  final String message;

  const StudyTopicRepositoryException(this.message);

  @override
  String toString() => message;
}

class StudyTopicRepository {
  StudyTopicRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    UserProfileRepository? userProfileRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _userProfileRepository =
           userProfileRepository ??
           UserProfileRepository(
             firestore: firestore,
             firebaseAuth: firebaseAuth,
           );

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final UserProfileRepository _userProfileRepository;

  CollectionReference<Map<String, dynamic>> _topicsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('studyTopics');
  }

  Query<Map<String, dynamic>> _topicsQuery(String uid, {String? studyCycleId}) {
    Query<Map<String, dynamic>> query = _topicsCollection(uid);
    final normalizedStudyCycleId = _normalizeString(studyCycleId);

    if (normalizedStudyCycleId != null) {
      query = query.where('studyCycleId', isEqualTo: normalizedStudyCycleId);
    }

    return query;
  }

  Stream<List<StudyTopic>> watchTopics({
    String? studyCycleId,
    String? disciplineId,
  }) {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    final normalizedDisciplineId = _normalizeString(disciplineId);

    return _topicsQuery(uid, studyCycleId: studyCycleId).snapshots().map((
      snapshot,
    ) {
      final topics = snapshot.docs.map(StudyTopic.fromFirestore).where((topic) {
        final matchesStudyCycle =
            normalizedStudyCycleId == null ||
            topic.studyCycleId == normalizedStudyCycleId;
        final matchesDiscipline =
            normalizedDisciplineId == null ||
            topic.disciplineId == normalizedDisciplineId;

        return matchesStudyCycle && matchesDiscipline;
      }).toList();

      return _sortTopics(topics);
    });
  }

  Future<List<StudyTopic>> fetchTopics({
    String? studyCycleId,
    String? disciplineId,
  }) async {
    final uid = _currentUserId;
    final normalizedStudyCycleId = _normalizeString(studyCycleId);
    final normalizedDisciplineId = _normalizeString(disciplineId);

    final snapshot = await _guardFirestoreCall(() {
      return _topicsQuery(uid, studyCycleId: studyCycleId).get();
    });

    final topics = snapshot.docs.map(StudyTopic.fromFirestore).where((topic) {
      final matchesStudyCycle =
          normalizedStudyCycleId == null ||
          topic.studyCycleId == normalizedStudyCycleId;
      final matchesDiscipline =
          normalizedDisciplineId == null ||
          topic.disciplineId == normalizedDisciplineId;

      return matchesStudyCycle && matchesDiscipline;
    }).toList();

    return _sortTopics(topics);
  }

  Future<String> createTopic(StudyTopicInput input) async {
    final uid = _currentUserId;
    final topicInput = await _withActiveStudyCycle(input);

    final document = await _guardFirestoreCall(() {
      return _topicsCollection(uid).add(topicInput.toCreateMap());
    });

    return document.id;
  }

  Future<void> updateTopic({
    required String id,
    required StudyTopicInput input,
  }) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _topicsCollection(uid).doc(id).update(input.toUpdateMap());
    });
  }

  Future<void> updateStatus({
    required StudyTopic topic,
    required StudyTopicStatus status,
  }) {
    final uid = _currentUserId;
    final seenAt = status == StudyTopicStatus.seen ? DateTime.now() : null;
    final input = StudyTopicInput(
      studyCycleId: topic.studyCycleId,
      disciplineId: topic.disciplineId,
      disciplineName: topic.disciplineName,
      title: topic.title,
      status: status,
      position: topic.position,
      seenAt: seenAt,
    );

    return _guardFirestoreCall(() {
      return _topicsCollection(uid).doc(topic.id).update(input.toUpdateMap());
    });
  }

  Future<void> deleteTopic(String id) {
    final uid = _currentUserId;

    return _guardFirestoreCall(() {
      return _topicsCollection(uid).doc(id).delete();
    });
  }

  List<StudyTopic> _sortTopics(List<StudyTopic> topics) {
    topics.sort(StudyTopic.compareByPosition);
    return topics;
  }

  Future<StudyTopicInput> _withActiveStudyCycle(StudyTopicInput input) async {
    if (_normalizeString(input.studyCycleId) != null) return input;

    final activeStudyCycleId = await _resolveActiveStudyCycleId();
    if (activeStudyCycleId == null) return input;

    return input.copyWith(studyCycleId: activeStudyCycleId);
  }

  Future<String?> _resolveActiveStudyCycleId() async {
    try {
      return await _userProfileRepository.resolveActiveStudyCycleId();
    } on UserProfileRepositoryException catch (error) {
      throw StudyTopicRepositoryException(error.message);
    }
  }

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const StudyTopicRepositoryException(
        'Entre na sua conta para salvar assuntos.',
      );
    }

    return user.uid;
  }

  Future<T> _guardFirestoreCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on StudyTopicRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw StudyTopicRepositoryException(_mapFirestoreError(error));
    } catch (_) {
      throw const StudyTopicRepositoryException(
        'Não foi possível salvar o assunto. Tente novamente.',
      );
    }
  }

  String _mapFirestoreError(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Você não tem permissão para salvar assuntos. Verifique as regras do Firestore.',
      'unavailable' =>
        'O Firestore está indisponível agora. Tente novamente em instantes.',
      'not-found' => 'Não encontramos esse assunto.',
      _ => error.message ?? 'Não foi possível salvar o assunto.',
    };
  }

  static String? _normalizeString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
