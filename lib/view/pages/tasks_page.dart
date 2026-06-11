import 'package:flutter/material.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../models/academic_task.dart';
import '../../models/discipline.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_design_tokens.dart';
import '../widgets/common/app_surface.dart';
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
  final DisciplineRepository _disciplineRepository = DisciplineRepository();
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  late Future<String?> _activeStudyCycleIdFuture;

  @override
  void initState() {
    super.initState();
    _activeStudyCycleIdFuture = _userProfileRepository
        .resolveActiveStudyCycleId();
  }

  List<AcademicTask> _filterTasks(List<AcademicTask> tasks) {
    return tasks.where(_selectedFilter.matches).toList();
  }

  List<String> _subjectNamesFromDisciplines(List<Discipline> disciplines) {
    return disciplines
        .map((discipline) => discipline.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  List<String> _subjectsForDialog({
    required List<String> subjects,
    AcademicTask? task,
  }) {
    final mergedSubjects = [...subjects];
    final currentSubject = task?.subject.trim();

    if (currentSubject != null &&
        currentSubject.isNotEmpty &&
        !mergedSubjects.contains(currentSubject)) {
      mergedSubjects.add(currentSubject);
    }

    return mergedSubjects;
  }

  Future<void> _openTaskDialog({
    AcademicTask? task,
    required List<String> subjects,
    required bool isLoadingSubjects,
    required bool hasSubjectsError,
  }) async {
    if (isLoadingSubjects && task == null) {
      _showError('Aguarde carregar suas disciplinas.');
      return;
    }

    if (hasSubjectsError && task == null) {
      _showError('Não foi possível carregar suas disciplinas.');
      return;
    }

    final dialogSubjects = _subjectsForDialog(subjects: subjects, task: task);
    if (dialogSubjects.isEmpty) {
      _showError('Cadastre uma disciplina antes de criar tarefas.');
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => TaskDialog(
        subjects: dialogSubjects,
        initialTask: task == null
            ? null
            : TaskDialogResult(
                title: task.title,
                subject: task.subject,
                deadline: task.deadline,
                visualPriority: task.visualPriority,
                description: task.description,
              ),
        onSubmit: (result) {
          final input = TaskInput(
            title: result.title,
            subject: result.subject,
            deadline: result.deadline,
            visualPriority: result.visualPriority,
            description: result.description,
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

                    FutureBuilder<String?>(
                      future: _activeStudyCycleIdFuture,
                      builder: (context, activeCycleSnapshot) {
                        if (activeCycleSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _TasksLoadingState();
                        }

                        if (activeCycleSnapshot.hasError) {
                          return const EmptyStateCard(
                            message:
                                'Não foi possível carregar seu ciclo de estudos.',
                          );
                        }

                        return StreamBuilder<List<Discipline>>(
                          stream: _disciplineRepository.watchDisciplines(
                            studyCycleId: activeCycleSnapshot.data,
                          ),
                          builder: (context, disciplineSnapshot) {
                            final isLoadingSubjects =
                                disciplineSnapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !disciplineSnapshot.hasData;
                            final hasSubjectsError =
                                disciplineSnapshot.hasError;
                            final subjects = hasSubjectsError
                                ? const <String>[]
                                : _subjectNamesFromDisciplines(
                                    disciplineSnapshot.data ?? const [],
                                  );

                            return StreamBuilder<List<AcademicTask>>(
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
                                final timelineStats =
                                    _TaskTimelineStats.fromTasks(allTasks);

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
                                        setState(
                                          () => _selectedFilter = filter,
                                        );
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
                                      _GroupedTaskList(
                                        tasks: tasks,
                                        itemBuilder: (task) => TaskCard(
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
                                          onTap: () => _openTaskDialog(
                                            task: task,
                                            subjects: subjects,
                                            isLoadingSubjects:
                                                isLoadingSubjects,
                                            hasSubjectsError: hasSubjectsError,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
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
              child: FutureBuilder<String?>(
                future: _activeStudyCycleIdFuture,
                builder: (context, activeCycleSnapshot) {
                  return StreamBuilder<List<Discipline>>(
                    stream:
                        activeCycleSnapshot.connectionState ==
                                ConnectionState.done &&
                            !activeCycleSnapshot.hasError
                        ? _disciplineRepository.watchDisciplines(
                            studyCycleId: activeCycleSnapshot.data,
                          )
                        : null,
                    builder: (context, disciplineSnapshot) {
                      final isLoadingSubjects =
                          activeCycleSnapshot.connectionState ==
                              ConnectionState.waiting ||
                          (disciplineSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !disciplineSnapshot.hasData);
                      final hasSubjectsError =
                          activeCycleSnapshot.hasError ||
                          disciplineSnapshot.hasError;
                      final subjects = hasSubjectsError
                          ? const <String>[]
                          : _subjectNamesFromDisciplines(
                              disciplineSnapshot.data ?? const [],
                            );

                      return FloatingAddButton(
                        onTap: () => _openTaskDialog(
                          subjects: subjects,
                          isLoadingSubjects: isLoadingSubjects,
                          hasSubjectsError: hasSubjectsError,
                        ),
                      );
                    },
                  );
                },
              ),
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

    return AppSurface(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      gradient: AppGradients.softSurface,
      border: Border.all(color: AppColors.outline),
      shadows: AppShadows.card,
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
                    fontFamily: 'Roboto',
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
                    fontFamily: 'Roboto',
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
                    fontFamily: 'Roboto',
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

class _GroupedTaskList extends StatelessWidget {
  final List<AcademicTask> tasks;
  final Widget Function(AcademicTask task) itemBuilder;

  const _GroupedTaskList({required this.tasks, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    final groups = _TaskTimelineGroup.fromTasks(tasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              group.label,
              style: const TextStyle(
                color: AppColors.textMedium,
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ...group.tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: itemBuilder(task),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _TaskTimelineGroup {
  final String label;
  final List<AcademicTask> tasks;

  const _TaskTimelineGroup({required this.label, required this.tasks});

  static List<_TaskTimelineGroup> fromTasks(List<AcademicTask> tasks) {
    final today = _dateOnly(DateTime.now());
    final overdue = <AcademicTask>[];
    final todayTasks = <AcademicTask>[];
    final nextTasks = <AcademicTask>[];
    final noDate = <AcademicTask>[];
    final completed = <AcademicTask>[];

    for (final task in tasks) {
      if (task.isChecked) {
        completed.add(task);
        continue;
      }

      final deadline = _parseBrazilianDate(task.deadline);
      if (deadline == null) {
        noDate.add(task);
      } else if (deadline.isBefore(today)) {
        overdue.add(task);
      } else if (deadline == today) {
        todayTasks.add(task);
      } else {
        nextTasks.add(task);
      }
    }

    int byDeadline(AcademicTask a, AcademicTask b) {
      final aDate = _parseBrazilianDate(a.deadline);
      final bDate = _parseBrazilianDate(b.deadline);
      if (aDate == null && bDate == null) return a.title.compareTo(b.title);
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      final dateComparison = aDate.compareTo(bDate);
      if (dateComparison != 0) return dateComparison;
      return a.title.compareTo(b.title);
    }

    overdue.sort(byDeadline);
    todayTasks.sort(byDeadline);
    nextTasks.sort(byDeadline);
    noDate.sort((a, b) => a.title.compareTo(b.title));
    completed.sort((a, b) => a.title.compareTo(b.title));

    return [
      if (overdue.isNotEmpty)
        _TaskTimelineGroup(label: 'ATRASADAS', tasks: overdue),
      if (todayTasks.isNotEmpty)
        _TaskTimelineGroup(label: 'HOJE', tasks: todayTasks),
      if (nextTasks.isNotEmpty)
        _TaskTimelineGroup(label: 'PRÓXIMOS PRAZOS', tasks: nextTasks),
      if (noDate.isNotEmpty)
        _TaskTimelineGroup(label: 'SEM PRAZO', tasks: noDate),
      if (completed.isNotEmpty)
        _TaskTimelineGroup(label: 'CONCLUÍDAS', tasks: completed),
    ];
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
              fontFamily: 'Roboto',
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
    return AppSurface(
      height: 46,
      padding: const EdgeInsets.all(4),
      color: AppColors.surface,
      border: Border.all(color: AppColors.outline),
      shadows: AppShadows.subtle,
      borderRadius: AppRadius.md,
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
                    fontFamily: 'Roboto',
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
