import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/app_colors.dart';
import '../common/hero_form_sheet.dart';
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
    return HeroFormSheet(
      heroIcon: Icons.menu_book_rounded,
      title: 'Nova Disciplina',
      subtitle: 'Organize sua grade acadêmica',
      badge: 'Cadastro',
      onBack: () => Navigator.of(context).maybePop(),
      onSave: _save,
      formContent: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroFormField(
              label: 'DISCIPLINA',
              child: TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: heroFormInputDecoration(hintText: 'Ex: Programação'),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Informe o nome da disciplina.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            HeroFormField(
              label: 'PROFESSOR',
              child: TextFormField(
                controller: _teacherController,
                textInputAction: TextInputAction.next,
                decoration: heroFormInputDecoration(hintText: 'Ex: Prof. Alguém'),
              ),
            ),
            const SizedBox(height: 20),
            HeroFormField(
              label: 'CARGA HORÁRIA',
              child: TextFormField(
                controller: _workloadController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: heroFormInputDecoration(hintText: 'Ex: 60'),
                validator: _validateWorkload,
              ),
            ),
            const SizedBox(height: 20),
            HeroFormField(
              label: 'DIAS DA SEMANA',
              child: WeekdaySelector(
                selectedIndexes: _selectedWeekdays,
                onChanged: _toggleWeekday,
              ),
            ),
            const SizedBox(height: 20),
            HeroFormField(
              label: 'HORÁRIO(S)',
              child: Column(
                children: [
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
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: _addTimeRange,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Adicionar horário'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0x7F514EB6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
          ],
        ),
      ),
    );
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          side: const BorderSide(color: Color(0xFFE8EAF2)),
          backgroundColor: const Color(0xFFF5F6FA),
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
