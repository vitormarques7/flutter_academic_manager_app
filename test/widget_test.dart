import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthException exposes its message', () {
    const exception = AuthException('Mensagem de teste');

    expect(exception.message, 'Mensagem de teste');
    expect(exception.toString(), 'Mensagem de teste');
  });
}
