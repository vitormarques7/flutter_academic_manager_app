import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';
import '../../../config/theme/app_design_tokens.dart';
import '../../../models/discipline.dart';
import '../../../models/schedule.dart';
import '../common/app_surface.dart';
import '../selectors/weekday_selector.dart';

typedef ScheduleCreateCallback = Future<void> Function(ScheduleInput input);
typedef ScheduleUpdateCallback =
    Future<void> Function(String scheduleId, ScheduleInput input);
typedef ScheduleDeleteCallback = Future<void> Function(String scheduleId);

class ScheduleEditorSheet extends StatefulWidget {
  final String studyCycleId;
  final List<Schedule> schedules;
  final List<Discipline> disciplines;
  final ScheduleCreateCallback onCreate;
  final ScheduleUpdateCallback onUpdate;
  final ScheduleDeleteCallback onDelete;

  const ScheduleEditorSheet({
    super.key,
    required this.studyCycleId,
    required this.schedules,
    required this.disciplines,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ScheduleEditorSheet> createState() => _ScheduleEditorSheetState();
}

class _ScheduleEditorSheetState extends State<ScheduleEditorSheet> {
  bool _isSaving = false;

  List<Schedule> get _sortedSchedules {
    return [...widget.schedules]..sort(Schedule.compareByStartTime);
  }

  Future<void> _openScheduleDialog({Schedule? schedule}) async {
    if (widget.disciplines.isEmpty) {
      _showError('Cadastre uma disciplina antes de editar a grade.');
      return;
    }

    final result = await showDialog<_ScheduleEditorResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => _ScheduleEntryDialog(
        disciplines: widget.disciplines,
        schedules: widget.schedules,
        initialSchedule: schedule,
      ),
    );

    if (result == null || !mounted) return;

    final input = ScheduleInput(
      studyCycleId: widget.studyCycleId,
      disciplineId: result.discipline.id,
      disciplineName: result.discipline.name,
      weekdays: result.weekdays,
      startTimeMinutes: result.startTimeMinutes,
      endTimeMinutes: result.endTimeMinutes,
      colorValue: result.discipline.colorValue,
    );

    setState(() => _isSaving = true);
    try {
      if (schedule == null) {
        await widget.onCreate(input);
        _showSuccess('Horário adicionado.');
      } else {
        await widget.onUpdate(schedule.id, input);
        _showSuccess('Horário atualizado.');
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteSchedule(Schedule schedule) async {
    final colors = context.appColors;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir horário?'),
          content: Text(
            'Isso removerá "${schedule.disciplineName}" da grade neste horário.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: colors.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await widget.onDelete(schedule.id);
      _showSuccess('Horário excluído.');
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showError(String message) {
    final colors = context.appColors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final schedules = _sortedSchedules;

    return SafeArea(
      top: false,
      child: AppSurface.card(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        borderRadius: AppRadius.xl,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Editar grade',
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 22,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: colors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.disciplines.isEmpty)
                const _EditorStatus(
                  icon: Icons.menu_book_outlined,
                  message: 'Cadastre disciplinas para montar sua grade.',
                )
              else ...[
                Flexible(
                  child:
                      schedules.isEmpty
                          ? const _EditorStatus(
                            icon: Icons.calendar_month_outlined,
                            message: 'Nenhum horário cadastrado ainda.',
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            itemCount: schedules.length,
                            separatorBuilder:
                                (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final schedule = schedules[index];
                              return _ScheduleEditorRow(
                                schedule: schedule,
                                discipline: _disciplineForSchedule(schedule),
                                onEdit:
                                    _isSaving
                                        ? null
                                        : () => _openScheduleDialog(
                                          schedule: schedule,
                                        ),
                                onDelete:
                                    _isSaving
                                        ? null
                                        : () => _deleteSchedule(schedule),
                              );
                            },
                          ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _openScheduleDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child:
                        _isSaving
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.textOnPrimary,
                                ),
                              ),
                            )
                            : const Text('Adicionar horário'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Discipline? _disciplineForSchedule(Schedule schedule) {
    final disciplineId = schedule.disciplineId?.trim();
    if (disciplineId != null && disciplineId.isNotEmpty) {
      for (final discipline in widget.disciplines) {
        if (discipline.id == disciplineId) return discipline;
      }
    }

    final scheduleName = schedule.disciplineName.trim().toLowerCase();
    for (final discipline in widget.disciplines) {
      if (discipline.name.trim().toLowerCase() == scheduleName) {
        return discipline;
      }
    }

    return null;
  }
}

class _ScheduleEditorRow extends StatelessWidget {
  final Schedule schedule;
  final Discipline? discipline;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ScheduleEditorRow({
    required this.schedule,
    required this.discipline,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = Color(discipline?.colorValue ?? schedule.colorValue);
    final teacher = discipline?.teacher.trim();

    return AppSurface.soft(
      padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.26)),
            ),
            child: Icon(Icons.menu_book_outlined, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.disciplineName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_weekdaySummary(schedule.weekdays)} • ${schedule.formattedTimeRange}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMedium,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (teacher != null && teacher.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    teacher,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar horário',
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, color: colors.primary),
          ),
          IconButton(
            tooltip: 'Excluir horário',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: colors.danger),
          ),
        ],
      ),
    );
  }
}

class _ScheduleEntryDialog extends StatefulWidget {
  final List<Discipline> disciplines;
  final List<Schedule> schedules;
  final Schedule? initialSchedule;

  const _ScheduleEntryDialog({
    required this.disciplines,
    required this.schedules,
    this.initialSchedule,
  });

  @override
  State<_ScheduleEntryDialog> createState() => _ScheduleEntryDialogState();
}

class _ScheduleEntryDialogState extends State<_ScheduleEntryDialog> {
  late String? _selectedDisciplineId;
  late Set<int> _selectedWeekdays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String? _errorMessage;

  bool get _isEditing => widget.initialSchedule != null;

  @override
  void initState() {
    super.initState();
    final initialSchedule = widget.initialSchedule;
    _selectedDisciplineId = _initialDisciplineId(initialSchedule);
    _selectedWeekdays = {...?initialSchedule?.weekdays};
    _startTime = _timeFromMinutes(initialSchedule?.startTimeMinutes ?? 8 * 60);
    _endTime = _timeFromMinutes(initialSchedule?.endTimeMinutes ?? 10 * 60);
  }

  void _submit() {
    final discipline = _selectedDiscipline();
    if (discipline == null) {
      setState(() => _errorMessage = 'Selecione uma disciplina.');
      return;
    }

    if (_selectedWeekdays.isEmpty) {
      setState(() => _errorMessage = 'Selecione pelo menos um dia.');
      return;
    }

    final startMinutes = _minutesFromTime(_startTime);
    final endMinutes = _minutesFromTime(_endTime);
    if (endMinutes <= startMinutes) {
      setState(
        () => _errorMessage = 'O horário final deve ser depois do inicial.',
      );
      return;
    }

    final conflict = _conflictingSchedule(startMinutes, endMinutes);
    if (conflict != null) {
      setState(() {
        _errorMessage =
            'Já existe ${conflict.disciplineName} em ${_firstConflictDay(conflict)}, '
            'das ${conflict.formattedStartTime} às ${conflict.formattedEndTime}.';
      });
      return;
    }

    Navigator.of(context).pop(
      _ScheduleEditorResult(
        discipline: discipline,
        weekdays: _selectedWeekdays.toList()..sort(),
        startTimeMinutes: startMinutes,
        endTimeMinutes: endMinutes,
      ),
    );
  }

  String? _initialDisciplineId(Schedule? schedule) {
    if (schedule == null) return widget.disciplines.firstOrNull?.id;

    final disciplineId = schedule.disciplineId?.trim();
    if (disciplineId != null && disciplineId.isNotEmpty) {
      for (final discipline in widget.disciplines) {
        if (discipline.id == disciplineId) return discipline.id;
      }
    }

    final scheduleName = schedule.disciplineName.trim().toLowerCase();
    for (final discipline in widget.disciplines) {
      if (discipline.name.trim().toLowerCase() == scheduleName) {
        return discipline.id;
      }
    }

    return widget.disciplines.firstOrNull?.id;
  }

  Discipline? _selectedDiscipline() {
    final selectedId = _selectedDisciplineId;
    if (selectedId == null) return null;

    for (final discipline in widget.disciplines) {
      if (discipline.id == selectedId) return discipline;
    }

    return null;
  }

  Schedule? _conflictingSchedule(int startMinutes, int endMinutes) {
    final initialScheduleId = widget.initialSchedule?.id;

    for (final schedule in widget.schedules) {
      if (schedule.id == initialScheduleId) continue;

      for (final weekday in _selectedWeekdays) {
        final overlaps =
            schedule.occursOnWeekday(weekday) &&
            startMinutes < schedule.endTimeMinutes &&
            endMinutes > schedule.startTimeMinutes;
        if (overlaps) return schedule;
      }
    }

    return null;
  }

  String _firstConflictDay(Schedule schedule) {
    for (final weekday in _selectedWeekdays) {
      if (schedule.occursOnWeekday(weekday)) return _weekdayName(weekday);
    }

    return 'um dos dias selecionados';
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final colors = context.appColors;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: colors.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      if (isStartTime) {
        _startTime = selectedTime;
      } else {
        _endTime = selectedTime;
      }
      _errorMessage = null;
    });
  }

  void _toggleWeekday(int weekdayIndex) {
    setState(() {
      if (!_selectedWeekdays.add(weekdayIndex)) {
        _selectedWeekdays.remove(weekdayIndex);
      }
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 18, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isEditing ? 'Editar horário' : 'Novo horário',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 24,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Fechar',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Icons.close,
                          color: colors.textMuted,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.divider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _DialogLabel('DISCIPLINA'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDisciplineId,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colors.textSubtle,
                        ),
                        decoration: _inputDecoration(context),
                        items: widget.disciplines.map((discipline) {
                          return DropdownMenuItem(
                            value: discipline.id,
                            child: Text(
                              discipline.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDisciplineId = value;
                            _errorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      const _DialogLabel('DIAS'),
                      const SizedBox(height: 10),
                      WeekdaySelector(
                        selectedIndexes: _selectedWeekdays,
                        onChanged: _toggleWeekday,
                      ),
                      const SizedBox(height: 18),
                      const _DialogLabel('HORÁRIO'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeButton(
                              label: _formatTime(_startTime),
                              onTap: () => _pickTime(isStartTime: true),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'até',
                              style: TextStyle(
                                color: colors.textMedium,
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _TimeButton(
                              label: _formatTime(_endTime),
                              onTap: () => _pickTime(isStartTime: false),
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.dangerSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.danger.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: colors.danger,
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
                Divider(height: 1, color: colors.divider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primary,
                            side: BorderSide(color: colors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Salvar'),
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
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final colors = context.appColors;
    return InputDecoration(
      filled: true,
      fillColor: colors.defaultFieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: _fieldBorder(context),
      enabledBorder: _fieldBorder(context),
      focusedBorder: _fieldBorder(context, color: colors.primary),
      errorBorder: _fieldBorder(context, color: colors.danger),
      focusedErrorBorder: _fieldBorder(context, color: colors.danger),
    );
  }

  OutlineInputBorder _fieldBorder(
    BuildContext context, {
    Color? color,
  }) {
    final colors = context.appColors;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color ?? colors.outline),
    );
  }
}

class _ScheduleEditorResult {
  final Discipline discipline;
  final List<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;

  const _ScheduleEditorResult({
    required this.discipline,
    required this.weekdays,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
  });
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.defaultFieldBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: colors.textDark,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogLabel extends StatelessWidget {
  final String label;

  const _DialogLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      label,
      style: TextStyle(
        color: colors.textMedium,
        fontSize: 12,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _EditorStatus extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EditorStatus({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppSurface.soft(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.textDark,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _weekdaySummary(List<int> weekdays) {
  if (weekdays.isEmpty) return 'Sem dias';

  final labels = weekdays.map(_weekdayName).toList();
  if (labels.length == 1) return labels.first;
  if (labels.length == 2) return '${labels.first} e ${labels.last}';

  return '${labels.take(labels.length - 1).join(', ')} e ${labels.last}';
}

String _weekdayName(int weekdayIndex) {
  return switch (weekdayIndex) {
    0 => 'Dom',
    1 => 'Seg',
    2 => 'Ter',
    3 => 'Qua',
    4 => 'Qui',
    5 => 'Sex',
    6 => 'Sáb',
    _ => 'Dia',
  };
}

TimeOfDay _timeFromMinutes(int minutes) {
  final normalizedMinutes = minutes.clamp(0, 1439);
  return TimeOfDay(
    hour: normalizedMinutes ~/ 60,
    minute: normalizedMinutes % 60,
  );
}

int _minutesFromTime(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

String _formatTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
