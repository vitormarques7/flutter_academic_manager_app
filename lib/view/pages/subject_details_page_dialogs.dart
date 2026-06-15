part of 'subject_details_page.dart';

class _AssessmentDialogResult {
  final String title;
  final String dateLabel;
  final double grade;

  const _AssessmentDialogResult({
    required this.title,
    required this.dateLabel,
    required this.grade,
  });
}

class _AssessmentDialog extends StatefulWidget {
  const _AssessmentDialog();

  @override
  State<_AssessmentDialog> createState() => _AssessmentDialogState();
}

class _AssessmentDialogState extends State<_AssessmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _gradeController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _AssessmentDialogResult(
        title: _titleController.text.trim(),
        dateLabel: _dateController.text.trim(),
        grade: _parseGrade(_gradeController.text),
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
                          'Nova nota',
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
  final String description;

  const SubjectEventDialogResult({
    required this.title,
    required this.type,
    required this.eventDate,
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

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _titleController.text = widget.initialEvent!.title;
      _dateController.text = widget.initialEvent!.displayDateLabel;
      _descriptionController.text = widget.initialEvent!.description;
      _selectedType = widget.initialEvent!.type;
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

    Navigator.of(context).pop(
      SubjectEventDialogResult(
        title: _titleController.text.trim(),
        type: _selectedType,
        eventDate: parseBrazilianDate(_dateController.text)!,
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
                            widget.initialEvent != null ? 'Editar evento' : 'Novo evento',
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
                            widget.initialNote != null ? 'Editar anotação' : 'Nova anotação',
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
