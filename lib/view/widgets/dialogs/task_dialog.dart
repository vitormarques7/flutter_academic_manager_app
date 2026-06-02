import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/app_colors.dart';

class TaskDialogResult {
  final String title;
  final String subject;
  final String deadline;
  final String visualPriority;

  const TaskDialogResult({
    required this.title,
    required this.subject,
    required this.deadline,
    required this.visualPriority,
  });
}

class TaskDialog extends StatefulWidget {
  final List<String> subjects;
  final TaskDialogResult? initialTask;
  final Future<void> Function(TaskDialogResult task) onSubmit;

  const TaskDialog({
    super.key,
    required this.subjects,
    required this.onSubmit,
    this.initialTask,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _deadlineController;
  late String? _selectedSubject;
  late String _selectedVisualPriority;
  bool _isSaving = false;
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
    _selectedSubject = initialTask?.subject;
    _selectedVisualPriority = initialTask?.visualPriority ?? 'Trabalho';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final task = TaskDialogResult(
      title: _titleController.text.trim(),
      subject: _selectedSubject!,
      deadline: _deadlineController.text.trim(),
      visualPriority: _selectedVisualPriority,
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

  String? _validateDeadline(String? value) {
    final text = value?.trim() ?? '';
    final parts = text.split('/');

    if (text.isEmpty) return null;
    if (parts.length != 3) return 'Use o formato dd/mm/yyyy.';

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'Use apenas números na data.';
    }

    final parsed = DateTime(year, month, day);
    final isValidDate =
        parsed.day == day && parsed.month == month && parsed.year == year;

    if (!isValidDate) return 'Informe uma data válida.';

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
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.33,
                              letterSpacing: -0.36,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isSaving
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
                            enabled: !_isSaving,
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
                            initialValue: _selectedSubject,
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
                                    value: subject,
                                    child: Text(subject),
                                  ),
                                )
                                .toList(),
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() => _selectedSubject = value);
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
                          child: TextFormField(
                            controller: _deadlineController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _DateInputFormatter(),
                            ],
                            decoration: _inputDecoration(
                              hintText: 'dd/mm/yyyy',
                            ),
                            enabled: !_isSaving,
                            validator: _validateDeadline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _FieldLabel('PRIORIDADE VISUAL'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PriorityOption(
                                label: 'Trabalho',
                                icon: Icons.assignment_outlined,
                                isSelected:
                                    _selectedVisualPriority == 'Trabalho',
                                onTap: _isSaving
                                    ? null
                                    : () {
                                        setState(
                                          () => _selectedVisualPriority =
                                              'Trabalho',
                                        );
                                      },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _PriorityOption(
                                label: 'Prova',
                                icon: Icons.edit_square,
                                isSelected: _selectedVisualPriority == 'Prova',
                                onTap: _isSaving
                                    ? null
                                    : () {
                                        setState(
                                          () =>
                                              _selectedVisualPriority = 'Prova',
                                        );
                                      },
                              ),
                            ),
                          ],
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
                                fontFamily: 'Inter',
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
                            onPressed: _isSaving
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
                            onPressed: _isSaving ? null : _save,
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
                                : const Row(
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
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        height: 1.50,
        letterSpacing: 0.72,
      ),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PriorityOption({
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
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
              Icon(icon, color: const Color(0xFF464552), size: 26),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF464552),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
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

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();

    for (var i = 0; i < limited.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
