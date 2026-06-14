import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme_colors.dart';
import '../../../models/discipline.dart';
import '../../../models/subject_event.dart';
import '../inputs/date_picker_field.dart';

class ScheduleEventDialogResult {
  final String title;
  final SubjectEventType type;
  final DateTime eventDate;
  final String description;
  final String? disciplineId;
  final String disciplineName;

  const ScheduleEventDialogResult({
    required this.title,
    required this.type,
    required this.eventDate,
    required this.description,
    required this.disciplineId,
    required this.disciplineName,
  });
}

class ScheduleEventDialog extends StatefulWidget {
  final List<Discipline> disciplines;
  final DateTime initialDate;

  const ScheduleEventDialog({
    super.key,
    required this.disciplines,
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

    final discipline = _selectedDisciplineId == _noDisciplineValue
        ? null
        : _selectedDiscipline();

    Navigator.of(context).pop(
      ScheduleEventDialogResult(
        title: _titleController.text.trim(),
        type: _selectedType,
        eventDate: parseBrazilianDate(_dateController.text)!,
        description: _descriptionController.text.trim(),
        disciplineId: discipline?.id,
        disciplineName: discipline?.name ?? '',
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

  Discipline? _selectedDiscipline() {
    for (final discipline in widget.disciplines) {
      if (discipline.id == _selectedDisciplineId) return discipline;
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
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF6B7280),
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
                              setState(() => _selectedDisciplineId = value);
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
                            initialDate: _futureOrToday(widget.initialDate),
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
                              backgroundColor: AppColors.primary,
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
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 15,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: _fieldBorder(),
      enabledBorder: _fieldBorder(),
      focusedBorder: _fieldBorder(color: AppColors.primary),
      errorBorder: _fieldBorder(color: Colors.red),
      focusedErrorBorder: _fieldBorder(color: Colors.red),
    );
  }

  OutlineInputBorder _fieldBorder({Color color = const Color(0xFFE2E4F0)}) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF464552),
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
