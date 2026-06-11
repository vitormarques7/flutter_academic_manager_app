import 'package:academic_manager_app/repositories/subject_event_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubjectEventRepositoryException', () {
    test('exposes its message', () {
      const exception = SubjectEventRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
