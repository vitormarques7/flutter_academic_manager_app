import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/routes/app_routes.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../models/academic_task.dart';
import '../../models/assessment.dart';
import '../../models/schedule.dart';
import '../../models/study_cycle.dart';
import '../../models/subject_event.dart';
import '../../repositories/assessment_repository.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/subject_event_repository.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'subject_event_details_page.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/list_section_header.dart';
import '../widgets/common/metadata_chip.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/summary_metric_tile.dart';

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
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível alterar o ciclo atual.'),
          backgroundColor: AppColors.danger,
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

  const _HomeDashboard({
    required this.activeStudyCycleId,
    required this.taskRepository,
    required this.scheduleRepository,
    required this.eventRepository,
    required this.assessmentRepository,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AcademicTask>>(
      stream: taskRepository.watchTasks(studyCycleId: activeStudyCycleId),
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
                        _isWaiting(taskSnapshot) ||
                        _isWaiting(scheduleSnapshot) ||
                        _isWaiting(eventSnapshot) ||
                        _isWaiting(assessmentSnapshot);
                    if (isLoading) return const _HomeLoadingState();

                    final hasError =
                        taskSnapshot.hasError ||
                        scheduleSnapshot.hasError ||
                        eventSnapshot.hasError ||
                        assessmentSnapshot.hasError;
                    final tasks = _tasksForCycle(
                      taskSnapshot.data ?? const [],
                      activeStudyCycleId,
                    );
                    final dashboard = _HomeDashboardData.from(
                      tasks: tasks,
                      schedules: scheduleSnapshot.data ?? const [],
                      events: eventSnapshot.data ?? const [],
                      assessments: assessmentSnapshot.data ?? const [],
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StudyFocusCard(data: dashboard),
                        const SizedBox(height: 18),
                        _OverviewMetrics(data: dashboard),
                        if (hasError) ...[
                          const SizedBox(height: 14),
                          const _HomeWarningPanel(),
                        ],
                        const SizedBox(height: 24),
                        ListSectionHeader(
                          label: 'PRÓXIMAS TAREFAS',
                          count: dashboard.upcomingTasks.length,
                        ),
                        const SizedBox(height: 12),
                        _UpcomingTasksCard(tasks: dashboard.upcomingTasks),
                        const SizedBox(height: 24),
                        ListSectionHeader(
                          label: 'PRÓXIMOS EVENTOS',
                          count: dashboard.upcomingEvents.length,
                        ),
                        const SizedBox(height: 12),
                        _UpcomingEventsCard(
                          events: dashboard.upcomingEvents,
                          onDelete: _deleteEvent,
                        ),
                        const SizedBox(height: 24),
                        ListSectionHeader(
                          label: 'RADAR',
                          count: dashboard.alerts.length,
                        ),
                        const SizedBox(height: 12),
                        _AlertsCard(alerts: dashboard.alerts),
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
}

class _StudyCycleMenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StudyCycleMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Tooltip(
      message: 'Ciclos de estudo',
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
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
            child: Icon(Icons.menu_rounded, color: colors.primary, size: 28),
          ),
        ),
      ),
    );
  }
}

class _StudyFocusCard extends StatelessWidget {
  final _HomeDashboardData data;

  const _StudyFocusCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface.card(
      padding: const EdgeInsets.all(18),
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
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: colors.subtleShadows,
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: Colors.white,
                  size: 27,
                ),
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
                        fontWeight: FontWeight.w900,
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
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: data.taskProgress,
              minHeight: 8,
              backgroundColor: colors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetadataChip(
                icon: Icons.school_outlined,
                label: data.nextClassLabel,
                foregroundColor: colors.navActive,
                backgroundColor: colors.primarySurface,
              ),
              MetadataChip(
                icon: Icons.event_available_outlined,
                label: data.nextEventLabel,
                foregroundColor: colors.event,
                backgroundColor: colors.eventSurface,
              ),
              MetadataChip(
                icon: Icons.check_circle_outline,
                label: data.progressLabel,
                foregroundColor: colors.success,
                backgroundColor: colors.successSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  final _HomeDashboardData data;

  const _OverviewMetrics({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryMetricTile(
            label: 'Média',
            value: data.averageLabel,
            icon: Icons.bar_chart_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryMetricTile(
            label: 'Pendentes',
            value: '${data.pendingTasks}',
            icon: Icons.pending_actions_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryMetricTile(
            label: 'Eventos',
            value: '${data.upcomingEvents.length}',
            icon: Icons.event_note_outlined,
          ),
        ),
      ],
    );
  }
}

class _UpcomingTasksCard extends StatelessWidget {
  final List<_HomeTask> tasks;

  const _UpcomingTasksCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.task_alt_outlined,
        message: 'Nenhuma tarefa pendente no seu ciclo atual.',
      );
    }

    return AppSurface.card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final entry in tasks.indexed) ...[
            _TaskRow(task: entry.$2),
            if (entry.$1 != tasks.length - 1) const _HomeDivider(),
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final _HomeTask task;

  const _TaskRow({required this.task});

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
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.tasks),
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
                        fontWeight: FontWeight.w900,
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
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingEventsCard extends StatelessWidget {
  final List<_HomeEvent> events;
  final Future<void> Function(SubjectEvent event) onDelete;

  const _UpcomingEventsCard({required this.events, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.event_available_outlined,
        message: 'Nenhum evento futuro cadastrado.',
      );
    }

    return AppSurface.card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final entry in events.indexed) ...[
            _EventRow(event: entry.$2, onDelete: onDelete),
            if (entry.$1 != events.length - 1) const _HomeDivider(),
          ],
        ],
      ),
    );
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
                backgroundColor: AppColors.eventSurface,
                foregroundColor: AppColors.event,
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
                        fontWeight: FontWeight.w900,
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
    Navigator.of(context).push(
      AppRoutes.slideRoute(
        page: SubjectEventDetailsPage(
          event: event.source,
          accentColor: AppColors.event,
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
      return const EmptyStateCard(
        icon: Icons.verified_outlined,
        message: 'Sem alertas importantes agora.',
      );
    }

    return AppSurface.card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final entry in alerts.indexed) ...[
            _AlertRow(alert: entry.$2),
            if (entry.$1 != alerts.length - 1) const _HomeDivider(),
          ],
        ],
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
      _AlertLevel.warning => AppColors.warning,
      _AlertLevel.danger => AppColors.danger,
      _AlertLevel.info => AppColors.primary,
    };
    final background = switch (alert.level) {
      _AlertLevel.warning => AppColors.warningSurface,
      _AlertLevel.danger => AppColors.dangerSurface,
      _AlertLevel.info => AppColors.primary.withValues(alpha: 0.10),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
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
              fontWeight: FontWeight.w900,
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
    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: AppColors.warningSurface,
      border: Border.all(color: const Color(0xFFFFD7A8)),
      shadows: const [],
      borderRadius: AppRadius.md,
      child: const Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: AppColors.warning, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Algumas informações podem estar incompletas agora.',
              style: TextStyle(
                color: AppColors.warning,
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
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: (foregroundColor ?? AppColors.primary).withValues(alpha: 0.22),
        ),
      ),
      child: Icon(icon, color: foregroundColor ?? AppColors.primary, size: 23),
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
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _HomeDivider extends StatelessWidget {
  const _HomeDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Divider(
      height: 1,
      thickness: 1,
      color: colors.outline,
      indent: 14,
      endIndent: 14,
    );
  }
}

class _HomeDashboardData {
  final double? averageGrade;
  final int pendingTasks;
  final int completedTasks;
  final int totalTasks;
  final List<_HomeTask> upcomingTasks;
  final List<_HomeEvent> upcomingEvents;
  final List<_HomeAlert> alerts;
  final _NextClass? nextClass;

  const _HomeDashboardData({
    required this.averageGrade,
    required this.pendingTasks,
    required this.completedTasks,
    required this.totalTasks,
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
  }) {
    final pendingTasks = tasks.where((task) => !task.isChecked).toList();
    final completedTasks = tasks.where((task) => task.isChecked).length;
    final sortedPendingTasks = pendingTasks.toList()
      ..sort(_compareTasksByDeadline);
    final upcomingEvents = events.toList()..sort(SubjectEvent.compareByDate);
    final average = assessments.isEmpty
        ? null
        : assessments.fold<double>(0, (sum, item) => sum + item.grade) /
              assessments.length;

    final nextClass = _NextClass.fromSchedules(schedules);
    final homeTasks = sortedPendingTasks.take(3).map(_HomeTask.from).toList();
    final homeEvents = upcomingEvents.take(3).map(_HomeEvent.from).toList();

    return _HomeDashboardData(
      averageGrade: average,
      pendingTasks: pendingTasks.length,
      completedTasks: completedTasks,
      totalTasks: tasks.length,
      upcomingTasks: homeTasks,
      upcomingEvents: homeEvents,
      alerts: _buildAlerts(
        pendingTasks: pendingTasks,
        schedules: schedules,
        events: upcomingEvents,
        assessments: assessments,
      ),
      nextClass: nextClass,
    );
  }

  String get averageLabel => averageGrade?.toStringAsFixed(1) ?? '-';

  double get taskProgress {
    if (totalTasks == 0) return 0;
    return (completedTasks / totalTasks).clamp(0.0, 1.0);
  }

  String get progressLabel {
    if (totalTasks == 0) return 'Sem tarefas';
    return '$completedTasks/$totalTasks concluídas';
  }

  String get nextClassLabel {
    final next = nextClass;
    if (next == null) return 'Sem próxima aula';
    return '${next.title}: ${next.timeLabel}';
  }

  String get nextEventLabel {
    if (upcomingEvents.isEmpty) return 'Sem eventos';
    return upcomingEvents.first.shortLabel;
  }

  String get focusTitle {
    final overdue = alerts.any((alert) => alert.level == _AlertLevel.danger);
    if (overdue) return 'Há prazos pedindo atenção';
    if (upcomingTasks.any((task) => task.isDueToday)) return 'Hoje tem tarefa';
    if (nextClass != null) return 'Próxima aula no radar';
    if (upcomingEvents.isNotEmpty) return 'Evento chegando';
    return 'Seu painel está tranquilo';
  }

  String get focusSubtitle {
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
    required List<Assessment> assessments,
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
          description: 'Marcado para ${soonEvent.displayDateLabel}.',
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
    if (assessments.isEmpty) {
      alerts.add(
        const _HomeAlert(
          title: 'Sem notas registradas',
          description: 'Adicionar notas ajuda o painel a calcular sua média.',
          level: _AlertLevel.info,
          icon: Icons.fact_check_outlined,
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
  final String title;
  final String subject;
  final String dueLabel;
  final String type;
  final DateTime? deadline;

  const _HomeTask({
    required this.title,
    required this.subject,
    required this.dueLabel,
    required this.type,
    this.deadline,
  });

  factory _HomeTask.from(AcademicTask task) {
    final deadline = _parseBrazilianDate(task.deadline);

    return _HomeTask(
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
      dateLabel: event.displayDateLabel,
      subjectLabel: subject.isEmpty ? 'Sem disciplina' : subject,
      shortLabel: '${event.type.label}: ${_shortDate(event.eventDate)}',
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
