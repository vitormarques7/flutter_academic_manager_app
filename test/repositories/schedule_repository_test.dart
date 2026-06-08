import 'package:academic_manager_app/repositories/schedule_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleRepositoryException', () {
    test('exposes its message', () {
      const exception = ScheduleRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
