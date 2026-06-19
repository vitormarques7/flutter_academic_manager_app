import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';
import '../../../models/discipline.dart';
import '../../../models/study_topic.dart';
import '../../../models/subject_event.dart';
import '../inputs/date_picker_field.dart';
import '../inputs/time_range_picker_field.dart';

class ScheduleEventDialogResult {
  final String title;
  final SubjectEventType type;
  final DateTime eventDate;
  final int? startTimeMinutes;
  final int? endTimeMinutes;
  final String description;
  final String? disciplineId;
  final String disciplineName;
  final List<String> topicIds;

  const ScheduleEventDialogResult({
    required this.title,
    required this.type,
    required this.eventDate,
    this.startTimeMinutes,
    this.endTimeMinutes,
    required this.description,
    required this.disciplineId,
    required this.disciplineName,
    this.topicIds = const [],
  });
}

class ScheduleEventDialog extends StatefulWidget {
  final List<Discipline> disciplines;
  final List<StudyTopic> topics;
  final DateTime initialDate;

  const ScheduleEventDialog({
    super.key,
    required this.disciplines,
    this.topics = const [],
    required this.initialDate,
  });

  @override
  State<ScheduleEventDialog> createState() => _ScheduleEventDialogState();
}

class _ScheduleEventDialogState extends State<ScheduleEventDialog> {
  static const _noDisciplineValue = '__none__';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  SubjectEventType _selectedType = SubjectEventType.exam;
  String _selectedDisciplineId = _noDisciplineValue;
  bool _hasTimeRange = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);
  final Set<String> _selectedTopicIds = {};
  String? _timeErrorMessage;

  @override
  void initState() {
    super.initState();
    _dateController.text = formatBrazilianDate(
      _futureOrToday(widget.initialDate),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final timeRangeError = _validateTimeRange();
    if (timeRangeError != null) {
      setState(() => _timeErrorMessage = timeRangeError);
      return;
    }

    final discipline = _selectedDisciplineId == _noDisciplineValue
        ? null
        : _selectedDiscipline();

    Navigator.of(context).pop(
      ScheduleEventDialogResult(
        title: _titleController.text.trim(),
        type: _selectedType,
        eventDate: parseBrazilianDate(_dateController.text)!,
        startTimeMinutes: _hasTimeRange ? timeOfDayToMinutes(_startTime) : null,
        endTimeMinutes: _hasTimeRange ? timeOfDayToMinutes(_endTime) : null,
        description: _descriptionController.text.trim(),
        disciplineId: discipline?.id,
        disciplineName: discipline?.name ?? '',
        topicIds: _selectedType == SubjectEventType.revision
            ? _selectedTopicIds.toList()
            : const [],
      ),
    );
  }

  String? _validateDate(String? value) {
    final parsed = parseBrazilianDate(value ?? '');
    if (parsed == null) return 'Informe uma data válida.';

    final today = _dateOnly(DateTime.now());
    if (parsed.isBefore(today)) {
      return 'Use hoje ou uma data futura.';
    }

    return null;
  }

  String? _validateTimeRange() {
    if (!_hasTimeRange) return null;

    final startMinutes = timeOfDayToMinutes(_startTime);
    final endMinutes = timeOfDayToMinutes(_endTime);

    if (endMinutes <= startMinutes) {
      return 'O horário final deve ser depois do inicial.';
    }

    return null;
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final selectedTime = await showAppTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      if (isStartTime) {
        _startTime = selectedTime;
      } else {
        _endTime = selectedTime;
      }
      _timeErrorMessage = null;
    });
  }

  Discipline? _selectedDiscipline() {
    for (final discipline in widget.disciplines) {
      if (discipline.id == _selectedDisciplineId) return discipline;
    }

    return null;
  }

  List<StudyTopic> _topicsForSelectedDiscipline() {
    final selectedDiscipline = _selectedDiscipline();
    if (selectedDiscipline == null) return const [];

    return widget.topics.where((topic) {
      final topicDisciplineId = topic.disciplineId?.trim();
      if (topicDisciplineId != null && topicDisciplineId.isNotEmpty) {
        return topicDisciplineId == selectedDiscipline.id;
      }

      return topic.disciplineName.trim().toLowerCase() ==
          selectedDiscipline.name.trim().toLowerCase();
    }).toList();
  }

  void _toggleTopic(String topicId, bool selected) {
    setState(() {
      if (selected) {
        _selectedTopicIds.add(topicId);
      } else {
        _selectedTopicIds.remove(topicId);
      }
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
          child: Form(
            key: _formKey,
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
                            'Novo evento',
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
                            color: colors.textMedium,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DialogField(
                          label: 'Título',
                          child: TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'Ex: Palestra ou prova',
                            ),
                            validator: (value) {
                              if ((value?.trim() ?? '').isEmpty) {
                                return 'Informe o título.';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DialogField(
                          label: 'Disciplina',
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedDisciplineId,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: colors.textSubtle,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Disciplina',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: _noDisciplineValue,
                                child: Text('Sem Disciplina'),
                              ),
                              ...widget.disciplines.map((discipline) {
                                return DropdownMenuItem(
                                  value: discipline.id,
                                  child: Text(
                                    discipline.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedDisciplineId = value;
                                final availableTopicIds =
                                    _topicsForSelectedDiscipline()
                                        .map((topic) => topic.id)
                                        .toSet();
                                _selectedTopicIds.removeWhere(
                                  (topicId) =>
                                      !availableTopicIds.contains(topicId),
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DialogField(
                          label: 'Tipo',
                          child: DropdownButtonFormField<SubjectEventType>(
                            initialValue: _selectedType,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: colors.textSubtle,
                            ),
                            decoration: _inputDecoration(hintText: 'Tipo'),
                            items: SubjectEventType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              );
                            }).toList(),
                            onChanged: (type) {
                              if (type == null) return;
                              setState(() => _selectedType = type);
                            },
                          ),
                        ),
                        if (_selectedType == SubjectEventType.revision &&
                            _topicsForSelectedDiscipline().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _DialogField(
                            label: 'Assuntos',
                            child: _RevisionTopicsSelector(
                              topics: _topicsForSelectedDiscipline(),
                              selectedTopicIds: _selectedTopicIds,
                              onChanged: _toggleTopic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _DialogField(
                          label: 'Data',
                          child: AppDatePickerField(
                            controller: _dateController,
                            decoration: _inputDecoration(
                              hintText: 'dd/mm/yyyy',
                            ),
                            firstDate: DateTime.now(),
                            initialDate: _futureOrToday(widget.initialDate),
                            helpText: 'Escolher data do evento',
                            validator: _validateDate,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DialogField(
                          label: 'Horário',
                          child: OptionalTimeRangeField(
                            hasTimeRange: _hasTimeRange,
                            startTime: _startTime,
                            endTime: _endTime,
                            errorText: _timeErrorMessage,
                            onHasTimeRangeChanged: (value) {
                              setState(() {
                                _hasTimeRange = value;
                                _timeErrorMessage = null;
                              });
                            },
                            onStartTap: () => _pickTime(isStartTime: true),
                            onEndTap: () => _pickTime(isStartTime: false),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DialogField(
                          label: 'Descrição',
                          child: TextFormField(
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                            decoration:
                                _inputDecoration(
                                  hintText: 'Local, assunto ou observações.',
                                ).copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 46,
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
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    final colors = context.appColors;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colors.textMuted,
        fontSize: 15,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: colors.defaultFieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: _fieldBorder(color: colors.outline),
      enabledBorder: _fieldBorder(color: colors.outline),
      focusedBorder: _fieldBorder(color: colors.primary),
      errorBorder: _fieldBorder(color: colors.danger),
      focusedErrorBorder: _fieldBorder(color: colors.danger),
    );
  }

  OutlineInputBorder _fieldBorder({required Color color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
  }

  static DateTime _futureOrToday(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final normalizedDate = _dateOnly(date);

    return normalizedDate.isBefore(today) ? today : normalizedDate;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final Widget child;

  const _DialogField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textMedium,
            fontSize: 12,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _RevisionTopicsSelector extends StatelessWidget {
  final List<StudyTopic> topics;
  final Set<String> selectedTopicIds;
  final void Function(String topicId, bool selected) onChanged;

  const _RevisionTopicsSelector({
    required this.topics,
    required this.selectedTopicIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: topics.map((topic) {
          final selected = selectedTopicIds.contains(topic.id);

          return CheckboxListTile(
            value: selected,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: colors.primary,
            title: Text(
              topic.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textDark,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
            onChanged: (value) => onChanged(topic.id, value ?? false),
          );
        }).toList(),
      ),
    );
  }
}
