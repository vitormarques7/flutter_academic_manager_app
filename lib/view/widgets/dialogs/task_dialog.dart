import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../inputs/date_picker_field.dart';

class TaskDialogResult {
  final String title;
  final String? disciplineId;
  final String subject;
  final String deadline;
  final String visualPriority;
  final String description;

  const TaskDialogResult({
    required this.title,
    this.disciplineId,
    required this.subject,
    required this.deadline,
    required this.visualPriority,
    this.description = '',
  });
}

class TaskDialogSubject {
  final String? id;
  final String name;

  const TaskDialogSubject({required this.name, this.id});

  String get value => id ?? 'legacy:${name.trim().toLowerCase()}';
}

class TaskDialog extends StatefulWidget {
  final List<TaskDialogSubject> subjects;
  final TaskDialogResult? initialTask;
  final Future<void> Function(TaskDialogResult task) onSubmit;
  final Future<void> Function()? onDelete;

  const TaskDialog({
    super.key,
    required this.subjects,
    required this.onSubmit,
    this.onDelete,
    this.initialTask,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  static const _taskTypes = [
    _TaskType(label: 'Trabalho', icon: Icons.assignment_outlined),
    _TaskType(label: 'Prova', icon: Icons.edit_square),
    _TaskType(label: 'Estudo', icon: Icons.school_outlined),
    _TaskType(label: 'Seminário', icon: Icons.co_present_outlined),
    _TaskType(label: 'Leitura', icon: Icons.menu_book_outlined),
    _TaskType(label: 'Pesquisa', icon: Icons.search_outlined),
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _deadlineController;
  late final TextEditingController _descriptionController;
  late String? _selectedSubjectValue;
  late String _selectedVisualPriority;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _errorMessage;

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final initialTask = widget.initialTask;
    _titleController = TextEditingController(text: initialTask?.title ?? '');
    _deadlineController = TextEditingController(
      text: initialTask?.deadline ?? '',
    );
    _descriptionController = TextEditingController(
      text: initialTask?.description ?? '',
    );
    _selectedSubjectValue = _initialSubjectValue(initialTask);
    _selectedVisualPriority = initialTask?.visualPriority ?? 'Trabalho';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _deadlineController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final selectedSubject = _selectedSubject();
    if (selectedSubject == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final task = TaskDialogResult(
      title: _titleController.text.trim(),
      disciplineId: selectedSubject.id,
      subject: selectedSubject.name,
      deadline: _deadlineController.text.trim(),
      visualPriority: _selectedVisualPriority,
      description: _descriptionController.text.trim(),
    );

    try {
      await widget.onSubmit(task);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isSaving = false;
      });
    }
  }

  String? _initialSubjectValue(TaskDialogResult? initialTask) {
    if (initialTask == null) return null;

    final disciplineId = initialTask.disciplineId?.trim();
    if (disciplineId != null && disciplineId.isNotEmpty) {
      for (final subject in widget.subjects) {
        if (subject.id == disciplineId) return subject.value;
      }
    }

    final subjectName = initialTask.subject.trim().toLowerCase();
    if (subjectName.isEmpty) return null;

    for (final subject in widget.subjects) {
      if (subject.name.trim().toLowerCase() == subjectName) {
        return subject.value;
      }
    }

    return null;
  }

  TaskDialogSubject? _selectedSubject() {
    final selectedValue = _selectedSubjectValue;
    if (selectedValue == null) return null;

    for (final subject in widget.subjects) {
      if (subject.value == selectedValue) return subject;
    }

    return null;
  }

  Future<void> _confirmDelete() async {
    final onDelete = widget.onDelete;
    if (onDelete == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir tarefa?'),
          content: const Text(
            'Essa ação remove a tarefa permanentemente. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await onDelete();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isDeleting = false;
      });
    }
  }

  String? _validateDeadline(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return null;
    final parsed = parseBrazilianDate(text);
    if (parsed == null) return 'Informe uma data válida.';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(parsed.year, parsed.month, parsed.day);

    if (deadline.isBefore(today)) {
      return 'Informe uma data de hoje em diante.';
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
                        Expanded(
                          child: Text(
                            _isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
                            style: const TextStyle(
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
                          onPressed: _isSaving || _isDeleting
                              ? null
                              : () => Navigator.of(context).maybePop(),
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
                          label: 'TÍTULO',
                          child: TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'Ex: Entrega de Trabalho de IA',
                            ),
                            enabled: !_isSaving && !_isDeleting,
                            validator: (value) {
                              if ((value?.trim() ?? '').isEmpty) {
                                return 'Informe o título.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        _LabeledField(
                          label: 'DISCIPLINA',
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSubjectValue,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF6B7280),
                              size: 32,
                            ),
                            decoration: _inputDecoration(),
                            hint: const Text('Selecione a disciplina'),
                            items: widget.subjects
                                .map(
                                  (subject) => DropdownMenuItem(
                                    value: subject.value,
                                    child: Text(
                                      subject.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: _isSaving || _isDeleting
                                ? null
                                : (value) {
                                    setState(
                                      () => _selectedSubjectValue = value,
                                    );
                                  },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecione uma disciplina.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        _LabeledField(
                          label: 'DATA / PRAZO',
                          child: AppDatePickerField(
                            controller: _deadlineController,
                            decoration: _inputDecoration(
                              hintText: 'dd/mm/yyyy',
                            ),
                            firstDate: DateTime.now(),
                            helpText: 'Escolher prazo',
                            enabled: !_isSaving && !_isDeleting,
                            validator: _validateDeadline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _FieldLabel('Tipo'),
                        const SizedBox(height: 10),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final optionWidth = (constraints.maxWidth - 16) / 3;

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _taskTypes.map((taskType) {
                                return SizedBox(
                                  width: optionWidth,
                                  child: _TypeOption(
                                    label: taskType.label,
                                    icon: taskType.icon,
                                    isSelected:
                                        _selectedVisualPriority ==
                                        taskType.label,
                                    onTap: _isSaving || _isDeleting
                                        ? null
                                        : () {
                                            setState(
                                              () => _selectedVisualPriority =
                                                  taskType.label,
                                            );
                                          },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _LabeledField(
                          label: 'Descrição',
                          child: TextFormField(
                            controller: _descriptionController,
                            minLines: 4,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                            decoration:
                                _inputDecoration(
                                  hintText: 'Digite algo...',
                                ).copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  alignLabelWithHint: true,
                                ),
                            enabled: !_isSaving && !_isDeleting,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E4F0)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: Column(
                      children: [
                        if (_errorMessage != null) ...[
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
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 13,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: _isSaving || _isDeleting
                                ? null
                                : () => Navigator.of(context).maybePop(),
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
                            onPressed: _isSaving || _isDeleting ? null : _save,
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
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
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
                        if (_isEditing && widget.onDelete != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: TextButton.icon(
                              onPressed: _isSaving || _isDeleting
                                  ? null
                                  : _confirmDelete,
                              icon: _isDeleting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.red,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.delete_outline, size: 22),
                              label: const Text('Excluir tarefa'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ],
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
          child: _FieldLabel(label),
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
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF464552),
        fontSize: 12,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w700,
        height: 1.50,
        letterSpacing: 0.72,
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEDEAF7) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2E4F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF464552), size: 22),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF464552),
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskType {
  final String label;
  final IconData icon;

  const _TaskType({required this.label, required this.icon});
}
