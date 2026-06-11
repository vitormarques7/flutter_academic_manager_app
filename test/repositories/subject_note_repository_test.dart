import 'package:academic_manager_app/repositories/subject_note_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubjectNoteRepositoryException', () {
    test('exposes its message', () {
      const exception = SubjectNoteRepositoryException('Mensagem de teste');

      expect(exception.message, 'Mensagem de teste');
      expect(exception.toString(), 'Mensagem de teste');
    });
  });
}
