import 'package:flutter/material.dart';
import '../../../config/theme/app_theme_colors.dart';
import '../selectors/weekday_selector.dart';

class ScheduleDialogResult {
  final String? disciplineName;
  final List<int> weekdays;
  final List<ScheduleTimeRangeResult> timeRanges;

  const ScheduleDialogResult({
    this.disciplineName,
    required this.weekdays,
    required this.timeRanges,
  });

  const ScheduleDialogResult.empty()
    : disciplineName = null,
      weekdays = const [],
      timeRanges = const [];
}

class ScheduleTimeRangeResult {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const ScheduleTimeRangeResult({
    required this.startTime,
    required this.endTime,
  });

  int get startTimeMinutes => startTime.hour * 60 + startTime.minute;

  int get endTimeMinutes => endTime.hour * 60 + endTime.minute;
}

class ScheduleDialog extends StatefulWidget {
  final bool showDisciplineNameField;

  const ScheduleDialog({super.key, this.showDisciplineNameField = false});

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  final _disciplineNameController = TextEditingController();
  final Set<int> _selectedWeekdays = {2, 4};
  final List<_ScheduleTimeRange> _timeRanges = [
    _ScheduleTimeRange(
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 50),
    ),
  ];
  String? _errorMessage;

  @override
  void dispose() {
    _disciplineNameController.dispose();
    super.dispose();
  }

  void _toggleWeekday(int index) {
    setState(() {
      if (!_selectedWeekdays.add(index)) {
        _selectedWeekdays.remove(index);
      }
      _errorMessage = null;
    });
  }

  void _addTimeRange() {
    setState(() {
      _timeRanges.add(
        _ScheduleTimeRange(
          startTime: const TimeOfDay(hour: 8, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 50),
        ),
      );
      _errorMessage = null;
    });
  }

  void _removeTimeRange(int index) {
    setState(() {
      _timeRanges.removeAt(index);
      if (_timeRanges.isEmpty) {
        _timeRanges.add(
          _ScheduleTimeRange(
            startTime: const TimeOfDay(hour: 8, minute: 0),
            endTime: const TimeOfDay(hour: 10, minute: 50),
          ),
        );
      }
      _errorMessage = null;
    });
  }

  Future<void> _pickTime({
    required int index,
    required bool isStartTime,
  }) async {
    final range = _timeRanges[index];
    final initialTime = isStartTime ? range.startTime : range.endTime;

    final selectedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _TimeWheelPicker(initialTime: initialTime),
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      if (isStartTime) {
        range.startTime = selectedTime;
      } else {
        range.endTime = selectedTime;
      }
      _errorMessage = null;
    });
  }

  void _onContinue() {
    final errorMessage = _validateSchedule();
    if (errorMessage != null) {
      setState(() => _errorMessage = errorMessage);
      return;
    }

    final weekdays = _selectedWeekdays.toList()..sort();
    final timeRanges = _timeRanges.map((range) {
      return ScheduleTimeRangeResult(
        startTime: range.startTime,
        endTime: range.endTime,
      );
    }).toList();

    Navigator.of(context).pop(
      ScheduleDialogResult(
        disciplineName: _disciplineNameController.text.trim(),
        weekdays: weekdays,
        timeRanges: timeRanges,
      ),
    );
  }

  String? _validateSchedule() {
    if (widget.showDisciplineNameField &&
        _disciplineNameController.text.trim().isEmpty) {
      return 'Informe o nome da disciplina.';
    }

    if (_selectedWeekdays.isEmpty) return 'Selecione pelo menos um dia.';

    for (final range in _timeRanges) {
      final startMinutes = range.startTime.hour * 60 + range.startTime.minute;
      final endMinutes = range.endTime.hour * 60 + range.endTime.minute;

      if (endMinutes <= startMinutes) {
        return 'O horário final deve ser depois do inicial.';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(32, 26, 32, 34),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outline),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(18),
                      child: Icon(
                        Icons.chevron_left,
                        color: colors.textDark,
                        size: 34,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Adicionar horario',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textDark,
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 34),
                  ],
                ),
                const SizedBox(height: 38),
                if (widget.showDisciplineNameField) ...[
                  Text(
                    'Disciplina',
                    style: TextStyle(
                      color: colors.textDark,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _disciplineNameController,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: colors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Ex: Programação Mobile',
                      hintStyle: TextStyle(color: colors.textMuted),
                      filled: true,
                      fillColor: colors.defaultFieldBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.primary),
                      ),
                    ),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),
                  const SizedBox(height: 26),
                ],
                Text(
                  'Quando acontece?',
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Defina os dias da semana e horários da sua disciplina.',
                  style: TextStyle(
                    color: colors.textMedium,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Dias da semana',
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                WeekdaySelector(
                  selectedIndexes: _selectedWeekdays,
                  onChanged: _toggleWeekday,
                ),
                const SizedBox(height: 30),
                Text(
                  'Horários',
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ..._timeRanges.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ScheduleTimeRow(
                      range: entry.value,
                      onStartTap: () =>
                          _pickTime(index: entry.key, isStartTime: true),
                      onEndTap: () =>
                          _pickTime(index: entry.key, isStartTime: false),
                      onDelete: () => _removeTimeRange(entry.key),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: _addTimeRange,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colors.primarySoft,
                      foregroundColor: colors.primary,
                      side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      '+ Adicionar novo horário',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: colors.danger,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.textOnPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop(const ScheduleDialogResult.empty());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(
                          color: colors.primary.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Deixar sem horário',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleTimeRow extends StatelessWidget {
  final _ScheduleTimeRange range;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final VoidCallback onDelete;

  const _ScheduleTimeRow({
    required this.range,
    required this.onStartTap,
    required this.onEndTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 29,
            decoration: BoxDecoration(
              color: context.appColors.defaultFieldBackground,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: context.appColors.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onStartTap,
                    borderRadius: BorderRadius.circular(5),
                    child: _TimeLabel(
                      title: 'Inicio',
                      time: _formatTime(range.startTime),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 21,
                  child: VerticalDivider(width: 1, thickness: 1),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onEndTap,
                    borderRadius: BorderRadius.circular(5),
                    child: _TimeLabel(
                      title: 'Fim',
                      time: _formatTime(range.endTime),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 29,
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.appColors.defaultFieldBackground,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: context.appColors.outline),
          ),
          child: IconButton(
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 29, height: 29),
            icon: const Icon(Icons.delete_outline, size: 19),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TimeLabel extends StatelessWidget {
  final String title;
  final String time;

  const _TimeLabel({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 6,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: colors.textDark,
            fontSize: 8,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ScheduleTimeRange {
  TimeOfDay startTime;
  TimeOfDay endTime;

  _ScheduleTimeRange({required this.startTime, required this.endTime});
}

class _TimeWheelPicker extends StatefulWidget {
  final TimeOfDay initialTime;

  const _TimeWheelPicker({required this.initialTime});

  @override
  State<_TimeWheelPicker> createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<_TimeWheelPicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const Spacer(),
                  Text(
                    'Definir horário',
                    style: TextStyle(
                      color: context.appColors.textDark,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed:
                        () => Navigator.of(context).pop(
                          TimeOfDay(
                            hour: _selectedHour,
                            minute: _selectedMinute,
                          ),
                        ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildNumberWheel(
                      controller: _hourController,
                      itemCount: 24,
                      onSelectedItemChanged: (value) {
                        setState(() => _selectedHour = value);
                      },
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      color: context.appColors.textDark,
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: _buildNumberWheel(
                      controller: _minuteController,
                      itemCount: 60,
                      onSelectedItemChanged: (value) {
                        setState(() => _selectedMinute = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    final colors = context.appColors;
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 58,
      physics: const FixedExtentScrollPhysics(parent: ClampingScrollPhysics()),
      overAndUnderCenterOpacity: 0.55,
      perspective: 0.0001,
      diameterRatio: 1000,
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          if (index < 0 || index >= itemCount) return null;

          return Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                color: colors.textDark,
                fontSize: 24,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
