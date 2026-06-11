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

  int get startTimeMinutes => _parseMinutes(startTime);

  int get endTimeMinutes => _parseMinutes(endTime);

  bool overlaps(SubjectScheduleEntry other) {
    if (weekdayIndex != other.weekdayIndex) return false;

    return startTimeMinutes < other.endTimeMinutes &&
        endTimeMinutes > other.startTimeMinutes;
  }

  Map<String, dynamic> toMap() {
    return {
      'weekdayIndex': weekdayIndex,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  static int _parseMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final minutes = hour * 60 + minute;

    if (minutes < 0 || minutes > 1439) return 0;
    return minutes;
  }
}

class SubjectDialog extends StatefulWidget {
  final List<SubjectScheduleEntry> unavailableScheduleEntries;

  const SubjectDialog({super.key, this.unavailableScheduleEntries = const []});

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _workloadController = TextEditingController();
  final Set<int> _selectedWeekdays = {};
  final Map<int, List<_ScheduleTimeRange>> _timeRangesByWeekday = {};
  String? _scheduleErrorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _workloadController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final scheduleError = _validateSchedule();
    if (scheduleError != null) {
      setState(() => _scheduleErrorMessage = scheduleError);
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

    final sortedWeekdays = _selectedWeekdays.toList()..sort();

    return sortedWeekdays.expand((weekdayIndex) {
      final ranges = _timeRangesByWeekday[weekdayIndex] ?? const [];

      return ranges.map((range) {
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
        _timeRangesByWeekday.remove(index);
      } else {
        _timeRangesByWeekday[index] = [_defaultTimeRange()];
      }
      _scheduleErrorMessage = null;
    });
  }

  void _addTimeRange(int weekdayIndex) {
    setState(() {
      _timeRangesByWeekday.putIfAbsent(
        weekdayIndex,
        () => [_defaultTimeRange()],
      );
      _timeRangesByWeekday[weekdayIndex]!.add(_defaultTimeRange());
      _scheduleErrorMessage = null;
    });
  }

  void _removeTimeRange({required int weekdayIndex, required int rangeIndex}) {
    setState(() {
      final ranges = _timeRangesByWeekday[weekdayIndex];
      if (ranges == null) return;

      ranges.removeAt(rangeIndex);
      if (ranges.isEmpty) {
        ranges.add(_defaultTimeRange());
      }
      _scheduleErrorMessage = null;
    });
  }

  Future<void> _pickTime({
    required int weekdayIndex,
    required int index,
    required bool isStartTime,
  }) async {
    final range = _timeRangesByWeekday[weekdayIndex]![index];
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
      _scheduleErrorMessage = null;
    });
  }

  _ScheduleTimeRange _defaultTimeRange() {
    return _ScheduleTimeRange(
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
    );
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

    for (final weekdayIndex in _selectedWeekdays) {
      final ranges = _timeRangesByWeekday[weekdayIndex] ?? const [];
      if (ranges.isEmpty) return 'Defina pelo menos um horário por dia.';

      for (final range in ranges) {
        final startMinutes = range.startTime.hour * 60 + range.startTime.minute;
        final endMinutes = range.endTime.hour * 60 + range.endTime.minute;

        if (endMinutes <= startMinutes) {
          return 'O horário final deve ser depois do inicial.';
        }
      }
    }

    final schedule = _buildSchedule();
    for (var i = 0; i < schedule.length; i++) {
      for (var j = i + 1; j < schedule.length; j++) {
        if (schedule[i].overlaps(schedule[j])) {
          return 'Há horários sobrepostos para ${_weekdayName(schedule[i].weekdayIndex)}.';
        }
      }
    }

    for (final entry in schedule) {
      for (final unavailableEntry in widget.unavailableScheduleEntries) {
        if (entry.overlaps(unavailableEntry)) {
          return 'Já existe uma disciplina em ${_weekdayName(entry.weekdayIndex)}, das ${unavailableEntry.startTime} às ${unavailableEntry.endTime}.';
        }
      }
    }

    return null;
  }

  String _weekdayName(int weekdayIndex) {
    return switch (weekdayIndex) {
      0 => 'domingo',
      1 => 'segunda',
      2 => 'terça',
      3 => 'quarta',
      4 => 'quinta',
      5 => 'sexta',
      6 => 'sábado',
      _ => 'dia selecionado',
    };
  }

  String _weekdayTitle(int weekdayIndex) {
    return switch (weekdayIndex) {
      0 => 'Domingo',
      1 => 'Segunda',
      2 => 'Terça',
      3 => 'Quarta',
      4 => 'Quinta',
      5 => 'Sexta',
      6 => 'Sábado',
      _ => 'Dia',
    };
  }

  String _weekdayShortName(int weekdayIndex) {
    return switch (weekdayIndex) {
      0 => 'dom',
      1 => 'seg',
      2 => 'ter',
      3 => 'qua',
      4 => 'qui',
      5 => 'sex',
      6 => 'sab',
      _ => 'dia',
    };
  }

  List<int> get _sortedSelectedWeekdays {
    return _selectedWeekdays.toList()..sort();
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
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 1.33,
                              letterSpacing: 0,
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
                        const _FieldLabel('HORÁRIOS POR DIA'),
                        const SizedBox(height: 10),
                        if (_selectedWeekdays.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7FD),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E4F0),
                              ),
                            ),
                            child: const Text(
                              'Selecione um dia para definir o horário.',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          ..._sortedSelectedWeekdays.map((weekdayIndex) {
                            final ranges =
                                _timeRangesByWeekday[weekdayIndex] ?? const [];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _WeekdayScheduleSection(
                                title: _weekdayTitle(weekdayIndex),
                                shortLabel: _weekdayShortName(weekdayIndex),
                                ranges: ranges,
                                onAddTimeRange: () =>
                                    _addTimeRange(weekdayIndex),
                                onPickStartTime: (rangeIndex) => _pickTime(
                                  weekdayIndex: weekdayIndex,
                                  index: rangeIndex,
                                  isStartTime: true,
                                ),
                                onPickEndTime: (rangeIndex) => _pickTime(
                                  weekdayIndex: weekdayIndex,
                                  index: rangeIndex,
                                  isStartTime: false,
                                ),
                                onRemoveTimeRange: (rangeIndex) =>
                                    _removeTimeRange(
                                      weekdayIndex: weekdayIndex,
                                      rangeIndex: rangeIndex,
                                    ),
                              ),
                            );
                          }),
                        if (_scheduleErrorMessage != null) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5),
                              ),
                            ),
                            child: Text(
                              _scheduleErrorMessage!,
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 12,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
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
                                fontFamily: 'Roboto',
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
                            child: const Text(
                              'Salvar',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
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
        fontFamily: 'Roboto',
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
              fontFamily: 'Roboto',
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
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          height: 1.50,
          letterSpacing: 0.72,
        ),
      ),
    );
  }
}

class _WeekdayScheduleSection extends StatelessWidget {
  final String title;
  final String shortLabel;
  final List<_ScheduleTimeRange> ranges;
  final VoidCallback onAddTimeRange;
  final ValueChanged<int> onPickStartTime;
  final ValueChanged<int> onPickEndTime;
  final ValueChanged<int> onRemoveTimeRange;

  const _WeekdayScheduleSection({
    required this.title,
    required this.shortLabel,
    required this.ranges,
    required this.onAddTimeRange,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onRemoveTimeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  shortLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1B1B20),
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...ranges.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ScheduleTimeRow(
                range: entry.value,
                canDelete: ranges.length > 1,
                onStartTap: () => onPickStartTime(entry.key),
                onEndTap: () => onPickEndTime(entry.key),
                onDelete: () => onRemoveTimeRange(entry.key),
              ),
            );
          }),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onAddTimeRange,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar horário para este dia'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: Color(0x7F514EB6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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
              fontFamily: 'Roboto',
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
            fontFamily: 'Roboto',
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
