import 'package:flutter/material.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../models/academic_task.dart';
import '../../repositories/task_repository.dart';
import '../../config/theme/app_colors.dart';
import '../widgets/common/page_header.dart';
import '../widgets/cards/task_card.dart';
import '../widgets/common/floating_add_button.dart';
import '../widgets/dialogs/task_dialog.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/list_section_header.dart';

enum _TaskFilter {
  pending('Pendentes'),
  all('Todas'),
  completed('Concluídas');

  final String label;

  const _TaskFilter(this.label);

  bool matches(AcademicTask task) {
    return switch (this) {
      _TaskFilter.pending => !task.isChecked,
      _TaskFilter.completed => task.isChecked,
      _TaskFilter.all => true,
    };
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  _TaskFilter _selectedFilter = _TaskFilter.all;
  final TaskRepository _taskRepository = TaskRepository();

  final List<String> _subjects = const [
    'Programação',
    'Cálculo I',
    'Banco de Dados',
    'Inteligência Artificial',
  ];

  List<AcademicTask> _filterTasks(List<AcademicTask> tasks) {
    return tasks.where(_selectedFilter.matches).toList();
  }

  Future<void> _openTaskDialog({AcademicTask? task}) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => TaskDialog(
        subjects: _subjects,
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
        onDelete: task == null
            ? null
            : () => _taskRepository.deleteTask(task.id),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: const AppScrollBehavior(),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(title: 'Suas Tarefas'),

                    const SizedBox(height: 24),

                    StreamBuilder<List<AcademicTask>>(
                      stream: _taskRepository.watchTasks(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const _TasksLoadingState();
                        }

                        if (snapshot.hasError) {
                          return const EmptyStateCard(
                            message:
                                'Não foi possível carregar suas tarefas agora.',
                          );
                        }

                        final allTasks = snapshot.data ?? [];
                        final tasks = _filterTasks(allTasks);
                        final pendingCount = allTasks
                            .where((task) => !task.isChecked)
                            .length;
                        final completedCount = allTasks
                            .where((task) => task.isChecked)
                            .length;
                        final timelineStats = _TaskTimelineStats.fromTasks(
                          allTasks,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TasksOverview(
                              total: allTasks.length,
                              pending: pendingCount,
                              completed: completedCount,
                              timelineStats: timelineStats,
                            ),
                            const SizedBox(height: 22),
                            ListSectionHeader(
                              label: 'LISTA DE TAREFAS',
                              count: tasks.length,
                            ),
                            const SizedBox(height: 12),
                            _TaskFilterTabs(
                              selectedFilter: _selectedFilter,
                              onSelected: (filter) {
                                setState(() => _selectedFilter = filter);
                              },
                            ),
                            const SizedBox(height: 18),
                            if (tasks.isEmpty)
                              EmptyStateCard(
                                message: allTasks.isEmpty
                                    ? 'Nenhuma tarefa criada ainda.'
                                    : 'Nenhuma tarefa nesse filtro.',
                                icon: allTasks.isEmpty
                                    ? Icons.assignment_outlined
                                    : Icons.filter_alt_off_outlined,
                              )
                            else
                              Column(
                                children: tasks.map((task) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: TaskCard(
                                      title: task.title,
                                      subject: task.subject,
                                      deadline: task.deadlineLabel,
                                      visualPriority: task.visualPriority,
                                      isChecked: task.isChecked,
                                      onChanged: (value) {
                                        _updateTaskCompletion(
                                          task,
                                          value ?? false,
                                        );
                                      },
                                      onTap: () => _openTaskDialog(task: task),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
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

class _TasksOverview extends StatelessWidget {
  final int total;
  final int pending;
  final int completed;
  final _TaskTimelineStats timelineStats;

  const _TasksOverview({
    required this.total,
    required this.pending,
    required this.completed,
    required this.timelineStats,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final progressPercent = (progress * 100).round();
    final focusText = _focusText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E4F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22587DBD),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    color: Color(0xFF191820),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  focusText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF191820),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  total == 0
                      ? 'Crie sua primeira tarefa para montar seu radar.'
                      : '$completed de $total ${_plural(total, 'tarefa', 'tarefas')} concluídas',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF464552),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.28,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TaskInsightPill(
                      label: 'Pendentes',
                      value: '$pending',
                      icon: Icons.pending_actions_outlined,
                    ),
                    _TaskInsightPill(
                      label: 'Hoje',
                      value: '${timelineStats.dueToday}',
                      icon: Icons.today_outlined,
                    ),
                    _TaskInsightPill(
                      label: 'Atrasadas',
                      value: '${timelineStats.overdue}',
                      icon: Icons.warning_amber_rounded,
                      isAlert: timelineStats.overdue > 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _focusText() {
    if (total == 0) return 'Seu radar está limpo';
    if (pending == 0) return 'Tudo concluído por aqui';
    if (timelineStats.overdue > 0) {
      return '${timelineStats.overdue} ${_plural(timelineStats.overdue, 'tarefa atrasada', 'tarefas atrasadas')}';
    }
    if (timelineStats.dueToday > 0) {
      return '${timelineStats.dueToday} ${_plural(timelineStats.dueToday, 'tarefa para hoje', 'tarefas para hoje')}';
    }
    final nextDeadline = timelineStats.nextDeadlineLabel;
    if (nextDeadline != null) return 'Próximo prazo: $nextDeadline';
    if (timelineStats.noDeadline > 0) return 'Há tarefas sem prazo definido';

    return 'Sem pendências no radar';
  }
}

class _TaskInsightPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isAlert;

  const _TaskInsightPill({
    required this.label,
    required this.value,
    required this.icon,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isAlert ? const Color(0xFF9A3412) : AppColors.primary;
    final background = isAlert
        ? const Color(0xFFFFF3E8)
        : Colors.white.withValues(alpha: 0.76);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAlert ? const Color(0xFFFFD6AD) : const Color(0xFFE2E4F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 14),
          const SizedBox(width: 5),
          Text(
            '$value $label',
            style: TextStyle(
              color: isAlert
                  ? const Color(0xFF7C2D12)
                  : const Color(0xFF464552),
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFilterTabs extends StatelessWidget {
  final _TaskFilter selectedFilter;
  final ValueChanged<_TaskFilter> onSelected;

  const _TaskFilterTabs({
    required this.selectedFilter,
    required this.onSelected,
  });

  static const _filters = [
    _TaskFilter.pending,
    _TaskFilter.completed,
    _TaskFilter.all,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x33587DBD),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF464552),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TaskTimelineStats {
  final int dueToday;
  final int overdue;
  final int noDeadline;
  final DateTime? nextDeadline;

  const _TaskTimelineStats({
    required this.dueToday,
    required this.overdue,
    required this.noDeadline,
    required this.nextDeadline,
  });

  factory _TaskTimelineStats.fromTasks(List<AcademicTask> tasks) {
    final today = _dateOnly(DateTime.now());
    var dueToday = 0;
    var overdue = 0;
    var noDeadline = 0;
    DateTime? nextDeadline;

    for (final task in tasks.where((task) => !task.isChecked)) {
      final deadline = _parseBrazilianDate(task.deadline);

      if (deadline == null) {
        noDeadline++;
        continue;
      }

      if (deadline.isBefore(today)) {
        overdue++;
        continue;
      }

      final daysUntil = deadline.difference(today).inDays;
      if (daysUntil == 0) dueToday++;

      if (nextDeadline == null || deadline.isBefore(nextDeadline)) {
        nextDeadline = deadline;
      }
    }

    return _TaskTimelineStats(
      dueToday: dueToday,
      overdue: overdue,
      noDeadline: noDeadline,
      nextDeadline: nextDeadline,
    );
  }

  String? get nextDeadlineLabel {
    final deadline = nextDeadline;
    if (deadline == null) return null;

    final day = deadline.day.toString().padLeft(2, '0');
    final month = deadline.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime? _parseBrazilianDate(String value) {
  final parts = value.trim().split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) return null;

  final date = DateTime(year, month, day);
  if (date.day != day || date.month != month || date.year != year) {
    return null;
  }

  return _dateOnly(date);
}

String _plural(int count, String singular, String plural) {
  return count == 1 ? singular : plural;
}

class _TasksLoadingState extends StatelessWidget {
  const _TasksLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 32),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
