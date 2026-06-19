part of 'subject_details_page.dart';

class _AssessmentDialogResult {
  final String title;
  final String dateLabel;
  final double grade;
  final double weight;

  const _AssessmentDialogResult({
    required this.title,
    required this.dateLabel,
    required this.grade,
    required this.weight,
  });
}

class _AssessmentDialog extends StatefulWidget {
  final Assessment? initialAssessment;

  const _AssessmentDialog({this.initialAssessment});

  @override
  State<_AssessmentDialog> createState() => _AssessmentDialogState();
}

class _AssessmentDialogState extends State<_AssessmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _gradeController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialAssessment = widget.initialAssessment;
    if (initialAssessment != null) {
      _titleController.text = initialAssessment.title;
      _dateController.text = initialAssessment.dateLabel;
      _gradeController.text = initialAssessment.grade.toString();
      _weightController.text = initialAssessment.weight.toString();
    } else {
      _weightController.text = '1.0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _gradeController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _AssessmentDialogResult(
        title: _titleController.text.trim(),
        dateLabel: _dateController.text.trim(),
        grade: _parseGrade(_gradeController.text),
        weight:
            double.tryParse(
              _weightController.text.trim().replaceAll(',', '.'),
            ) ??
            1.0,
      ),
    );
  }

  String? _validateDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    return parseBrazilianDate(text) == null ? 'Informe uma data válida.' : null;
  }

  String? _validateGrade(String? value) {
    final grade = _tryParseGrade(value ?? '');
    if (grade == null) return 'Informe uma nota.';
    if (grade < 0 || grade > 10) return 'Use uma nota entre 0 e 10.';

    return null;
  }

  String? _validateWeight(String? value) {
    final normalized = value?.trim().replaceAll(',', '.') ?? '';
    if (normalized.isEmpty) return 'Informe o peso.';
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) return 'O peso deve ser maior que 0.';
    return null;
  }

  double _parseGrade(String value) {
    return _tryParseGrade(value) ?? 0;
  }

  double? _tryParseGrade(String value) {
    final normalizedValue = value.trim().replaceAll(',', '.');
    if (normalizedValue.isEmpty) return null;

    return double.tryParse(normalizedValue);
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
                          widget.initialAssessment != null
                              ? 'Editar nota'
                              : 'Nova nota',
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DialogField(
                        label: 'Título',
                        child: TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(hintText: 'Ex: Prova 1'),
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
                        label: 'Data',
                        child: AppDatePickerField(
                          controller: _dateController,
                          decoration: _inputDecoration(hintText: 'dd/mm/yyyy'),
                          helpText: 'Escolher data da nota',
                          validator: _validateDate,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DialogField(
                        label: 'Nota',
                        child: TextFormField(
                          controller: _gradeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9,.]'),
                            ),
                          ],
                          decoration: _inputDecoration(hintText: 'Ex: 8.5'),
                          validator: _validateGrade,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DialogField(
                        label: 'Peso',
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9,.]'),
                            ),
                          ],
                          decoration: _inputDecoration(hintText: 'Ex: 1.0'),
                          validator: _validateWeight,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
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
}

class SubjectEventDialogResult {
  final String title;
  final SubjectEventType type;
  final DateTime eventDate;
  final int? startTimeMinutes;
  final int? endTimeMinutes;
  final List<String> topicIds;
  final String description;

  const SubjectEventDialogResult({
    required this.title,
    required this.type,
    required this.eventDate,
    this.startTimeMinutes,
    this.endTimeMinutes,
    this.topicIds = const [],
    required this.description,
  });
}

class SubjectEventDialog extends StatefulWidget {
  final SubjectEvent? initialEvent;

  const SubjectEventDialog({super.key, this.initialEvent});

  @override
  State<SubjectEventDialog> createState() => _SubjectEventDialogState();
}

class _SubjectEventDialogState extends State<SubjectEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  SubjectEventType _selectedType = SubjectEventType.exam;
  bool _hasTimeRange = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);
  final Set<String> _selectedTopicIds = {};
  String? _timeErrorMessage;

  @override
  void initState() {
    super.initState();
    final initialEvent = widget.initialEvent;
    if (initialEvent != null) {
      _titleController.text = initialEvent.title;
      _dateController.text = initialEvent.displayDateLabel;
      _descriptionController.text = initialEvent.description;
      _selectedType = initialEvent.type;
      _selectedTopicIds.addAll(initialEvent.topicIds);

      if (initialEvent.hasTimeRange) {
        _hasTimeRange = true;
        _startTime = timeOfDayFromMinutes(initialEvent.startTimeMinutes!);
        _endTime = timeOfDayFromMinutes(initialEvent.endTimeMinutes!);
      }
    }
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

    Navigator.of(context).pop(
      SubjectEventDialogResult(
        title: _titleController.text.trim(),
        type: _selectedType,
        eventDate: parseBrazilianDate(_dateController.text)!,
        startTimeMinutes: _hasTimeRange ? timeOfDayToMinutes(_startTime) : null,
        endTimeMinutes: _hasTimeRange ? timeOfDayToMinutes(_endTime) : null,
        topicIds: _selectedTopicIds.toList(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  String? _validateDate(String? value) {
    final parsed = parseBrazilianDate(value ?? '');
    if (parsed == null) return 'Informe uma data válida.';

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (parsed.isBefore(todayOnly)) {
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
                            widget.initialEvent != null
                                ? 'Editar evento'
                                : 'Novo evento',
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
                              hintText: 'Ex: Prova final',
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
                          label: 'Tipo',
                          child: DropdownButtonFormField<SubjectEventType>(
                            initialValue: _selectedType,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF6B7280),
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
                        const SizedBox(height: 16),
                        _DialogField(
                          label: 'Data',
                          child: AppDatePickerField(
                            controller: _dateController,
                            decoration: _inputDecoration(
                              hintText: 'dd/mm/yyyy',
                            ),
                            firstDate: DateTime.now(),
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
                              foregroundColor: Colors.white,
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
}

class SubjectNoteDialogResult {
  final String title;
  final String content;

  const SubjectNoteDialogResult({required this.title, required this.content});
}

class SubjectNoteDialog extends StatefulWidget {
  final SubjectNote? initialNote;

  const SubjectNoteDialog({super.key, this.initialNote});

  @override
  State<SubjectNoteDialog> createState() => _SubjectNoteDialogState();
}

class _SubjectNoteDialogState extends State<SubjectNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialNote != null) {
      _titleController.text = widget.initialNote!.title;
      _contentController.text = widget.initialNote!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      SubjectNoteDialogResult(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      ),
    );
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
                            widget.initialNote != null
                                ? 'Editar anotação'
                                : 'Nova anotação',
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
                              hintText: 'Ex: Dúvidas da aula',
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
                          label: 'Anotação',
                          child: TextFormField(
                            controller: _contentController,
                            minLines: 5,
                            maxLines: 7,
                            textInputAction: TextInputAction.newline,
                            decoration:
                                _inputDecoration(
                                  hintText:
                                      'Escreva um resumo, dúvida ou lembrete.',
                                ).copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                            validator: (value) {
                              if ((value?.trim() ?? '').isEmpty) {
                                return 'Escreva a anotação.';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: Colors.white,
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
}

class _StudySessionDialogResult {
  final DateTime studiedAt;
  final int durationMinutes;
  final List<String> topicIds;
  final String notes;

  const _StudySessionDialogResult({
    required this.studiedAt,
    required this.durationMinutes,
    required this.topicIds,
    required this.notes,
  });
}

class _StudySessionDialog extends StatefulWidget {
  final List<StudyTopic> topics;

  const _StudySessionDialog({required this.topics});

  @override
  State<_StudySessionDialog> createState() => _StudySessionDialogState();
}

class _StudySessionDialogState extends State<_StudySessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(
    text: formatBrazilianDate(DateTime.now()),
  );
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  final Set<String> _selectedTopicIds = {};

  @override
  void dispose() {
    _dateController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _StudySessionDialogResult(
        studiedAt: parseBrazilianDate(_dateController.text)!,
        durationMinutes: int.tryParse(_durationController.text.trim()) ?? 0,
        topicIds: _selectedTopicIds.toList(),
        notes: _notesController.text.trim(),
      ),
    );
  }

  String? _validateDate(String? value) {
    final parsed = parseBrazilianDate(value ?? '');
    if (parsed == null) return 'Informe uma data válida.';

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (parsed.isAfter(todayOnly)) return 'Use hoje ou uma data anterior.';

    return null;
  }

  String? _validateDuration(String? value) {
    final minutes = int.tryParse(value?.trim() ?? '');
    if (minutes == null || minutes <= 0) {
      return 'Informe a duração em minutos.';
    }

    return null;
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
    final topics = widget.topics;

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
                            'Registrar estudo',
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DialogField(
                          label: 'Data',
                          child: AppDatePickerField(
                            controller: _dateController,
                            decoration: _inputDecoration(
                              hintText: 'dd/mm/yyyy',
                            ),
                            lastDate: DateTime.now(),
                            helpText: 'Escolher data de estudo',
                            validator: _validateDate,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DialogField(
                          label: 'Duração',
                          child: TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration(
                              hintText: 'Minutos estudados',
                            ),
                            validator: _validateDuration,
                          ),
                        ),
                        if (topics.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _DialogField(
                            label: 'Assuntos vistos',
                            child: AppSurface.soft(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: topics.map((topic) {
                                  final selected = _selectedTopicIds.contains(
                                    topic.id,
                                  );

                                  return CheckboxListTile(
                                    value: selected,
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: Text(
                                      topic.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onChanged: (value) =>
                                        _toggleTopic(topic.id, value ?? false),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _DialogField(
                          label: 'Observações',
                          child: TextFormField(
                            controller: _notesController,
                            minLines: 3,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                            decoration:
                                _inputDecoration(
                                  hintText: 'O que avançou nesta sessão?',
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
}

class _StudyTopicDialogResult {
  final String title;

  const _StudyTopicDialogResult({required this.title});
}

class _StudyTopicDialog extends StatefulWidget {
  const _StudyTopicDialog();

  @override
  State<_StudyTopicDialog> createState() => _StudyTopicDialogState();
}

class _StudyTopicDialogState extends State<_StudyTopicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(
      context,
    ).pop(_StudyTopicDialogResult(title: _titleController.text.trim()));
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
                          'Novo assunto',
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DialogField(
                        label: 'Assunto',
                        child: TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Ex: Funções de 1º grau',
                            filled: true,
                            fillColor: colors.defaultFieldBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colors.outline),
                            ),
                          ),
                          validator: (value) {
                            if ((value?.trim() ?? '').isEmpty) {
                              return 'Informe o assunto.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
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
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final Widget child;

  const _DialogField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.appColors.textMedium,
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
