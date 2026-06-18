import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';

class OptionalTimeRangeField extends StatelessWidget {
  final bool hasTimeRange;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<bool> onHasTimeRangeChanged;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final String? errorText;

  const OptionalTimeRangeField({
    super.key,
    required this.hasTimeRange,
    required this.startTime,
    required this.endTime,
    required this.onHasTimeRangeChanged,
    required this.onStartTap,
    required this.onEndTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Adicionar horário',
                style: TextStyle(
                  color: colors.textMedium,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Switch(
              value: hasTimeRange,
              activeThumbColor: colors.primary,
              onChanged: onHasTimeRangeChanged,
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: hasTimeRange
              ? Column(
                  key: const ValueKey('time-range-fields'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TimePickerButton(
                            label: 'Início',
                            value: formatTimeOfDay(startTime),
                            onTap: onStartTap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TimePickerButton(
                            label: 'Fim',
                            value: formatTimeOfDay(endTime),
                            onTap: onEndTap,
                          ),
                        ),
                      ],
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: TextStyle(
                          color: colors.danger,
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('no-time-range-fields')),
        ),
      ],
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: colors.defaultFieldBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, color: colors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      final mediaQuery = MediaQuery.of(context);

      return MediaQuery(
        data: mediaQuery.copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
}

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

int timeOfDayToMinutes(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

TimeOfDay timeOfDayFromMinutes(int minutes) {
  return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
}
