import 'package:academic_manager_app/repositories/discipline_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DisciplineRepositoryException', () {
    test('exposes its message', () {
      const exception = DisciplineRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
