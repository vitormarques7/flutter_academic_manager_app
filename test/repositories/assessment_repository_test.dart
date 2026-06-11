import 'package:academic_manager_app/repositories/assessment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssessmentRepositoryException', () {
    test('exposes its message', () {
      const exception = AssessmentRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
