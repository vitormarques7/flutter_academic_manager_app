import 'package:flutter/material.dart';
import '../../models/academic_task.dart';
import '../../repositories/subject_repository.dart';
import '../../repositories/task_repository.dart';
import '../../config/theme/app_colors.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/section_label.dart';
import '../widgets/selectors/task_filter_chip.dart';
import '../widgets/cards/swipeable_task_card.dart';
import '../widgets/common/floating_add_button.dart';
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

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => TaskDialog(
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
    // TODO: implementar dropdown de filtro (Todas, Pendentes, Concluídas)
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Todas', 'Pendentes', 'Concluídas'].map((option) {
          return ListTile(
            title: Text(option),
            selected: _selectedFilter == option,
            selectedColor: const Color(0xFF514EB6),
            onTap: () {
              setState(() => _selectedFilter = option);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
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
                          return const _TasksStateMessage(
                            message:
                                'Não foi possível carregar suas tarefas agora.',
                          );
                        }

                        final tasks = _filterTasks(snapshot.data ?? []);

                        if (tasks.isEmpty) {
                          return const _TasksStateMessage(
                            message: 'Nenhuma tarefa encontrada.',
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
                                onChanged: (value) {
                                  _updateTaskCompletion(task, value ?? false);
                                },
                                onTap: () => _openTaskDialog(task: task),
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

            // Botão flutuante
            Positioned(
              right: 24,
              bottom: 16,
              child: FloatingAddButton(onTap: () => _openTaskDialog()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksStateMessage extends StatelessWidget {
  final String message;

  const _TasksStateMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF464552),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
