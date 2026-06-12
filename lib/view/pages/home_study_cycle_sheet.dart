part of 'home_page.dart';

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
      child: AppSurface.card(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        borderRadius: AppRadius.xl,
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
                      _PreviousCyclesTile(
                        cycles: previousCycles,
                        onActivate: (cycleId) {
                          Navigator.of(context).pop(cycleId);
                        },
                      ),
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
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
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
    return AppSurface.soft(
      padding: const EdgeInsets.all(14),
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
  final ValueChanged<String> onActivate;

  const _PreviousCyclesTile({required this.cycles, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    if (cycles.isEmpty) {
      return const _StudyCycleSheetStatus(
        icon: Icons.history_outlined,
        message: 'Sem ciclos anteriores.',
        dense: true,
      );
    }

    return AppSurface(
      padding: EdgeInsets.zero,
      color: AppColors.surfaceAlt,
      border: Border.all(color: AppColors.outline),
      shadows: const [],
      borderRadius: AppRadius.md,
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
                child: _PreviousCycleRow(
                  cycle: cycle,
                  onActivate: () => onActivate(cycle.id),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PreviousCycleRow extends StatelessWidget {
  final _StudyCycleSummary cycle;
  final VoidCallback onActivate;

  const _PreviousCycleRow({required this.cycle, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onActivate,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
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
                      cycle.title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cycle.label} • ${cycle.detail}',
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
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onActivate,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
                label: const Text('Ativar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    return AppSurface(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: dense ? 13 : 20),
      color: dense ? AppColors.surfaceAlt : AppColors.surface,
      border: Border.all(color: AppColors.outline),
      shadows: const [],
      borderRadius: AppRadius.md,
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

enum _ScheduleShift {
  morning('Manhã'),
  afternoon('Tarde'),
  night('Noite');

  final String label;

  const _ScheduleShift(this.label);
}
