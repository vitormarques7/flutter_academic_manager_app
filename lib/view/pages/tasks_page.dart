import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../models/academic_task.dart';
import '../../models/discipline.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../config/theme/app_theme_colors.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/common/page_header.dart';
import '../widgets/cards/task_card.dart';
import '../widgets/common/floating_add_button.dart';
import '../widgets/dialogs/task_dialog.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/list_section_header.dart';
import 'task_details_page.dart';

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
  String? _selectedDisciplineId;
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

  List<TaskDialogSubject> _subjectOptionsFromDisciplines(
    List<Discipline> disciplines,
  ) {
    return disciplines
        .where((discipline) => discipline.name.trim().isNotEmpty)
        .map(
          (discipline) => TaskDialogSubject(
            id: discipline.id,
            name: discipline.name.trim(),
          ),
        )
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<TaskDialogSubject> _subjectsForDialog({
    required List<TaskDialogSubject> subjects,
    AcademicTask? task,
  }) {
    final mergedSubjects = [...subjects];
    final currentDisciplineId = task?.disciplineId?.trim();
    final currentSubject = task?.subject.trim();

    final hasCurrentDiscipline =
        currentDisciplineId != null &&
        currentDisciplineId.isNotEmpty &&
        mergedSubjects.any((subject) => subject.id == currentDisciplineId);
    final hasCurrentSubject =
        currentSubject != null &&
        currentSubject.isNotEmpty &&
        mergedSubjects.any(
          (subject) =>
              subject.name.trim().toLowerCase() == currentSubject.toLowerCase(),
        );

    if (!hasCurrentDiscipline &&
        !hasCurrentSubject &&
        currentSubject != null &&
        currentSubject.isNotEmpty) {
      mergedSubjects.add(TaskDialogSubject(name: currentSubject));
    }

    return mergedSubjects;
  }

  Future<void> _openTaskDialog({
    AcademicTask? task,
    required List<TaskDialogSubject> subjects,
    String? activeStudyCycleId,
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
                disciplineId: task.disciplineId,
                subject: task.subject,
                deadline: task.deadline,
                visualPriority: task.visualPriority,
                description: task.description,
              ),
        onSubmit: (result) {
          final input = TaskInput(
            title: result.title,
            disciplineId: result.disciplineId,
            subject: result.subject,
            deadline: result.deadline,
            visualPriority: result.visualPriority,
            description: result.description,
            studyCycleId: task?.studyCycleId ?? activeStudyCycleId,
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

  void _openTaskDetails({
    required AcademicTask task,
    required List<TaskDialogSubject> subjects,
    String? activeStudyCycleId,
  }) {
    Navigator.of(context).push(
      AppRoutes.detailRoute(
        page: TaskDetailsPage(
          task: task,
          subjects: _subjectsForDialog(subjects: subjects, task: task),
          activeStudyCycleId: activeStudyCycleId,
        ),
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

    final colors = context.appColors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
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
                    const PageHeader(title: 'Suas Tarefas', avatarSize: 46),

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
                            icon: Icons.error_outline_rounded,
                            message:
                                'Não foi possível carregar seu ciclo de estudos.',
                          );
                        }

                        return StreamBuilder<List<Discipline>>(
                          stream: _disciplineRepository.watchDisciplines(
                            studyCycleId: activeCycleSnapshot.data,
                          ),
                          builder: (context, disciplineSnapshot) {
                            final hasSubjectsError =
                                disciplineSnapshot.hasError;
                            final disciplines =
                                disciplineSnapshot.data ?? const [];
                            final subjects = hasSubjectsError
                                ? const <TaskDialogSubject>[]
                                : _subjectOptionsFromDisciplines(disciplines);

                            // Clean up selected discipline if it's no longer present
                            if (_selectedDisciplineId != null &&
                                !disciplines.any(
                                  (d) => d.id == _selectedDisciplineId,
                                )) {
                              _selectedDisciplineId = null;
                            }

                            return StreamBuilder<List<AcademicTask>>(
                              stream: _taskRepository.watchTasks(
                                studyCycleId: activeCycleSnapshot.data,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    !snapshot.hasData) {
                                  return const _TasksLoadingState();
                                }

                                if (snapshot.hasError) {
                                  return const EmptyStateCard(
                                    icon: Icons.error_outline_rounded,
                                    message:
                                        'Não foi possível carregar suas tarefas agora.',
                                  );
                                }

                                final allTasks = snapshot.data ?? [];
                                final disciplineTasks =
                                    _selectedDisciplineId == null
                                    ? allTasks
                                    : allTasks
                                          .where(
                                            (t) =>
                                                t.disciplineId ==
                                                _selectedDisciplineId,
                                          )
                                          .toList();

                                final mainListTasks = switch (_selectedFilter) {
                                  _TaskFilter.completed =>
                                    disciplineTasks
                                        .where((t) => t.isChecked)
                                        .toList(),
                                  _TaskFilter.all => disciplineTasks,
                                  _TaskFilter.pending =>
                                    disciplineTasks
                                        .where((t) => !t.isChecked)
                                        .toList(),
                                };

                                final completedTasksList = disciplineTasks
                                    .where((t) => t.isChecked)
                                    .toList();
                                final showCompletedCollapsible =
                                    _selectedFilter == _TaskFilter.pending &&
                                    completedTasksList.isNotEmpty;

                                final timelineStats =
                                    _TaskTimelineStats.fromTasks(
                                      disciplineTasks,
                                    );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (disciplines.isNotEmpty) ...[
                                      _DisciplineFilterSelector(
                                        disciplines: disciplines,
                                        selectedDisciplineId:
                                            _selectedDisciplineId,
                                        onSelected: (id) {
                                          setState(
                                            () => _selectedDisciplineId = id,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                    ],
                                    _TasksOverview(
                                      tasks: disciplineTasks,
                                      timelineStats: timelineStats,
                                    ),
                                    const SizedBox(height: 22),
                                    ListSectionHeader(
                                      label: 'LISTA DE TAREFAS',
                                      count:
                                          mainListTasks.length +
                                          (showCompletedCollapsible
                                              ? completedTasksList.length
                                              : 0),
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
                                    if (mainListTasks.isEmpty &&
                                        !showCompletedCollapsible)
                                      EmptyStateCard(
                                        message: allTasks.isEmpty
                                            ? 'Nenhuma tarefa criada ainda.'
                                            : 'Nenhuma tarefa nesse filtro.',
                                        icon: allTasks.isEmpty
                                            ? Icons.assignment_outlined
                                            : Icons.filter_alt_off_outlined,
                                      )
                                    else ...[
                                      if (mainListTasks.isNotEmpty)
                                        _GroupedTaskList(
                                          tasks: mainListTasks,
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
                                            onTap: () => _openTaskDetails(
                                              task: task,
                                              subjects: subjects,
                                              activeStudyCycleId:
                                                  activeCycleSnapshot.data,
                                            ),
                                          ),
                                        ),
                                      if (showCompletedCollapsible) ...[
                                        const SizedBox(height: 16),
                                        _CompletedTasksCollapseCard(
                                          tasks: completedTasksList,
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
                                            onTap: () => _openTaskDetails(
                                              task: task,
                                              subjects: subjects,
                                              activeStudyCycleId:
                                                  activeCycleSnapshot.data,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
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
                          ? const <TaskDialogSubject>[]
                          : _subjectOptionsFromDisciplines(
                              disciplineSnapshot.data ?? const [],
                            );

                      return FloatingAddButton(
                        onTap: () => _openTaskDialog(
                          subjects: subjects,
                          activeStudyCycleId: activeCycleSnapshot.data,
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
  final List<AcademicTask> tasks;
  final _TaskTimelineStats timelineStats;

  const _TasksOverview({required this.tasks, required this.timelineStats});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = tasks.length;
    final pending = tasks.where((task) => !task.isChecked).length;
    final completed = tasks.where((task) => task.isChecked).length;
    final focusText = _focusText(totalCount: total, pendingCount: pending);
    final radarColor = _radarColor(colors, pending);
    final supportText = _supportText(
      total: total,
      pending: pending,
      completed: completed,
    );

    return AppSurface.soft(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      shadows: colors.cardShadows,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: radarColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: radarColor.withValues(alpha: 0.22)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$pending',
                    maxLines: 1,
                    style: TextStyle(
                      color: radarColor,
                      fontSize: 30,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _plural(pending, 'pendente', 'pendentes'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: radarColor,
                    fontSize: 10,
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
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  supportText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMedium,
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
                      isAlert: timelineStats.dueToday > 0,
                    ),
                    _TaskInsightPill(
                      label: 'Semana',
                      value: '${timelineStats.dueThisWeek}',
                      icon: Icons.date_range_outlined,
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

  String _focusText({required int totalCount, required int pendingCount}) {
    if (totalCount == 0) return 'Seu radar está limpo';
    if (pendingCount == 0) return 'Tudo concluído por aqui';
    if (timelineStats.overdue > 0) {
      return '${timelineStats.overdue} ${_plural(timelineStats.overdue, 'tarefa atrasada', 'tarefas atrasadas')}';
    }
    if (timelineStats.dueToday > 0) {
      return '${timelineStats.dueToday} ${_plural(timelineStats.dueToday, 'tarefa para hoje', 'tarefas para hoje')}';
    }
    if (timelineStats.dueThisWeek > 0) {
      return '${timelineStats.dueThisWeek} ${_plural(timelineStats.dueThisWeek, 'tarefa nos próximos 7 dias', 'tarefas nos próximos 7 dias')}';
    }
    final nextDeadline = timelineStats.nextDeadlineLabel;
    if (nextDeadline != null) return 'Próximo prazo: $nextDeadline';
    if (timelineStats.noDeadline > 0) return 'Há tarefas sem prazo definido';

    return 'Sem pendências no radar';
  }

  String _supportText({
    required int total,
    required int pending,
    required int completed,
  }) {
    if (total == 0) return 'Crie sua primeira tarefa para montar seu radar.';
    if (pending == 0) {
      return '$completed de $total ${_plural(total, 'tarefa', 'tarefas')} concluídas.';
    }

    return '$completed concluídas de $total ${_plural(total, 'tarefa', 'tarefas')} no total.';
  }

  Color _radarColor(AppThemeColors colors, int pending) {
    if (pending == 0 && tasks.isNotEmpty) return colors.success;
    if (timelineStats.overdue > 0) return colors.danger;
    if (timelineStats.dueToday > 0) return colors.warning;

    return colors.primary;
  }
}

class _GroupedTaskList extends StatelessWidget {
  final List<AcademicTask> tasks;
  final Widget Function(AcademicTask task) itemBuilder;

  const _GroupedTaskList({required this.tasks, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final groups = _TaskTimelineGroup.fromTasks(tasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < groups.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              groups[i].label,
              style: TextStyle(
                color: groups[i].label == 'ATRASADAS'
                    ? colors.danger
                    : colors.textMedium,
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ...groups[i].tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: itemBuilder(task),
            ),
          ),
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
    final colors = context.appColors;
    final foreground = isAlert ? colors.warning : colors.primary;
    final background = isAlert
        ? colors.warningSurface
        : colors.surface.withValues(alpha: 0.76);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAlert
              ? colors.warning.withValues(alpha: 0.26)
              : colors.outline,
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
              color: isAlert ? colors.warning : colors.textMedium,
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
    final colors = context.appColors;

    return AppSurface(
      height: 46,
      padding: const EdgeInsets.all(4),
      color: colors.surface,
      border: Border.all(color: colors.outline),
      shadows: colors.subtleShadows,
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
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? colors.textOnPrimary
                        : colors.textMedium,
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
  final int dueThisWeek;
  final int overdue;
  final int noDeadline;
  final DateTime? nextDeadline;

  const _TaskTimelineStats({
    required this.dueToday,
    required this.dueThisWeek,
    required this.overdue,
    required this.noDeadline,
    required this.nextDeadline,
  });

  factory _TaskTimelineStats.fromTasks(List<AcademicTask> tasks) {
    final today = _dateOnly(DateTime.now());
    var dueToday = 0;
    var dueThisWeek = 0;
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
      if (daysUntil > 0 && daysUntil <= 7) dueThisWeek++;

      if (nextDeadline == null || deadline.isBefore(nextDeadline)) {
        nextDeadline = deadline;
      }
    }

    return _TaskTimelineStats(
      dueToday: dueToday,
      dueThisWeek: dueThisWeek,
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
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Center(child: CircularProgressIndicator(color: colors.primary)),
    );
  }
}

class _DisciplineFilterSelector extends StatelessWidget {
  final List<Discipline> disciplines;
  final String? selectedDisciplineId;
  final ValueChanged<String?> onSelected;

  const _DisciplineFilterSelector({
    required this.disciplines,
    required this.selectedDisciplineId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: selectedDisciplineId == null,
              onSelected: (selected) {
                if (selected) onSelected(null);
              },
              selectedColor: colors.primary,
              backgroundColor: colors.surface,
              labelStyle: TextStyle(
                color: selectedDisciplineId == null
                    ? colors.textOnPrimary
                    : colors.textMedium,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selectedDisciplineId == null
                      ? Colors.transparent
                      : colors.outline,
                ),
              ),
            ),
          ),
          ...disciplines.map((discipline) {
            final isSelected = selectedDisciplineId == discipline.id;
            final disciplineColor = Color(discipline.colorValue);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(discipline.name),
                selected: isSelected,
                onSelected: (selected) {
                  onSelected(selected ? discipline.id : null);
                },
                selectedColor: disciplineColor,
                backgroundColor: colors.surface,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : colors.textMedium,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : colors.outline,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CompletedTasksCollapseCard extends StatefulWidget {
  final List<AcademicTask> tasks;
  final Widget Function(AcademicTask task) itemBuilder;

  const _CompletedTasksCollapseCard({
    required this.tasks,
    required this.itemBuilder,
  });

  @override
  State<_CompletedTasksCollapseCard> createState() =>
      _CompletedTasksCollapseCardState();
}

class _CompletedTasksCollapseCardState
    extends State<_CompletedTasksCollapseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: AppSurface.card(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          title: Text(
            'Concluídas (${widget.tasks.length})',
            style: TextStyle(
              color: colors.textMedium,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          trailing: Icon(
            _isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: colors.textMedium,
          ),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.tasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: widget.itemBuilder(task),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
