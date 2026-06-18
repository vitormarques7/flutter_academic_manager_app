import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/routes/app_routes.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../models/academic_task.dart';
import '../../models/assessment.dart';
import '../../models/discipline.dart';
import '../../models/grade_summary.dart';
import '../../models/schedule.dart';
import '../../models/study_cycle.dart';
import '../../models/subject_event.dart';
import '../../repositories/assessment_repository.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/subject_event_repository.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'subject_event_details_page.dart';
import 'task_details_page.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/metadata_chip.dart';
import '../widgets/common/page_header.dart';
import '../widgets/dialogs/task_dialog.dart';

part 'home_study_cycle_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskRepository _taskRepository = TaskRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final SubjectEventRepository _eventRepository = SubjectEventRepository();
  final AssessmentRepository _assessmentRepository = AssessmentRepository();
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final DisciplineRepository _disciplineRepository = DisciplineRepository();

  late Future<String?> _activeStudyCycleIdFuture;

  @override
  void initState() {
    super.initState();
    _activeStudyCycleIdFuture = _userProfileRepository
        .resolveActiveStudyCycleId();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _firstNameFromDisplayName(
      AuthService().currentUser?.displayName,
    );

    return SafeArea(
      child: ScrollConfiguration(
        behavior: const AppScrollBehavior(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Olá, $firstName',
                trailing: _StudyCycleMenuButton(onTap: _openStudyCycleMenu),
              ),
              const SizedBox(height: 24),
              FutureBuilder<String?>(
                future: _activeStudyCycleIdFuture,
                builder: (context, activeCycleSnapshot) {
                  if (activeCycleSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const _HomeLoadingState();
                  }

                  if (activeCycleSnapshot.hasError) {
                    return const EmptyStateCard(
                      icon: Icons.error_outline_rounded,
                      message:
                          'Não foi possível carregar seu ciclo de estudos.',
                    );
                  }

                  final activeStudyCycleId = activeCycleSnapshot.data;
                  if (activeStudyCycleId == null) {
                    return _SetupNeededPanel(
                      onTap: () => AppRoutes.toStudyCycleSetup(context),
                    );
                  }

                  return _HomeDashboard(
                    activeStudyCycleId: activeStudyCycleId,
                    taskRepository: _taskRepository,
                    scheduleRepository: _scheduleRepository,
                    eventRepository: _eventRepository,
                    assessmentRepository: _assessmentRepository,
                    disciplineRepository: _disciplineRepository,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _firstNameFromDisplayName(String? displayName) {
    final trimmedName = displayName?.trim();
    if (trimmedName == null || trimmedName.isEmpty) return 'Usuário';

    return trimmedName.split(RegExp(r'\s+')).first;
  }

  Future<void> _openStudyCycleMenu() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final selectedStudyCycleId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _StudyCycleSheet(
          onCreateCycle: () {
            Navigator.of(sheetContext).pop();
            AppRoutes.toStudyCycleSetup(context);
          },
        );
      },
    );

    if (selectedStudyCycleId == null || !mounted) return;

    try {
      await _userProfileRepository.setActiveStudyCycleId(selectedStudyCycleId);
      if (!mounted) return;
      setState(() {
        _activeStudyCycleIdFuture = _userProfileRepository
            .resolveActiveStudyCycleId();
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Ciclo atual alterado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on UserProfileRepositoryException catch (error) {
      if (!mounted) return;
      final colors = context.appColors;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: colors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final colors = context.appColors;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Não foi possível alterar o ciclo atual.'),
          backgroundColor: colors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _HomeDashboard extends StatelessWidget {
  final String activeStudyCycleId;
  final TaskRepository taskRepository;
  final ScheduleRepository scheduleRepository;
  final SubjectEventRepository eventRepository;
  final AssessmentRepository assessmentRepository;
  final DisciplineRepository disciplineRepository;

  const _HomeDashboard({
    required this.activeStudyCycleId,
    required this.taskRepository,
    required this.scheduleRepository,
    required this.eventRepository,
    required this.assessmentRepository,
    required this.disciplineRepository,
  });

  @override
  Widget build(BuildContext context) {
    final studyCycleRepository = StudyCycleRepository();

    return StreamBuilder<List<StudyCycle>>(
      stream: studyCycleRepository.watchStudyCycles(),
      builder: (context, studyCycleSnapshot) {
        final studyCycles = studyCycleSnapshot.data ?? const [];
        final activeCycle = studyCycles.firstWhere(
          (c) => c.id == activeStudyCycleId,
          orElse: () => StudyCycle(
            id: activeStudyCycleId,
            type: StudyCycleType.independent,
            passingGrade: 7.0,
          ),
        );
        final passingGrade = activeCycle.passingGrade;

        return StreamBuilder<List<Discipline>>(
          stream: disciplineRepository.watchDisciplines(
            studyCycleId: activeStudyCycleId,
          ),
          builder: (context, disciplineSnapshot) {
            return StreamBuilder<List<AcademicTask>>(
              stream: taskRepository.watchTasks(
                studyCycleId: activeStudyCycleId,
              ),
              builder: (context, taskSnapshot) {
                return StreamBuilder<List<Schedule>>(
                  stream: scheduleRepository.watchSchedules(
                    studyCycleId: activeStudyCycleId,
                  ),
                  builder: (context, scheduleSnapshot) {
                    return StreamBuilder<List<SubjectEvent>>(
                      stream: eventRepository.watchEvents(
                        studyCycleId: activeStudyCycleId,
                        upcomingOnly: true,
                      ),
                      builder: (context, eventSnapshot) {
                        return StreamBuilder<List<Assessment>>(
                          stream: assessmentRepository.watchAssessments(
                            studyCycleId: activeStudyCycleId,
                          ),
                          builder: (context, assessmentSnapshot) {
                            final isLoading =
                                (studyCycleSnapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    !studyCycleSnapshot.hasData) ||
                                _isWaiting(disciplineSnapshot) ||
                                _isWaiting(taskSnapshot) ||
                                _isWaiting(scheduleSnapshot) ||
                                _isWaiting(eventSnapshot) ||
                                _isWaiting(assessmentSnapshot);
                            if (isLoading) return const _HomeLoadingState();

                            final hasError =
                                studyCycleSnapshot.hasError ||
                                disciplineSnapshot.hasError ||
                                taskSnapshot.hasError ||
                                scheduleSnapshot.hasError ||
                                eventSnapshot.hasError ||
                                assessmentSnapshot.hasError;
                            final disciplines =
                                disciplineSnapshot.data ?? const <Discipline>[];
                            final tasks = _tasksForCycle(
                              taskSnapshot.data ?? const [],
                              activeStudyCycleId,
                            );
                            final dashboard = _HomeDashboardData.from(
                              tasks: tasks,
                              schedules: scheduleSnapshot.data ?? const [],
                              events: eventSnapshot.data ?? const [],
                              assessments: assessmentSnapshot.data ?? const [],
                              disciplines: disciplines,
                              passingGrade: passingGrade,
                            );
                            final taskSubjects =
                                _taskDialogSubjectsFromDisciplines(disciplines);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StudyFocusCard(data: dashboard),
                                if (hasError) ...[
                                  const SizedBox(height: 14),
                                  const _HomeWarningPanel(),
                                ],
                                const SizedBox(height: 22),
                                _HomeTimelinePanel(
                                  tasks: dashboard.upcomingTasks,
                                  subjects: taskSubjects,
                                  activeStudyCycleId: activeStudyCycleId,
                                  events: dashboard.upcomingEvents,
                                  onDelete: _deleteEvent,
                                ),
                                if (dashboard.alerts.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  _HomeInlineSectionHeader(
                                    icon: Icons.radar_rounded,
                                    label: 'Radar',
                                    count: dashboard.alerts.length,
                                  ),
                                  const SizedBox(height: 10),
                                  _AlertsCard(alerts: dashboard.alerts),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  bool _isWaiting(AsyncSnapshot<Object?> snapshot) {
    return snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData;
  }

  List<AcademicTask> _tasksForCycle(
    List<AcademicTask> tasks,
    String activeStudyCycleId,
  ) {
    return tasks.where((task) {
      return task.studyCycleId == null ||
          task.studyCycleId == activeStudyCycleId;
    }).toList();
  }

  Future<void> _deleteEvent(SubjectEvent event) {
    return eventRepository.deleteEvent(event.id);
  }

  List<TaskDialogSubject> _taskDialogSubjectsFromDisciplines(
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
}

class _StudyCycleMenuButton extends StatefulWidget {
  final Future<void> Function() onTap;

  const _StudyCycleMenuButton({required this.onTap});

  @override
  State<_StudyCycleMenuButton> createState() => _StudyCycleMenuButtonState();
}

class _StudyCycleMenuButtonState extends State<_StudyCycleMenuButton> {
  final _userProfileRepository = UserProfileRepository();
  final _studyCycleRepository = StudyCycleRepository();
  Future<String?>? _activeCycleLabelFuture;

  @override
  void initState() {
    super.initState();
    _loadActiveCycleLabel();
  }

  void _loadActiveCycleLabel() {
    _activeCycleLabelFuture = () async {
      try {
        final activeId = await _userProfileRepository
            .resolveActiveStudyCycleId();
        if (activeId == null) return null;
        final cycles = await _studyCycleRepository.fetchStudyCycles();
        final activeCycle = cycles.firstWhere((c) => c.id == activeId);
        return _cycleLabelText(activeCycle);
      } catch (_) {
        return null;
      }
    }();
  }

  String _cycleLabelText(StudyCycle cycle) {
    return switch (cycle.type) {
      StudyCycleType.university =>
        cycle.period == null ? 'Período' : '${cycle.period}º Período',
      StudyCycleType.highSchool =>
        cycle.schoolYear == null ? 'Ano' : '${cycle.schoolYear}º Ano',
      StudyCycleType.independent => 'Independente',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return FutureBuilder<String?>(
      future: _activeCycleLabelFuture,
      builder: (context, snapshot) {
        final label = snapshot.data;
        final tooltipMessage = label != null
            ? 'Ciclos de estudo ($label)'
            : 'Ciclos de estudo';

        return Tooltip(
          message: tooltipMessage,
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () async {
                await widget.onTap();
                if (mounted) {
                  setState(() {
                    _loadActiveCycleLabel();
                  });
                }
              },
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.outline),
                  boxShadow: colors.subtleShadows,
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: colors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StudyFocusCard extends StatelessWidget {
  final _HomeDashboardData data;

  const _StudyFocusCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final focusColor = data.focusColor(colors);
    final focusTint = Color.alphaBlend(
      focusColor.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.035,
      ),
      colors.surface,
    );

    return AppSurface.card(
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [focusTint, colors.surface],
      ),
      border: Border.all(color: focusColor.withValues(alpha: 0.12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: focusColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: colors.subtleShadows,
                ),
                child: Icon(data.focusIcon, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.focusTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 19,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.focusSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textMedium,
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetadataChip(
                icon: Icons.school_outlined,
                label: data.nextClassLabel,
                foregroundColor: data.nextClassColor(colors),
                backgroundColor: data.nextClassBackground(colors),
                maxWidth: 280,
              ),
              MetadataChip(
                icon: Icons.event_available_outlined,
                label: data.nextEventLabel,
                foregroundColor: data.nextEventColor(colors),
                backgroundColor: data.nextEventBackground(colors),
                maxWidth: 240,
              ),
              MetadataChip(
                icon: data.taskStatusIcon,
                label: data.taskStatusLabel,
                foregroundColor: data.taskStatusColor(colors),
                backgroundColor: data.taskStatusBackground(colors),
              ),
              MetadataChip(
                icon: data.gradeStatusIcon,
                label: data.gradeStatusLabel,
                foregroundColor: data.gradeStatusColor(colors),
                backgroundColor: data.gradeStatusBackground(colors),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeTimelinePanel extends StatelessWidget {
  final List<_HomeTask> tasks;
  final List<TaskDialogSubject> subjects;
  final String activeStudyCycleId;
  final List<_HomeEvent> events;
  final Future<void> Function(SubjectEvent event) onDelete;

  const _HomeTimelinePanel({
    required this.tasks,
    required this.subjects,
    required this.activeStudyCycleId,
    required this.events,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface.card(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shadows: colors.subtleShadows,
      border: Border.all(color: colors.outline.withValues(alpha: 0.72)),
      child: Column(
        children: [
          _HomeInlineSectionHeader(
            icon: Icons.assignment_outlined,
            label: 'Próximas tarefas',
            count: tasks.length,
          ),
          if (tasks.isEmpty)
            const _InlineEmptyState(
              icon: Icons.task_alt_outlined,
              message: 'Nenhuma tarefa pendente no seu ciclo atual.',
            )
          else
            for (final entry in tasks.indexed) ...[
              _TaskRow(
                task: entry.$2,
                subjects: subjects,
                activeStudyCycleId: activeStudyCycleId,
              ),
              if (entry.$1 != tasks.length - 1)
                const _HomeDivider(indent: 70, endIndent: 16),
            ],
          const _PanelSectionDivider(),
          _HomeInlineSectionHeader(
            icon: Icons.event_available_outlined,
            label: 'Próximos eventos',
            count: events.length,
            accentColor: colors.event,
          ),
          if (events.isEmpty)
            const _InlineEmptyState(
              icon: Icons.event_available_outlined,
              message: 'Nenhum evento futuro cadastrado.',
            )
          else
            for (final entry in events.indexed) ...[
              _EventRow(event: entry.$2, onDelete: onDelete),
              if (entry.$1 != events.length - 1)
                const _HomeDivider(indent: 70, endIndent: 16),
            ],
        ],
      ),
    );
  }
}

class _HomeInlineSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final Color? accentColor;

  const _HomeInlineSectionHeader({
    required this.icon,
    required this.label,
    this.count,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = accentColor ?? colors.primary;
    final count = this.count;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: colors.textDark,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const Spacer(),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceTint,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: colors.outline),
              ),
              child: Text(
                '$count ${count == 1 ? 'item' : 'itens'}',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _InlineEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          _IconBadge(
            icon: icon,
            backgroundColor: colors.surfaceTint,
            foregroundColor: colors.textSubtle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 13,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                height: 1.32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelSectionDivider extends StatelessWidget {
  const _PanelSectionDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Divider(
      height: 18,
      thickness: 1,
      color: colors.outline,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _TaskRow extends StatelessWidget {
  final _HomeTask task;
  final List<TaskDialogSubject> subjects;
  final String activeStudyCycleId;

  const _TaskRow({
    required this.task,
    required this.subjects,
    required this.activeStudyCycleId,
  });

  IconData get _typeIcon {
    return switch (task.type) {
      'Prova' => Icons.edit_square,
      'Estudo' => Icons.school_outlined,
      'Seminário' => Icons.co_present_outlined,
      'Leitura' => Icons.menu_book_outlined,
      'Pesquisa' => Icons.search_outlined,
      _ => Icons.assignment_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(icon: _typeIcon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        height: 1.24,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        MetadataChip(
                          icon: Icons.school_outlined,
                          label: task.subject,
                          iconSize: 14,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                        ),
                        MetadataChip(
                          icon: Icons.sell_outlined,
                          label: task.type,
                          foregroundColor: colors.primary,
                          backgroundColor: colors.primarySurface,
                          iconSize: 14,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _DateBadge(label: task.dueLabel, isUrgent: task.isUrgent),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: colors.textSubtle),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      AppRoutes.detailRoute(
        page: TaskDetailsPage(
          task: task.source,
          subjects: _subjectsForTask(subjects: subjects, task: task.source),
          activeStudyCycleId: activeStudyCycleId,
        ),
      ),
    );
  }

  List<TaskDialogSubject> _subjectsForTask({
    required List<TaskDialogSubject> subjects,
    required AcademicTask task,
  }) {
    final mergedSubjects = [...subjects];
    final currentDisciplineId = task.disciplineId?.trim();
    final currentSubject = task.subject.trim();

    final hasCurrentDiscipline =
        currentDisciplineId != null &&
        currentDisciplineId.isNotEmpty &&
        mergedSubjects.any((subject) => subject.id == currentDisciplineId);
    final hasCurrentSubject =
        currentSubject.isNotEmpty &&
        mergedSubjects.any(
          (subject) =>
              subject.name.trim().toLowerCase() == currentSubject.toLowerCase(),
        );

    if (!hasCurrentDiscipline &&
        !hasCurrentSubject &&
        currentSubject.isNotEmpty) {
      mergedSubjects.add(TaskDialogSubject(name: currentSubject));
    }

    return mergedSubjects;
  }
}

class _EventRow extends StatelessWidget {
  final _HomeEvent event;
  final Future<void> Function(SubjectEvent event) onDelete;

  const _EventRow({required this.event, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(
                icon: event.icon,
                backgroundColor: colors.eventSurface,
                foregroundColor: colors.event,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        height: 1.24,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        MetadataChip(
                          icon: Icons.calendar_today_outlined,
                          label: event.dateLabel,
                          iconSize: 14,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                        ),
                        MetadataChip(
                          icon: Icons.menu_book_outlined,
                          label: event.subjectLabel,
                          iconSize: 14,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: colors.textSubtle),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    final colors = context.appColors;
    Navigator.of(context).push(
      AppRoutes.detailRoute(
        page: SubjectEventDetailsPage(
          event: event.source,
          accentColor: colors.event,
          onDelete: onDelete,
        ),
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  final List<_HomeAlert> alerts;

  const _AlertsCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: alerts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(width: 268, child: _AlertRow(alert: alerts[index]));
        },
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final _HomeAlert alert;

  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = switch (alert.level) {
      _AlertLevel.warning => colors.warning,
      _AlertLevel.danger => colors.danger,
      _AlertLevel.info => colors.primary,
    };
    final background = switch (alert.level) {
      _AlertLevel.warning => colors.warningSurface,
      _AlertLevel.danger => colors.dangerSurface,
      _AlertLevel.info => colors.primarySurface,
    };
    final surfaceColor = Color.alphaBlend(
      color.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.06,
      ),
      colors.surface,
    );

    return AppSurface(
      padding: const EdgeInsets.all(13),
      color: surfaceColor,
      border: Border.all(color: color.withValues(alpha: 0.18)),
      shadows: colors.subtleShadows,
      borderRadius: AppRadius.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(
            icon: alert.icon,
            backgroundColor: background,
            foregroundColor: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    height: 1.24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMedium,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupNeededPanel extends StatelessWidget {
  final VoidCallback onTap;

  const _SetupNeededPanel({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface.card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconBadge(icon: Icons.school_outlined),
          const SizedBox(height: 14),
          Text(
            'Configure seu ciclo de estudos',
            style: TextStyle(
              color: colors.textDark,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Depois disso, a Home passa a mostrar suas aulas, tarefas, notas e eventos reais.',
            style: TextStyle(
              color: colors.textMedium,
              fontSize: 13,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              child: const Text('Configurar agora'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeWarningPanel extends StatelessWidget {
  const _HomeWarningPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: colors.warningSurface,
      border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      shadows: const [],
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: colors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Algumas informações podem estar incompletas agora.',
              style: TextStyle(
                color: colors.warning,
                fontSize: 13,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SkeletonBlock(height: 150),
        SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _SkeletonBlock(height: 82)),
            SizedBox(width: 10),
            Expanded(child: _SkeletonBlock(height: 82)),
            SizedBox(width: 10),
            Expanded(child: _SkeletonBlock(height: 82)),
          ],
        ),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;

  const _SkeletonBlock({required this.height});

  @override
  Widget build(BuildContext context) {
    return AppSurface.soft(
      height: height,
      padding: EdgeInsets.zero,
      child: const SizedBox.shrink(),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _IconBadge({
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveForegroundColor = foregroundColor ?? colors.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? colors.primary.withValues(alpha: 0.10);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: effectiveForegroundColor.withValues(alpha: 0.22),
        ),
      ),
      child: Icon(icon, color: effectiveForegroundColor, size: 23),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String label;
  final bool isUrgent;

  const _DateBadge({required this.label, this.isUrgent = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isUrgent ? colors.danger : colors.textMedium;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent ? colors.dangerSurface : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isUrgent
              ? colors.danger.withValues(alpha: 0.20)
              : colors.outline,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _HomeDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const _HomeDivider({this.indent = 14, this.endIndent = 14});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Divider(
      height: 1,
      thickness: 1,
      color: colors.outline,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

class _HomeDashboardData {
  final int pendingTasks;
  final int totalTasks;
  final int gradeRiskCount;
  final int gradeAttentionCount;
  final List<_HomeTask> upcomingTasks;
  final List<_HomeEvent> upcomingEvents;
  final List<_HomeAlert> alerts;
  final _NextClass? nextClass;

  const _HomeDashboardData({
    required this.pendingTasks,
    required this.totalTasks,
    required this.gradeRiskCount,
    required this.gradeAttentionCount,
    required this.upcomingTasks,
    required this.upcomingEvents,
    required this.alerts,
    required this.nextClass,
  });

  factory _HomeDashboardData.from({
    required List<AcademicTask> tasks,
    required List<Schedule> schedules,
    required List<SubjectEvent> events,
    required List<Assessment> assessments,
    required List<Discipline> disciplines,
    required double passingGrade,
  }) {
    final pendingTasks = tasks.where((task) => !task.isChecked).toList();
    final sortedPendingTasks = pendingTasks.toList()
      ..sort(_compareTasksByDeadline);
    final upcomingEvents = events.toList()..sort(SubjectEvent.compareByDate);
    final summary = GradeSummary.calculate(
      disciplines: disciplines,
      assessments: assessments,
      passingGrade: passingGrade,
    );

    final nextClass = _NextClass.fromSchedules(schedules);
    final homeTasks = sortedPendingTasks.take(3).map(_HomeTask.from).toList();
    final homeEvents = upcomingEvents.take(3).map(_HomeEvent.from).toList();

    return _HomeDashboardData(
      pendingTasks: pendingTasks.length,
      totalTasks: tasks.length,
      gradeRiskCount: summary.countByStatus(GradeStatus.risk),
      gradeAttentionCount: summary.countByStatus(GradeStatus.attention),
      upcomingTasks: homeTasks,
      upcomingEvents: homeEvents,
      alerts: _buildAlerts(
        pendingTasks: pendingTasks,
        schedules: schedules,
        events: upcomingEvents,
        disciplines: disciplines,
        passingGrade: passingGrade,
        summary: summary,
      ),
      nextClass: nextClass,
    );
  }

  String get taskStatusLabel {
    if (totalTasks == 0) return 'Sem tarefas';
    if (pendingTasks == 0) return 'Tarefas em dia';

    return '$pendingTasks ${pendingTasks == 1 ? 'pendente' : 'pendentes'}';
  }

  IconData get taskStatusIcon {
    if (totalTasks == 0) return Icons.playlist_add_check_outlined;
    if (pendingTasks == 0) return Icons.check_circle_outline;

    return Icons.pending_actions_outlined;
  }

  Color taskStatusColor(AppThemeColors colors) {
    if (totalTasks == 0) return colors.textMedium;
    if (pendingTasks == 0) return colors.success;

    return colors.warning;
  }

  Color taskStatusBackground(AppThemeColors colors) {
    if (totalTasks == 0) return colors.surfaceAlt;
    if (pendingTasks == 0) return colors.successSurface;

    return colors.warningSurface;
  }

  String get gradeStatusLabel {
    if (gradeRiskCount > 0) {
      return '$gradeRiskCount em risco';
    }

    return 'Notas em dia';
  }

  IconData get gradeStatusIcon {
    if (gradeRiskCount > 0) return Icons.trending_up_rounded;

    return Icons.fact_check_outlined;
  }

  Color gradeStatusColor(AppThemeColors colors) {
    if (gradeRiskCount > 0) return colors.danger;

    return colors.success;
  }

  Color gradeStatusBackground(AppThemeColors colors) {
    if (gradeRiskCount > 0) return colors.dangerSurface;

    return colors.successSurface;
  }

  IconData get focusIcon {
    if (gradeRiskCount > 0) return Icons.trending_up_rounded;
    if (gradeAttentionCount > 0) return Icons.fact_check_outlined;
    final hasDangerAlert = alerts.any(
      (alert) => alert.level == _AlertLevel.danger,
    );
    if (hasDangerAlert) return Icons.warning_amber_rounded;
    if (upcomingTasks.any((task) => task.isDueToday)) {
      return Icons.today_outlined;
    }
    if (nextClass != null) return Icons.school_outlined;
    if (upcomingEvents.isNotEmpty) return Icons.event_available_outlined;
    return Icons.check_circle_outline;
  }

  Color focusColor(AppThemeColors colors) {
    if (gradeRiskCount > 0) return colors.danger;
    if (gradeAttentionCount > 0) return colors.warning;
    final hasDangerAlert = alerts.any(
      (alert) => alert.level == _AlertLevel.danger,
    );
    if (hasDangerAlert) return colors.danger;
    if (upcomingTasks.any((task) => task.isDueToday)) return colors.warning;
    if (nextClass != null) return colors.navActive;
    if (upcomingEvents.isNotEmpty) return colors.event;
    return colors.success;
  }

  String get nextClassLabel {
    final next = nextClass;
    if (next == null) return 'Sem próxima aula';
    return '${next.title}: ${next.timeLabel}';
  }

  Color nextClassColor(AppThemeColors colors) {
    return nextClass == null ? colors.textMedium : colors.navActive;
  }

  Color nextClassBackground(AppThemeColors colors) {
    return nextClass == null ? colors.surfaceAlt : colors.primarySurface;
  }

  String get nextEventLabel {
    if (upcomingEvents.isEmpty) return 'Sem eventos';
    return upcomingEvents.first.shortLabel;
  }

  Color nextEventColor(AppThemeColors colors) {
    return upcomingEvents.isEmpty ? colors.textMedium : colors.event;
  }

  Color nextEventBackground(AppThemeColors colors) {
    return upcomingEvents.isEmpty ? colors.surfaceAlt : colors.eventSurface;
  }

  String get focusTitle {
    if (gradeRiskCount > 0) return 'Disciplina em risco';
    if (gradeAttentionCount > 0) return 'Notas pedindo cuidado';
    final hasDangerAlert = alerts.any(
      (alert) => alert.level == _AlertLevel.danger,
    );
    if (hasDangerAlert) return 'Há pontos pedindo atenção';
    if (upcomingTasks.any((task) => task.isDueToday)) return 'Hoje tem tarefa';
    if (nextClass != null) return 'Próxima aula no radar';
    if (upcomingEvents.isNotEmpty) return 'Evento chegando';
    return 'Seu painel está tranquilo';
  }

  String get focusSubtitle {
    if (gradeRiskCount > 0) {
      if (gradeRiskCount == 1) {
        return 'Revise as notas da disciplina em risco.';
      }

      return 'Revise as notas das $gradeRiskCount disciplinas em risco.';
    }

    if (gradeAttentionCount > 0) {
      return '$gradeAttentionCount ${gradeAttentionCount == 1 ? 'disciplina está' : 'disciplinas estão'} perto da média mínima.';
    }

    if (pendingTasks == 0 && totalTasks > 0) {
      return 'Tudo concluído no ciclo atual. Belo ritmo.';
    }
    if (pendingTasks == 0) {
      return 'Crie tarefas, notas e eventos para acompanhar sua rotina.';
    }

    final taskLabel = pendingTasks == 1
        ? 'tarefa pendente'
        : 'tarefas pendentes';
    return '$pendingTasks $taskLabel no ciclo atual.';
  }

  static List<_HomeAlert> _buildAlerts({
    required List<AcademicTask> pendingTasks,
    required List<Schedule> schedules,
    required List<SubjectEvent> events,
    required List<Discipline> disciplines,
    required double passingGrade,
    required GradeSummary summary,
  }) {
    final today = _dateOnly(DateTime.now());
    final overdueCount = pendingTasks.where((task) {
      final deadline = _parseBrazilianDate(task.deadline);
      return deadline != null && deadline.isBefore(today);
    }).length;
    final todayCount = pendingTasks.where((task) {
      final deadline = _parseBrazilianDate(task.deadline);
      return deadline != null && deadline == today;
    }).length;
    final soonEvent = events.where((event) {
      final daysUntil = _dateOnly(event.eventDate).difference(today).inDays;
      return daysUntil >= 0 && daysUntil <= 3;
    }).firstOrNull;

    final alerts = <_HomeAlert>[];
    if (overdueCount > 0) {
      alerts.add(
        _HomeAlert(
          title:
              '$overdueCount ${overdueCount == 1 ? 'tarefa atrasada' : 'tarefas atrasadas'}',
          description: 'Revise seus prazos para recuperar o controle.',
          level: _AlertLevel.danger,
          icon: Icons.warning_amber_rounded,
        ),
      );
    }

    for (final discipline in disciplines) {
      final absences = discipline.absences;
      final maxAbsences = discipline.maxAbsences > 0
          ? discipline.maxAbsences
          : 12;
      if (absences >= maxAbsences * 0.8) {
        alerts.add(
          _HomeAlert(
            title: 'Atenção ao limite de faltas',
            description:
                'Você tem $absences/$maxAbsences faltas em ${discipline.name}.',
            level: _AlertLevel.danger,
            icon: Icons.trending_up_rounded,
          ),
        );
      }
    }

    if (summary.totalGrades == 0) {
      alerts.add(
        const _HomeAlert(
          title: 'Sem notas registradas',
          description: 'Adicionar notas ajuda a acompanhar cada disciplina.',
          level: _AlertLevel.info,
          icon: Icons.fact_check_outlined,
        ),
      );
    } else {
      for (final discipline in disciplines) {
        final disciplineSummary = summary.disciplineSummaries[discipline.id];
        if (disciplineSummary == null ||
            disciplineSummary.status != GradeStatus.risk) {
          continue;
        }

        alerts.add(
          _HomeAlert(
            title: '${discipline.name} em risco',
            description:
                'Média ${disciplineSummary.average!.toStringAsFixed(1)} '
                'abaixo do mínimo ${passingGrade.toStringAsFixed(1)}.',
            level: _AlertLevel.danger,
            icon: Icons.warning_amber_rounded,
          ),
        );
      }

      for (final discipline in disciplines) {
        final disciplineSummary = summary.disciplineSummaries[discipline.id];
        if (disciplineSummary == null ||
            disciplineSummary.status != GradeStatus.attention) {
          continue;
        }

        alerts.add(
          _HomeAlert(
            title: '${discipline.name} em atenção',
            description:
                'Média ${disciplineSummary.average!.toStringAsFixed(1)} '
                'perto do mínimo ${passingGrade.toStringAsFixed(1)}.',
            level: _AlertLevel.warning,
            icon: Icons.trending_up_rounded,
          ),
        );
      }
    }

    if (todayCount > 0) {
      alerts.add(
        _HomeAlert(
          title:
              '$todayCount ${todayCount == 1 ? 'entrega para hoje' : 'entregas para hoje'}',
          description: 'Separe um bloco de tempo para finalizar sem pressa.',
          level: _AlertLevel.warning,
          icon: Icons.today_outlined,
        ),
      );
    }
    if (soonEvent != null) {
      alerts.add(
        _HomeAlert(
          title: '${soonEvent.type.label}: ${soonEvent.title}',
          description: 'Marcado para ${soonEvent.displayDateTimeLabel}.',
          level: _AlertLevel.info,
          icon: Icons.event_available_outlined,
        ),
      );
    }
    if (schedules.isEmpty) {
      alerts.add(
        const _HomeAlert(
          title: 'Grade ainda vazia',
          description: 'Cadastre suas aulas para melhorar seu calendário.',
          level: _AlertLevel.info,
          icon: Icons.calendar_month_outlined,
        ),
      );
    }

    return alerts.take(3).toList();
  }
}

class _NextClass {
  final String title;
  final String timeLabel;
  final DateTime occurrenceDate;
  final int startTimeMinutes;

  const _NextClass({
    required this.title,
    required this.timeLabel,
    required this.occurrenceDate,
    required this.startTimeMinutes,
  });

  static _NextClass? fromSchedules(List<Schedule> schedules) {
    if (schedules.isEmpty) return null;

    final now = DateTime.now();
    final today = _dateOnly(now);
    final nowMinutes = now.hour * 60 + now.minute;
    final candidates = <_NextClass>[];

    for (var dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final day = today.add(Duration(days: dayOffset));
      final weekdayIndex = day.weekday % 7;
      final schedulesForDay = schedules.where(
        (schedule) => schedule.occursOnWeekday(weekdayIndex),
      );

      for (final schedule in schedulesForDay) {
        if (dayOffset == 0 && schedule.endTimeMinutes < nowMinutes) continue;

        candidates.add(
          _NextClass(
            title: schedule.disciplineName,
            timeLabel:
                '${_relativeDayLabel(day, today)}, ${schedule.formattedTimeRange}',
            occurrenceDate: day,
            startTimeMinutes: schedule.startTimeMinutes,
          ),
        );
      }
    }

    candidates.sort((a, b) {
      final dateComparison = a.occurrenceDate.compareTo(b.occurrenceDate);
      if (dateComparison != 0) return dateComparison;
      return a.startTimeMinutes.compareTo(b.startTimeMinutes);
    });

    return candidates.firstOrNull;
  }
}

class _HomeTask {
  final AcademicTask source;
  final String title;
  final String subject;
  final String dueLabel;
  final String type;
  final DateTime? deadline;

  const _HomeTask({
    required this.source,
    required this.title,
    required this.subject,
    required this.dueLabel,
    required this.type,
    this.deadline,
  });

  factory _HomeTask.from(AcademicTask task) {
    final deadline = _parseBrazilianDate(task.deadline);

    return _HomeTask(
      source: task,
      title: task.title,
      subject: task.subject.isEmpty ? 'Sem disciplina' : task.subject,
      dueLabel: deadline == null ? task.deadlineLabel : _shortDate(deadline),
      type: task.visualPriority,
      deadline: deadline,
    );
  }

  bool get isDueToday {
    final date = deadline;
    if (date == null) return false;
    return date == _dateOnly(DateTime.now());
  }

  bool get isUrgent {
    final date = deadline;
    if (date == null) return false;
    return !date.isAfter(_dateOnly(DateTime.now()));
  }
}

class _HomeEvent {
  final SubjectEvent source;
  final String title;
  final String dateLabel;
  final String subjectLabel;
  final String shortLabel;
  final IconData icon;

  const _HomeEvent({
    required this.source,
    required this.title,
    required this.dateLabel,
    required this.subjectLabel,
    required this.shortLabel,
    required this.icon,
  });

  factory _HomeEvent.from(SubjectEvent event) {
    final subject = event.disciplineName.trim();

    return _HomeEvent(
      source: event,
      title: event.title,
      dateLabel: event.displayDateTimeLabel,
      subjectLabel: subject.isEmpty ? 'Sem disciplina' : subject,
      shortLabel: event.hasTimeRange
          ? '${event.type.label}: ${_shortDate(event.eventDate)} ${event.timeRangeLabel}'
          : '${event.type.label}: ${_shortDate(event.eventDate)}',
      icon: switch (event.type) {
        SubjectEventType.exam => Icons.edit_square,
        SubjectEventType.lecture => Icons.record_voice_over_outlined,
        SubjectEventType.seminar => Icons.co_present_outlined,
        SubjectEventType.deadline => Icons.assignment_turned_in_outlined,
        SubjectEventType.extraClass => Icons.school_outlined,
        SubjectEventType.other => Icons.event_note_outlined,
      },
    );
  }
}

class _HomeAlert {
  final String title;
  final String description;
  final _AlertLevel level;
  final IconData icon;

  const _HomeAlert({
    required this.title,
    required this.description,
    required this.level,
    required this.icon,
  });
}

enum _AlertLevel { info, warning, danger }

int _compareTasksByDeadline(AcademicTask a, AcademicTask b) {
  final aDate = _parseBrazilianDate(a.deadline);
  final bDate = _parseBrazilianDate(b.deadline);

  if (aDate == null && bDate == null) return a.title.compareTo(b.title);
  if (aDate == null) return 1;
  if (bDate == null) return -1;

  final dateComparison = aDate.compareTo(bDate);
  if (dateComparison != 0) return dateComparison;

  return a.title.compareTo(b.title);
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime? _parseBrazilianDate(String value) {
  final parts = value.trim().split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;

  final parsed = DateTime(year, month, day);
  if (parsed.day != day || parsed.month != month || parsed.year != year) {
    return null;
  }

  return _dateOnly(parsed);
}

String _shortDate(DateTime date) {
  return DateFormat('dd/MM', 'pt_BR').format(date);
}

String _relativeDayLabel(DateTime day, DateTime today) {
  final normalizedDay = _dateOnly(day);
  final difference = normalizedDay.difference(today).inDays;
  if (difference == 0) return 'Hoje';
  if (difference == 1) return 'Amanhã';

  final weekday = DateFormat.EEEE('pt_BR').format(day);
  return '${weekday[0].toUpperCase()}${weekday.substring(1)}';
}
