import 'package:academic_manager_app/repositories/user_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileRepositoryException', () {
    test('exposes its message', () {
      const exception = UserProfileRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
