import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/app_colors.dart';
import '../selectors/weekday_selector.dart';

class SubjectDialogResult {
  final String name;
  final String teacher;
  final int workload;
  final List<SubjectScheduleEntry> schedule;

  const SubjectDialogResult({
    required this.name,
    required this.teacher,
    required this.workload,
    required this.schedule,
  });
}

class SubjectScheduleEntry {
  final int weekdayIndex;
  final String startTime;
  final String endTime;

  const SubjectScheduleEntry({
    required this.weekdayIndex,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'weekdayIndex': weekdayIndex,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class SubjectDialog extends StatefulWidget {
  const SubjectDialog({super.key});

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _workloadController = TextEditingController();
  final Set<int> _selectedWeekdays = {};
  final List<_ScheduleTimeRange> _timeRanges = [
    _ScheduleTimeRange(
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _workloadController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_validateSchedule() != null) {
      setState(() {});
      return;
    }

    Navigator.of(context).pop(
      SubjectDialogResult(
        name: _nameController.text.trim(),
        teacher: _teacherController.text.trim().isEmpty
            ? 'Professor não informado'
            : _teacherController.text.trim(),
        workload: int.tryParse(_workloadController.text.trim()) ?? 0,
        schedule: _buildSchedule(),
      ),
    );
  }

  List<SubjectScheduleEntry> _buildSchedule() {
    if (_selectedWeekdays.isEmpty) return const [];

    return _selectedWeekdays.expand((weekdayIndex) {
      return _timeRanges.map((range) {
        return SubjectScheduleEntry(
          weekdayIndex: weekdayIndex,
          startTime: _formatTime(range.startTime),
          endTime: _formatTime(range.endTime),
        );
      });
    }).toList();
  }

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
          endTime: const TimeOfDay(hour: 10, minute: 0),
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
            endTime: const TimeOfDay(hour: 10, minute: 0),
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
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? range.startTime : range.endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
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

  String? _validateWorkload(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return null;

    final workload = int.tryParse(text);
    if (workload == null || workload <= 0) {
      return 'Informe uma carga horária válida.';
    }

    return null;
  }

  String? _validateSchedule() {
    if (_selectedWeekdays.isEmpty) return null;

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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E4F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80514EB6),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Nova Disciplina',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.33,
                              letterSpacing: -0.36,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF464552),
                            size: 32,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E4F0)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LabeledField(
                          label: 'DISCIPLINA',
                          child: TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'Ex: Programação',
                            ),
                            validator: (value) {
                              if ((value?.trim() ?? '').isEmpty) {
                                return 'Informe o nome da disciplina.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        _LabeledField(
                          label: 'PROFESSOR',
                          child: TextFormField(
                            controller: _teacherController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'Ex: Prof. Alguém',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _LabeledField(
                          label: 'CARGA HORÁRIA',
                          child: TextFormField(
                            controller: _workloadController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration(hintText: 'Ex: 60'),
                            validator: _validateWorkload,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _FieldLabel('DIAS DA SEMANA'),
                        const SizedBox(height: 10),
                        WeekdaySelector(
                          selectedIndexes: _selectedWeekdays,
                          onChanged: _toggleWeekday,
                        ),
                        const SizedBox(height: 24),
                        const _FieldLabel('HORÁRIO(S)'),
                        const SizedBox(height: 10),
                        ..._timeRanges.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ScheduleTimeRow(
                              range: entry.value,
                              canDelete: _timeRanges.length > 1,
                              onStartTap: () => _pickTime(
                                index: entry.key,
                                isStartTime: true,
                              ),
                              onEndTap: () => _pickTime(
                                index: entry.key,
                                isStartTime: false,
                              ),
                              onDelete: () => _removeTimeRange(entry.key),
                            ),
                          );
                        }),
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: OutlinedButton.icon(
                            onPressed: _addTimeRange,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Adicionar horário'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: Color(0x7F514EB6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        if (_validateSchedule() != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _validateSchedule()!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E4F0)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF39349D),
                              side: const BorderSide(color: Color(0xFF39349D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppColors.primary.withValues(
                                alpha: 0.28,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_outlined, size: 28),
                                SizedBox(width: 10),
                                Text(
                                  'Salvar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: _fieldBorder(),
      enabledBorder: _fieldBorder(),
      focusedBorder: _fieldBorder(color: AppColors.primary),
      errorBorder: _fieldBorder(color: Colors.red),
      focusedErrorBorder: _fieldBorder(color: Colors.red),
    );
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  OutlineInputBorder _fieldBorder({Color color = const Color(0xFFE2E4F0)}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF464552),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 0.72,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF464552),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          height: 1.50,
          letterSpacing: 0.72,
        ),
      ),
    );
  }
}

class _ScheduleTimeRow extends StatelessWidget {
  final _ScheduleTimeRange range;
  final bool canDelete;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final VoidCallback onDelete;

  const _ScheduleTimeRow({
    required this.range,
    required this.canDelete,
    required this.onStartTap,
    required this.onEndTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeButton(
            label: _format(range.startTime),
            onTap: onStartTap,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'até',
            style: TextStyle(
              color: Color(0xFF464552),
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: _TimeButton(label: _format(range.endTime), onTap: onEndTap),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: canDelete ? onDelete : null,
          icon: const Icon(Icons.delete_outline),
          color: const Color(0xFF464552),
          disabledColor: const Color(0xFFC7C7D1),
          tooltip: 'Remover horário',
        ),
      ],
    );
  }

  String _format(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1B1B20),
          side: const BorderSide(color: Color(0xFFE2E4F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ScheduleTimeRange {
  TimeOfDay startTime;
  TimeOfDay endTime;

  _ScheduleTimeRange({required this.startTime, required this.endTime});
}
