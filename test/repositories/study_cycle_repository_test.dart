import 'package:academic_manager_app/repositories/study_cycle_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudyCycleRepositoryException', () {
    test('exposes its message', () {
      const exception = StudyCycleRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
