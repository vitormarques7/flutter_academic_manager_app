import 'package:academic_manager_app/repositories/study_session_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudySessionRepositoryException', () {
    test('exposes its message', () {
      const exception = StudySessionRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
