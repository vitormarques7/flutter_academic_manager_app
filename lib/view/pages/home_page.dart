import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import '../../config/routes/app_routes.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_colors.dart';
import '../../models/schedule.dart';
import '../../models/study_cycle.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../widgets/common/list_section_header.dart';
import '../widgets/common/metadata_chip.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/summary_metric_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _overview = _HomeOverview(
    averageGrade: 8.5,
    frequency: 0.92,
    pendingTasks: 3,
    nextClass: 'Programação',
  );

  static const _tasks = [
    _HomeTask(
      title: 'Entrega de trabalho - Programação',
      subject: 'Programação',
      dueLabel: '24/04',
      type: 'Trabalho',
    ),
    _HomeTask(
      title: 'Revisar matéria de BD',
      subject: 'Banco de Dados',
      dueLabel: '26/04',
      type: 'Estudo',
    ),
    _HomeTask(
      title: 'Revisar matéria de Cálculo 1',
      subject: 'Cálculo I',
      dueLabel: '30/04',
      type: 'Revisão',
    ),
  ];

  static const _alerts = [
    _HomeAlert(
      title: 'Prova de Cálculo',
      description: 'Reserve um bloco de revisão antes da aula.',
      level: _AlertLevel.warning,
    ),
    _HomeAlert(
      title: 'Frequência de Cálculo I em atenção',
      description: '60% registrado no mock atual.',
      level: _AlertLevel.info,
    ),
  ];

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
                trailing: _StudyCycleMenuButton(
                  onTap: () => _openStudyCycleMenu(context),
                ),
              ),
              const SizedBox(height: 24),
              const _StudyFocusCard(overview: _overview),
              const SizedBox(height: 18),
              const _OverviewMetrics(overview: _overview),
              const SizedBox(height: 24),
              ListSectionHeader(
                label: 'PRÓXIMAS TAREFAS',
                count: _tasks.length,
              ),
              const SizedBox(height: 12),
              const _UpcomingTasksCard(tasks: _tasks),
              const SizedBox(height: 24),
              ListSectionHeader(label: 'ALERTAS', count: _alerts.length),
              const SizedBox(height: 12),
              const _AlertsCard(alerts: _alerts),
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

  void _openStudyCycleMenu(BuildContext context) {
    showModalBottomSheet<void>(
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
  }
}

class _StudyCycleMenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StudyCycleMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Períodos',
      child: Material(
        color: const Color(0xFFEDE8FB),
        borderRadius: BorderRadius.circular(16),
        shadowColor: const Color(0x33587DBD),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.menu_rounded, color: AppColors.primary, size: 30),
          ),
        ),
      ),
    );
  }
}

class _StudyCycleSheet extends StatelessWidget {
  final VoidCallback onCreateCycle;
  final StudyCycleRepository studyCycleRepository;
  final UserProfileRepository userProfileRepository;
  final ScheduleRepository scheduleRepository;

  _StudyCycleSheet({
    required this.onCreateCycle,
    StudyCycleRepository? studyCycleRepository,
    UserProfileRepository? userProfileRepository,
    ScheduleRepository? scheduleRepository,
  }) : studyCycleRepository = studyCycleRepository ?? StudyCycleRepository(),
       userProfileRepository = userProfileRepository ?? UserProfileRepository(),
       scheduleRepository = scheduleRepository ?? ScheduleRepository();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x33514EB6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<List<_StudyCycleSummary>>(
              future: _loadStudyCycleSummaries(),
              builder: (context, snapshot) {
                final cycles = snapshot.data ?? [];
                final currentCycle = cycles.isEmpty
                    ? null
                    : cycles.firstWhere(
                        (cycle) => cycle.isCurrent,
                        orElse: () => cycles.first,
                      );
                final sheetTitle = _sheetTitleForCycle(currentCycle);

                Widget content;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  content = const _StudyCycleSheetStatus(
                    icon: Icons.hourglass_top_rounded,
                    message: 'Carregando seus períodos...',
                  );
                } else if (snapshot.hasError) {
                  content = const _StudyCycleSheetStatus(
                    icon: Icons.error_outline_rounded,
                    message: 'Não foi possível carregar seus períodos.',
                  );
                } else if (cycles.isEmpty) {
                  content = const _StudyCycleSheetStatus(
                    icon: Icons.school_outlined,
                    message: 'Nenhum período cadastrado ainda.',
                  );
                } else {
                  final activeCycle = currentCycle!;
                  final previousCycles = cycles
                      .where((cycle) => cycle.id != activeCycle.id)
                      .toList();

                  content = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CurrentCycleCard(cycle: activeCycle),
                      const SizedBox(height: 12),
                      _PreviousCyclesTile(cycles: previousCycles),
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sheetTitle,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 22,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fechar',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    content,
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              shadowColor: const Color(0x33587DBD),
              elevation: 3,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onCreateCycle,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Criar novo período',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w800,
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

  Future<List<_StudyCycleSummary>> _loadStudyCycleSummaries() async {
    final activeStudyCycleId = await userProfileRepository
        .resolveActiveStudyCycleId();
    final studyCycles = await studyCycleRepository.fetchStudyCycles();
    if (studyCycles.isEmpty) return const [];

    final summaries = <_StudyCycleSummary>[];
    for (final studyCycle in studyCycles) {
      final schedules = await scheduleRepository.fetchSchedules(
        studyCycleId: studyCycle.id,
      );

      summaries.add(
        _StudyCycleSummary(
          id: studyCycle.id,
          type: studyCycle.type,
          title: _cycleTitle(studyCycle),
          label: _cycleLabel(studyCycle),
          detail: _cycleDetail(schedules),
          isCurrent: studyCycle.id == activeStudyCycleId,
        ),
      );
    }

    summaries.sort((a, b) {
      if (a.isCurrent && !b.isCurrent) return -1;
      if (!a.isCurrent && b.isCurrent) return 1;
      return 0;
    });

    return summaries;
  }

  String _sheetTitleForCycle(_StudyCycleSummary? studyCycle) {
    return switch (studyCycle?.type) {
      StudyCycleType.university => 'Seus períodos',
      StudyCycleType.highSchool => 'Seus anos letivos',
      StudyCycleType.independent => 'Suas metas',
      null => 'Seus ciclos',
    };
  }

  String _cycleTitle(StudyCycle studyCycle) {
    return switch (studyCycle.type) {
      StudyCycleType.university =>
        studyCycle.courseName ?? 'Curso não informado',
      StudyCycleType.highSchool => 'Ensino médio',
      StudyCycleType.independent => studyCycle.goal ?? 'Objetivo não informado',
    };
  }

  String _cycleLabel(StudyCycle studyCycle) {
    return switch (studyCycle.type) {
      StudyCycleType.university =>
        studyCycle.period == null
            ? 'Período não informado'
            : '${studyCycle.period}º período',
      StudyCycleType.highSchool =>
        studyCycle.schoolYear == null
            ? 'Ano letivo não informado'
            : '${studyCycle.schoolYear}º ano',
      StudyCycleType.independent => 'Estudo independente',
    };
  }

  String _cycleDetail(List<Schedule> schedules) {
    if (schedules.isEmpty) return 'Sem aulas cadastradas';

    final classCount = schedules.fold<int>(
      0,
      (total, schedule) => total + schedule.weekdays.length,
    );
    final safeClassCount = classCount == 0 ? schedules.length : classCount;
    final classLabel = safeClassCount == 1 ? 'aula' : 'aulas';

    return '${_shiftLabelFromSchedules(schedules)} • '
        '$safeClassCount $classLabel';
  }

  String _shiftLabelFromSchedules(List<Schedule> schedules) {
    if (schedules.isEmpty) return 'Sem aulas';

    final shifts = <_ScheduleShift>{};

    for (final schedule in schedules) {
      shifts.add(_shiftFromTime(schedule.startTimeMinutes));
    }

    const orderedShifts = [
      _ScheduleShift.morning,
      _ScheduleShift.afternoon,
      _ScheduleShift.night,
    ];

    final labels = orderedShifts
        .where(shifts.contains)
        .map((shift) => shift.label)
        .toList();

    if (labels.length <= 1) return labels.first;
    if (labels.length == 2) return '${labels.first} e ${labels.last}';

    return '${labels[0]}, ${labels[1]} e ${labels[2]}';
  }

  _ScheduleShift _shiftFromTime(int startTimeMinutes) {
    if (startTimeMinutes < 12 * 60) return _ScheduleShift.morning;
    if (startTimeMinutes < 18 * 60) return _ScheduleShift.afternoon;

    return _ScheduleShift.night;
  }
}

class _CurrentCycleCard extends StatelessWidget {
  final _StudyCycleSummary cycle;

  const _CurrentCycleCard({required this.cycle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33514EB6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.school_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cycle.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const _CurrentBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cycle.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cycle.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
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

class _PreviousCyclesTile extends StatelessWidget {
  final List<_StudyCycleSummary> cycles;

  const _PreviousCyclesTile({required this.cycles});

  @override
  Widget build(BuildContext context) {
    if (cycles.isEmpty) {
      return const _StudyCycleSheetStatus(
        icon: Icons.history_outlined,
        message: 'Sem ciclos anteriores.',
        dense: true,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1F514EB6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
        leading: const Icon(Icons.history_outlined, color: AppColors.primary),
        title: const Text(
          'Períodos anteriores',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
          ),
        ),
        children: cycles
            .map(
              (cycle) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _PreviousCycleRow(cycle: cycle),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PreviousCycleRow extends StatelessWidget {
  final _StudyCycleSummary cycle;

  const _PreviousCycleRow({required this.cycle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cycle.label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                cycle.detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudyCycleSheetStatus extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool dense;

  const _StudyCycleSheetStatus({
    required this.icon,
    required this.message,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: dense ? 13 : 20),
      decoration: BoxDecoration(
        color: dense ? const Color(0xFFF5F5F5) : const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1F514EB6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: dense ? 22 : 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: dense ? 14 : 15,
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

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Atual',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _StudyFocusCard extends StatelessWidget {
  final _HomeOverview overview;

  const _StudyFocusCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final frequencyPercent = (overview.frequency * 100).round();

    return _HomeCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33587DBD),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seu painel de hoje',
                      style: TextStyle(
                        color: Color(0xFF191820),
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${overview.pendingTasks} tarefas pendentes e $frequencyPercent% de frequência geral.',
                      style: const TextStyle(
                        color: Color(0xFF464552),
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
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: overview.frequency.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.82),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetadataChip(
                icon: Icons.school_outlined,
                label: 'Próxima aula: ${overview.nextClass}',
              ),
              MetadataChip(
                icon: Icons.bar_chart_outlined,
                label: 'Média ${overview.averageGrade.toStringAsFixed(1)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  final _HomeOverview overview;

  const _OverviewMetrics({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryMetricTile(
            label: 'Média',
            value: overview.averageGrade.toStringAsFixed(1),
            icon: Icons.bar_chart_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryMetricTile(
            label: 'Freq.',
            value: '${(overview.frequency * 100).round()}%',
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryMetricTile(
            label: 'Pendentes',
            value: '${overview.pendingTasks}',
            icon: Icons.pending_actions_outlined,
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
    return _HomeCard(
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: Icons.assignment_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF191820),
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
          _DateBadge(label: task.dueLabel),
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  final List<_HomeAlert> alerts;

  const _AlertsCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
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
    final isWarning = alert.level == _AlertLevel.warning;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(
            icon: isWarning
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            backgroundColor: isWarning
                ? const Color(0xFFFFF3E8)
                : AppColors.primary.withValues(alpha: 0.12),
            foregroundColor: isWarning ? const Color(0xFF9A3412) : null,
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
                  style: const TextStyle(
                    color: Color(0xFF191820),
                    fontSize: 15,
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
                  style: const TextStyle(
                    color: Color(0xFF464552),
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

class _HomeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _HomeCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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
      child: child,
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
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4C514EB6)),
      ),
      child: Icon(icon, color: foregroundColor ?? AppColors.primary, size: 23),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String label;

  const _DateBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF464552),
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
  const _HomeDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE2E4F0),
      indent: 14,
      endIndent: 14,
    );
  }
}

class _HomeOverview {
  final double averageGrade;
  final double frequency;
  final int pendingTasks;
  final String nextClass;

  const _HomeOverview({
    required this.averageGrade,
    required this.frequency,
    required this.pendingTasks,
    required this.nextClass,
  });
}

class _HomeTask {
  final String title;
  final String subject;
  final String dueLabel;
  final String type;

  const _HomeTask({
    required this.title,
    required this.subject,
    required this.dueLabel,
    required this.type,
  });
}

class _HomeAlert {
  final String title;
  final String description;
  final _AlertLevel level;

  const _HomeAlert({
    required this.title,
    required this.description,
    required this.level,
  });
}

class _StudyCycleSummary {
  final String id;
  final StudyCycleType type;
  final String title;
  final String label;
  final String detail;
  final bool isCurrent;

  const _StudyCycleSummary({
    required this.id,
    required this.type,
    required this.title,
    required this.label,
    required this.detail,
    this.isCurrent = false,
  });
}

enum _AlertLevel { info, warning }

enum _ScheduleShift {
  morning('Manhã'),
  afternoon('Tarde'),
  night('Noite');

  final String label;

  const _ScheduleShift(this.label);
}
