import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';
import '../../../services/setup/academic_setup_service.dart';
import '../dialogs/subject_dialog.dart';

class DisciplineSetupList extends StatefulWidget {
  final ValueChanged<List<AcademicSetupDisciplineDraft>>? onChanged;
  final bool isIndependent;

  const DisciplineSetupList({
    super.key,
    this.onChanged,
    this.isIndependent = false,
  });

  @override
  State<DisciplineSetupList> createState() => _DisciplineSetupListState();
}

class _DisciplineSetupListState extends State<DisciplineSetupList> {
  final List<AcademicSetupDisciplineDraft> _disciplines = [];

  Future<void> _openSubjectDialog() async {
    if (widget.isIndependent) {
      await _openIndependentDisciplineDialog();
      return;
    }

    final result = await showDialog<SubjectDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => SubjectDialog(
        unavailableScheduleEntries: _unavailableScheduleEntries(),
      ),
    );

    if (result == null || !mounted) return;

    final disciplineName = result.name.trim();
    if (disciplineName.isEmpty) return;

    setState(() {
      _disciplines.add(
        AcademicSetupDisciplineDraft(
          name: disciplineName,
          teacher: result.teacher,
          workload: result.workload,
          maxAbsences: result.maxAbsences,
          schedules: result.schedule.map((entry) {
            return AcademicSetupScheduleDraft(
              weekdays: [entry.weekdayIndex],
              startTimeMinutes: entry.startTimeMinutes,
              endTimeMinutes: entry.endTimeMinutes,
            );
          }).toList(),
        ),
      );
      _emitChanges();
    });
  }

  Future<void> _openIndependentDisciplineDialog() async {
    final result = await showDialog<IndependentDisciplineDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const IndependentDisciplineDialog(),
    );

    if (result == null || !mounted) return;

    final disciplineName = result.name.trim();
    if (disciplineName.isEmpty) return;

    setState(() {
      _disciplines.add(
        AcademicSetupDisciplineDraft(
          name: disciplineName,
          initialTopics: result.topics,
        ),
      );
      _emitChanges();
    });
  }

  void _removeDiscipline(int index) {
    if (index >= _disciplines.length) return;

    setState(() {
      _disciplines.removeAt(index);
      _emitChanges();
    });
  }

  void _emitChanges() {
    widget.onChanged?.call(List.unmodifiable(_disciplines));
  }

  List<SubjectScheduleEntry> _unavailableScheduleEntries() {
    return _disciplines.expand((discipline) {
      return discipline.schedules.expand((schedule) {
        return schedule.weekdays.map((weekdayIndex) {
          return SubjectScheduleEntry(
            weekdayIndex: weekdayIndex,
            startTime: _formatMinutes(schedule.startTimeMinutes),
            endTime: _formatMinutes(schedule.endTimeMinutes),
          );
        });
      });
    }).toList();
  }

  String _formatMinutes(int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_disciplines.isEmpty)
          const _EmptyDisciplineSetupState()
        else
          ..._disciplines.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SetupDisciplineTile(
                discipline: entry.value,
                isIndependent: widget.isIndependent,
                onDelete: () => _removeDiscipline(entry.key),
              ),
            );
          }),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _openSubjectDialog,
            icon: const Icon(Icons.add, size: 22),
            label: const Text('Adicionar disciplina'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDisciplineSetupState extends StatelessWidget {
  const _EmptyDisciplineSetupState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Text(
        'Nenhuma disciplina adicionada ainda.',
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 13,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SetupDisciplineTile extends StatelessWidget {
  final AcademicSetupDisciplineDraft discipline;
  final bool isIndependent;
  final VoidCallback onDelete;

  const _SetupDisciplineTile({
    required this.discipline,
    required this.isIndependent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheduleSummary = _scheduleSummary();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: colors.surfaceTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discipline.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isIndependent ? _topicSummary() : scheduleSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover disciplina',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  String _scheduleSummary() {
    if (discipline.schedules.isEmpty) return 'Sem horário definido';

    final days = discipline.schedules
        .expand((schedule) => schedule.weekdays)
        .toSet()
        .map(_weekdayShortName)
        .join(', ');

    return '$days • ${discipline.schedules.length} ${discipline.schedules.length == 1 ? 'horário' : 'horários'}';
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

  String _topicSummary() {
    if (discipline.initialTopics.isEmpty) return 'Sem assuntos iniciais';

    return '${discipline.initialTopics.length} ${discipline.initialTopics.length == 1 ? 'assunto' : 'assuntos'} a ver';
  }
}

class IndependentDisciplineDialogResult {
  final String name;
  final List<String> topics;

  const IndependentDisciplineDialogResult({
    required this.name,
    required this.topics,
  });
}

class IndependentDisciplineDialog extends StatefulWidget {
  const IndependentDisciplineDialog({super.key});

  @override
  State<IndependentDisciplineDialog> createState() =>
      _IndependentDisciplineDialogState();
}

class _IndependentDisciplineDialogState
    extends State<IndependentDisciplineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _topicsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final topics = _topicsController.text
        .split('\n')
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty)
        .toSet()
        .toList();

    Navigator.of(context).pop(
      IndependentDisciplineDialogResult(
        name: _nameController.text.trim(),
        topics: topics,
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
            borderRadius: BorderRadius.circular(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Nova Disciplina',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 24,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 1.33,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fechar',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icon(
                            Icons.close,
                            color: colors.textMuted,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: colors.divider),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DialogField(
                          label: 'DISCIPLINA',
                          child: TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'Ex: Matemática',
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
                        _DialogField(
                          label: 'ASSUNTOS A VER',
                          child: TextFormField(
                            controller: _topicsController,
                            minLines: 5,
                            maxLines: 8,
                            textInputAction: TextInputAction.newline,
                            decoration:
                                _inputDecoration(
                                  hintText: 'Digite um assunto por linha',
                                ).copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  alignLabelWithHint: true,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: colors.divider),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.textOnPrimary,
                              elevation: 4,
                              shadowColor: colors.primary.withValues(
                                alpha: 0.28,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'Salvar',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: colors.textMedium),
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
    final colors = context.appColors;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colors.textMuted,
        fontSize: 16,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: colors.defaultFieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
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
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: TextStyle(
              color: colors.textMedium,
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
