import 'package:academic_manager_app/repositories/study_topic_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudyTopicRepositoryException', () {
    test('exposes its message', () {
      const exception = StudyTopicRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
