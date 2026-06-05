import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../selectors/weekday_selector.dart';

class ScheduleDialog extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const ScheduleDialog({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  final Set<int> _selectedWeekdays = {2, 4};
  final List<_ScheduleTimeRange> _timeRanges = [
    _ScheduleTimeRange(
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 50),
    ),
    _ScheduleTimeRange(
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 50),
    ),
  ];

  void _toggleWeekday(int index) {
    setState(() {
      if (!_selectedWeekdays.add(index)) {
        _selectedWeekdays.remove(index);
      }
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
      backgroundColor: Colors.white,
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(32, 26, 32, 34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.background),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66587DBD),
                blurRadius: 4,
                offset: Offset(0, 4),
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
                      child: const Icon(Icons.chevron_left, size: 34),
                    ),
                    const Expanded(
                      child: Text(
                        'Adicionar horario',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
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
                const Text(
                  'Quando acontece?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Defina os dias da semana e horários da sua disciplina.',
                  style: TextStyle(
                    color: Color(0xFF8E8888),
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dias da semana',
                  style: TextStyle(
                    color: Colors.black,
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
                const Text(
                  'Horários',
                  style: TextStyle(
                    color: Colors.black,
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
                      backgroundColor: const Color(0xFFE4E4FF),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: Color(0x7F514EB6)),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
                      onPressed: widget.onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0x7F514EB6)),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.textMuted),
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
                  child: VerticalDivider(
                    width: 1,
                    color: AppColors.textMuted,
                    thickness: 1,
                  ),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.textMuted),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 6,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.black,
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
                  const Text(
                    'Definir horário',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(
                      TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
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
                  const Text(
                    ':',
                    style: TextStyle(
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
              style: const TextStyle(
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
