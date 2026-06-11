import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/app_colors.dart';

class AppDatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String helpText;

  const AppDatePickerField({
    super.key,
    required this.controller,
    required this.decoration,
    this.validator,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.helpText = 'Selecionar data',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        BrazilianDateInputFormatter(),
      ],
      decoration: decoration.copyWith(
        suffixIcon: IconButton(
          tooltip: helpText,
          onPressed: enabled ? () => _openDatePicker(context) : null,
          icon: const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.primary,
          ),
        ),
      ),
      enabled: enabled,
      validator: validator,
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final effectiveFirstDate = _dateOnly(firstDate ?? DateTime(2020));
    final effectiveLastDate = _dateOnly(lastDate ?? DateTime(2035, 12, 31));
    final parsedDate = parseBrazilianDate(controller.text);
    final effectiveInitialDate = _clampDate(
      _dateOnly(parsedDate ?? initialDate ?? DateTime.now()),
      effectiveFirstDate,
      effectiveLastDate,
    );

    final pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      initialDate: effectiveInitialDate,
      helpText: helpText,
      cancelText: 'Cancelar',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: child,
            ),
          ),
        );
      },
    );

    if (pickedDate == null) return;

    controller.text = formatBrazilianDate(pickedDate);
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _clampDate(
    DateTime date,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    if (date.isBefore(firstDate)) return firstDate;
    if (date.isAfter(lastDate)) return lastDate;

    return date;
  }
}

class BrazilianDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();

    for (var i = 0; i < limited.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

DateTime? parseBrazilianDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;

  final parts = text.split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;

  final parsed = DateTime(year, month, day);
  final isValidDate =
      parsed.day == day && parsed.month == month && parsed.year == year;

  return isValidDate ? parsed : null;
}

String formatBrazilianDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}
