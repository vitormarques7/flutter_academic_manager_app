import 'package:flutter/material.dart';
import '../../models/academic_task.dart';
import '../../repositories/subject_repository.dart';
import '../../repositories/task_repository.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme_extension.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/section_label.dart';
import '../widgets/selectors/task_filter_chip.dart';
import '../widgets/cards/swipeable_task_card.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/floating_add_button.dart';
import '../widgets/common/hero_form_sheet.dart';
import '../shell/main_shell_scope.dart';
import '../widgets/dialogs/task_dialog.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedFilter = 'Todas';
  final TaskRepository _taskRepository = TaskRepository();
  final SubjectRepository _subjectRepository = SubjectRepository();

  List<AcademicTask> _filterTasks(List<AcademicTask> tasks) {
    return tasks.where((task) {
      final isChecked = task.isChecked;

      if (_selectedFilter == 'Pendentes') return !isChecked;
      if (_selectedFilter == 'Concluídas') return isChecked;

      return true;
    }).toList();
  }

  Future<void> _openTaskDialog({AcademicTask? task}) async {
    List<String> subjects = [];

    try {
      final savedSubjects = await _subjectRepository.watchSubjects().first;
      subjects = savedSubjects.map((subject) => subject.name).toList();
    } on SubjectRepositoryException catch (error) {
      _showError(error.message);
      return;
    } catch (_) {
      _showError('Não foi possível carregar suas disciplinas.');
      return;
    }

    if (!mounted) return;

    if (subjects.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cadastre uma disciplina'),
          content: const Text(
            'Para criar uma tarefa, você precisa ter ao menos uma disciplina cadastrada.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                MainShellScope.maybeOf(context)?.selectTab(1);
              },
              child: const Text('Ir para Disciplinas'),
            ),
          ],
        ),
      );
      return;
    }

    await showHeroFormDialog<void>(
      context: context,
      child: TaskDialog(
        subjects: subjects,
        initialTask: task == null
            ? null
            : TaskDialogResult(
                title: task.title,
                subject: task.subject,
                deadline: task.deadline,
                visualPriority: task.visualPriority,
              ),
        onSubmit: (result) {
          final input = TaskInput(
            title: result.title,
            subject: result.subject,
            deadline: result.deadline,
            visualPriority: result.visualPriority,
          );

          if (task == null) {
            return _taskRepository.createTask(input);
          }

          return _taskRepository.updateTask(id: task.id, input: input);
        },
      ),
    );
  }

  Future<bool> _confirmDeleteTask(AcademicTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir tarefa'),
          content: Text(
            'Deseja excluir "${task.title}"? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _deleteTask(AcademicTask task) async {
    try {
      await _taskRepository.deleteTask(task.id);
    } on TaskRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível excluir a tarefa. Tente novamente.');
    }
  }

  Future<void> _updateTaskCompletion(AcademicTask task, bool value) async {
    try {
      await _taskRepository.updateCompletion(id: task.id, isChecked: value);
    } on TaskRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível atualizar a tarefa. Tente novamente.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _onFilterTap() {
    final appTheme = context.appTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: appTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Todas', 'Pendentes', 'Concluídas'].map((option) {
          return ListTile(
            title: Text(
              option,
              style: TextStyle(color: appTheme.textPrimary),
            ),
            selected: _selectedFilter == option,
            selectedColor: AppColors.primary,
            iconColor: AppColors.primary,
            onTap: () {
              setState(() => _selectedFilter = option);
              Navigator.pop(sheetContext);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(title: 'Suas Tarefas'),

                    const SizedBox(height: 24),

                    TaskFilterChip(label: _selectedFilter, onTap: _onFilterTap),

                    const SizedBox(height: 20),

                    const SectionLabel(label: 'LISTA DE TAREFAS'),

                    const SizedBox(height: 12),

                    StreamBuilder<List<AcademicTask>>(
                      stream: _taskRepository.watchTasks(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const EmptyStateCard(
                            icon: Icons.cloud_off_outlined,
                            title: 'Erro ao carregar tarefas',
                            subtitle:
                                'Não foi possível carregar suas tarefas agora.',
                          );
                        }

                        final allTasks = snapshot.data ?? [];
                        final tasks = _filterTasks(allTasks);
                        final hasActiveFilter = _selectedFilter != 'Todas';

                        if (tasks.isEmpty) {
                          return EmptyStateCard(
                            icon: hasActiveFilter
                                ? Icons.filter_alt_off_outlined
                                : Icons.assignment_outlined,
                            title: hasActiveFilter
                                ? 'Nenhuma tarefa neste filtro'
                                : 'Nenhuma tarefa cadastrada',
                            subtitle: hasActiveFilter
                                ? 'Altere o filtro acima para ver outras tarefas.'
                                : 'Toque no botão + para criar sua primeira tarefa.',
                            actionLabel:
                                hasActiveFilter ? null : 'Criar tarefa',
                            onAction: hasActiveFilter
                                ? null
                                : () => _openTaskDialog(),
                          );
                        }

                        return Column(
                          children: tasks.map((task) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: SwipeableTaskCard(
                                dismissKey: task.id,
                                title: task.title,
                                subject: task.subject,
                                deadline: task.deadlineLabel,
                                isChecked: task.isChecked,
                                onConfirmDelete: () => _confirmDeleteTask(task),
                                onDismissed: () => _deleteTask(task),
                                onChanged: task.isChecked
                                    ? null
                                    : (value) {
                                        _updateTaskCompletion(
                                          task,
                                          value ?? false,
                                        );
                                      },
                                onTap: task.isChecked
                                    ? null
                                    : () => _openTaskDialog(task: task),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 16,
            child: FloatingAddButton(onTap: () => _openTaskDialog()),
          ),
        ],
      ),
    );
  }
}
