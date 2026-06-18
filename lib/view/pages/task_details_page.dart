import 'package:flutter/material.dart';

import '../../config/theme/app_theme_colors.dart';
import '../../models/academic_task.dart';
import '../../repositories/task_repository.dart';
import '../widgets/dialogs/task_dialog.dart';

class TaskDetailsPage extends StatefulWidget {
  final AcademicTask task;
  final List<TaskDialogSubject> subjects;
  final String? activeStudyCycleId;

  const TaskDetailsPage({
    super.key,
    required this.task,
    required this.subjects,
    this.activeStudyCycleId,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final TaskRepository _taskRepository = TaskRepository();
  late AcademicTask _currentTask;
  bool _isDeleting = false;
  bool _isSaving = false;
  bool _isUpdatingCompletion = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  IconData get _priorityIcon {
    return switch (_currentTask.visualPriority) {
      'Prova' => Icons.edit_square,
      'Estudo' => Icons.school_outlined,
      'Seminário' => Icons.co_present_outlined,
      'Leitura' => Icons.menu_book_outlined,
      'Pesquisa' => Icons.search_outlined,
      _ => Icons.assignment_outlined,
    };
  }

  Color _accentColor(AppThemeColors colors) {
    if (_currentTask.isChecked) return colors.success;

    return switch (_currentTask.visualPriority) {
      'Prova' => colors.danger,
      'Seminário' => colors.warning,
      'Pesquisa' => colors.primary,
      _ => colors.primary,
    };
  }

  Future<void> _openEditDialog() async {
    if (widget.subjects.isEmpty) {
      _showError('Não foi possível carregar disciplinas para editar.');
      return;
    }

    TaskDialogResult? savedResult;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => TaskDialog(
        subjects: widget.subjects,
        initialTask: TaskDialogResult(
          title: _currentTask.title,
          disciplineId: _currentTask.disciplineId,
          subject: _currentTask.subject,
          deadline: _currentTask.deadline,
          visualPriority: _currentTask.visualPriority,
          description: _currentTask.description,
        ),
        onSubmit: (result) async {
          final input = TaskInput(
            title: result.title,
            disciplineId: result.disciplineId,
            subject: result.subject,
            deadline: result.deadline,
            visualPriority: result.visualPriority,
            description: result.description,
            studyCycleId:
                _currentTask.studyCycleId ?? widget.activeStudyCycleId,
          );

          await _taskRepository.updateTask(id: _currentTask.id, input: input);
          savedResult = result;
        },
      ),
    );

    if (savedResult == null || !mounted) return;

    setState(() {
      _currentTask = _currentTask.copyWith(
        title: savedResult!.title,
        disciplineId: savedResult!.disciplineId,
        subject: savedResult!.subject,
        deadline: savedResult!.deadline,
        visualPriority: savedResult!.visualPriority,
        description: savedResult!.description,
        studyCycleId: _currentTask.studyCycleId ?? widget.activeStudyCycleId,
        updatedAt: DateTime.now(),
      );
    });

    _showSuccess('Tarefa atualizada com sucesso.');
  }

  Future<void> _toggleCompletion() async {
    final nextValue = !_currentTask.isChecked;

    setState(() => _isUpdatingCompletion = true);

    try {
      await _taskRepository.updateCompletion(
        id: _currentTask.id,
        isChecked: nextValue,
      );

      if (!mounted) return;

      setState(() {
        _isUpdatingCompletion = false;
        _currentTask = _currentTask.copyWith(
          isChecked: nextValue,
          updatedAt: DateTime.now(),
        );
      });
    } on TaskRepositoryException catch (error) {
      if (!mounted) return;
      setState(() => _isUpdatingCompletion = false);
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUpdatingCompletion = false);
      _showError('Não foi possível atualizar a tarefa. Tente novamente.');
    }
  }

  Future<void> _confirmDelete() async {
    final colors = context.appColors;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir tarefa?'),
          content: Text('Isso removerá "${_currentTask.title}".'),
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

    setState(() => _isDeleting = true);

    try {
      await _taskRepository.deleteTask(_currentTask.id);
      if (!mounted) return;
      _showSuccess('Tarefa excluída.');
      Navigator.of(context).pop();
    } on TaskRepositoryException catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showError('Não foi possível excluir a tarefa. Tente novamente.');
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

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
    final accentColor = _accentColor(colors);
    final disciplineLabel = _currentTask.subject.trim().isEmpty
        ? 'Sem disciplina'
        : _currentTask.subject.trim();
    final statusLabel = _currentTask.isChecked ? 'Concluída' : 'Pendente';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: accentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Tarefa',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: _isDeleting || _isSaving || _isUpdatingCompletion
                ? null
                : () async {
                    setState(() => _isSaving = true);
                    await _openEditDialog();
                    if (mounted) setState(() => _isSaving = false);
                  },
            tooltip: 'Editar tarefa',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _EntranceSlideFade(
              beginOffset: const Offset(0, -28),
              fade: false,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: colors.subtleShadows,
                ),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _priorityIcon,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _currentTask.visualPriority.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _currentTask.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      disciplineLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _EntranceSlideFade(
                beginOffset: const Offset(0, 32),
                start: 0.14,
                duration: const Duration(milliseconds: 880),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DetailsCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(
                              icon: Icons.description_outlined,
                              title: 'Descrição',
                              accentColor: accentColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentTask.description.isEmpty
                                  ? 'Nenhuma descrição cadastrada para esta tarefa.'
                                  : _currentTask.description,
                              style: TextStyle(
                                color: _currentTask.description.isEmpty
                                    ? colors.textMuted
                                    : colors.textMedium,
                                fontSize: 15,
                                fontFamily: 'Roboto',
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailsCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(
                              icon: Icons.info_outline_rounded,
                              title: 'Detalhes da Tarefa',
                              accentColor: accentColor,
                            ),
                            const SizedBox(height: 16),
                            _DetailRow(
                              icon: Icons.calendar_today_rounded,
                              title: 'Prazo',
                              value: _currentTask.deadlineLabel,
                              iconColor: accentColor,
                            ),
                            Divider(height: 24, color: colors.divider),
                            _DetailRow(
                              icon: _priorityIcon,
                              title: 'Tipo',
                              value: _currentTask.visualPriority,
                              iconColor: accentColor,
                            ),
                            Divider(height: 24, color: colors.divider),
                            _DetailRow(
                              icon: Icons.menu_book_rounded,
                              title: 'Disciplina',
                              value: disciplineLabel,
                              iconColor: accentColor,
                            ),
                            Divider(height: 24, color: colors.divider),
                            _DetailRow(
                              icon: _currentTask.isChecked
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.pending_actions_outlined,
                              title: 'Status',
                              value: statusLabel,
                              iconColor: accentColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _isDeleting || _isSaving
                              ? null
                              : _toggleCompletion,
                          icon: _isUpdatingCompletion
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.textOnPrimary,
                                  ),
                                )
                              : Icon(
                                  _currentTask.isChecked
                                      ? Icons.radio_button_unchecked_rounded
                                      : Icons.check_circle_outline_rounded,
                                ),
                          label: Text(
                            _currentTask.isChecked
                                ? 'Marcar como pendente'
                                : 'Marcar como concluída',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: colors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: IconButton(
                          icon: _isDeleting
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.textSubtle,
                                  ),
                                )
                              : Icon(
                                  Icons.delete_outline_rounded,
                                  color: colors.textSubtle,
                                  size: 28,
                                ),
                          onPressed:
                              _isDeleting || _isSaving || _isUpdatingCompletion
                              ? null
                              : _confirmDelete,
                          tooltip: 'Excluir tarefa',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Widget child;

  const _DetailsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outline),
        boxShadow: colors.subtleShadows,
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Icon(icon, color: accentColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: colors.textDark,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.textSubtle,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: colors.textDark,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EntranceSlideFade extends StatelessWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final double start;
  final bool fade;

  const _EntranceSlideFade({
    required this.child,
    required this.beginOffset,
    this.duration = const Duration(milliseconds: 760),
    this.start = 0,
    this.fade = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.linear,
      builder: (context, value, child) {
        final progress = Interval(
          start,
          1,
          curve: Curves.easeOutQuart,
        ).transform(value);

        final translatedChild = Transform.translate(
          offset: Offset.lerp(beginOffset, Offset.zero, progress)!,
          child: child,
        );

        if (!fade) return translatedChild;

        return Opacity(opacity: progress, child: translatedChild);
      },
      child: child,
    );
  }
}
