import 'package:academic_manager_app/view/widgets/inputs/date_picker_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseBrazilianDate', () {
    test('parses valid dd/mm/yyyy dates', () {
      expect(parseBrazilianDate('11/06/2026'), DateTime(2026, 6, 11));
    });

    test('rejects invalid or incomplete dates', () {
      expect(parseBrazilianDate('31/02/2026'), isNull);
      expect(parseBrazilianDate('11062026'), isNull);
      expect(parseBrazilianDate(''), isNull);
    });
  });

  group('formatBrazilianDate', () {
    test('formats dates as dd/mm/yyyy', () {
      expect(formatBrazilianDate(DateTime(2026, 6, 5)), '05/06/2026');
    });
  });

  group('BrazilianDateInputFormatter', () {
    test('formats typed digits and limits to eight numbers', () {
      final formatter = BrazilianDateInputFormatter();
      final value = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1106202699'),
      );

      expect(value.text, '11/06/2026');
      expect(value.selection.baseOffset, value.text.length);
    });
  });
}
