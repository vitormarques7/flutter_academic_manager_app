part of 'subject_details_page.dart';

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4FF), width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
              size: 28,
            ),
            tooltip: 'Voltar',
          ),
          Expanded(
            child: Text(
              'Detalhes da disciplina',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headline3.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}

class _SubjectSummaryCard extends StatelessWidget {
  final String name;
  final String teacher;
  final double average;
  final int workload;
  final int gradeCount;
  final int pendingTaskCount;
  final Color accentColor;

  const _SubjectSummaryCard({
    required this.name,
    required this.teacher,
    required this.average,
    required this.workload,
    required this.gradeCount,
    required this.pendingTaskCount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      gradient: AppGradients.softSurface,
      border: Border.all(color: AppColors.outline),
      shadows: AppShadows.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconTile(
                      icon: Icons.menu_book_outlined,
                      color: accentColor,
                      size: 52,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 22,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  teacher,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
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
                      icon: Icons.access_time,
                      label: '${workload}h',
                      iconSize: 15,
                      maxWidth: 150,
                    ),
                    MetadataChip(
                      icon: Icons.fact_check_outlined,
                      label:
                          '$gradeCount ${gradeCount == 1 ? 'nota' : 'notas'}',
                      iconSize: 15,
                      maxWidth: 180,
                    ),
                    MetadataChip(
                      icon: Icons.pending_actions_outlined,
                      label:
                          '$pendingTaskCount ${pendingTaskCount == 1 ? 'pendente' : 'pendentes'}',
                      iconSize: 15,
                      maxWidth: 160,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AverageRing(average: average),
        ],
      ),
    );
  }
}

class _AverageRing extends StatelessWidget {
  final double average;

  const _AverageRing({required this.average});

  Color get _statusColor {
    if (average >= 7) return const Color(0xFF16A34A);
    if (average >= 5) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: Column(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    value: (average / 10).clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: AppColors.surface,
                    color: _statusColor,
                  ),
                ),
                Text(
                  average.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 25,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Média',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              height: 1.12,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}

class _InlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _InlineActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectEventsPanel extends StatelessWidget {
  final List<SubjectEvent> events;
  final bool isLoading;
  final bool hasError;
  final Color accentColor;
  final ValueChanged<SubjectEvent> onOpen;

  const _SubjectEventsPanel({
    required this.events,
    required this.isLoading,
    required this.hasError,
    required this.accentColor,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _StatusPanel(
        icon: Icons.hourglass_top_rounded,
        message: 'Carregando eventos...',
      );
    }

    if (hasError) {
      return const _StatusPanel(
        icon: Icons.error_outline_rounded,
        message: 'Não foi possível carregar os eventos.',
      );
    }

    if (events.isEmpty) {
      return const _StatusPanel(
        icon: Icons.event_busy_outlined,
        message: 'Nenhum evento futuro para esta disciplina.',
      );
    }

    return _PanelCard(
      child: Column(
        children: [
          for (final entry in events.indexed) ...[
            _SubjectEventRow(
              event: entry.$2,
              accentColor: accentColor,
              onTap: () => onOpen(entry.$2),
            ),
            if (entry.$1 != events.length - 1) const _PanelDivider(),
          ],
        ],
      ),
    );
  }
}

class _SubjectEventRow extends StatelessWidget {
  final SubjectEvent event;
  final Color accentColor;
  final VoidCallback onTap;

  const _SubjectEventRow({
    required this.event,
    required this.accentColor,
    required this.onTap,
  });

  IconData get _typeIcon {
    return switch (event.type) {
      SubjectEventType.exam => Icons.edit_square,
      SubjectEventType.lecture => Icons.record_voice_over_outlined,
      SubjectEventType.seminar => Icons.co_present_outlined,
      SubjectEventType.deadline => Icons.assignment_turned_in_outlined,
      SubjectEventType.extraClass => Icons.school_outlined,
      SubjectEventType.other => Icons.event_note_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconTile(icon: _typeIcon, color: accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        MetadataChip(
                          icon: Icons.calendar_today_outlined,
                          label: event.displayDateLabel,
                          iconSize: 13,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          maxWidth: 150,
                        ),
                        MetadataChip(
                          icon: _typeIcon,
                          label: event.type.label,
                          iconSize: 13,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          maxWidth: 160,
                        ),
                      ],
                    ),
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentsPanel extends StatelessWidget {
  final List<Assessment> assessments;
  final bool isLoading;
  final bool hasError;
  final Color accentColor;
  final VoidCallback onAdd;
  final ValueChanged<Assessment> onDelete;

  const _AssessmentsPanel({
    required this.assessments,
    required this.isLoading,
    required this.hasError,
    required this.accentColor,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _StatusPanel(
        icon: Icons.hourglass_top_rounded,
        message: 'Carregando notas...',
      );
    }

    if (hasError) {
      return const _StatusPanel(
        icon: Icons.error_outline_rounded,
        message: 'Não foi possível carregar as notas.',
      );
    }

    if (assessments.isEmpty) {
      return const _StatusPanel(
        icon: Icons.fact_check_outlined,
        message: 'Nenhuma nota cadastrada ainda.',
      );
    }

    return _PanelCard(
      child: Column(
        children: [
          for (final entry in assessments.indexed) ...[
            _AssessmentRow(
              assessment: entry.$2,
              accentColor: accentColor,
              onDelete: () => onDelete(entry.$2),
            ),
            if (entry.$1 != assessments.length - 1) const _PanelDivider(),
          ],
        ],
      ),
    );
  }
}

class _AssessmentRow extends StatelessWidget {
  final Assessment assessment;
  final Color accentColor;
  final VoidCallback onDelete;

  const _AssessmentRow({
    required this.assessment,
    required this.accentColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Row(
        children: [
          _IconTile(icon: Icons.description_outlined, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assessment.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  assessment.displayDateLabel,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _GradeBadge(label: assessment.formattedGrade),
          IconButton(
            tooltip: 'Excluir nota',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Color(0xFF9A2828)),
          ),
        ],
      ),
    );
  }
}

class _RelatedTasksPanel extends StatelessWidget {
  final List<AcademicTask> tasks;
  final bool isLoading;
  final bool hasError;
  final Color accentColor;
  final VoidCallback onOpenTasks;

  const _RelatedTasksPanel({
    required this.tasks,
    required this.isLoading,
    required this.hasError,
    required this.accentColor,
    required this.onOpenTasks,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _StatusPanel(
        icon: Icons.hourglass_top_rounded,
        message: 'Carregando tarefas...',
      );
    }

    if (hasError) {
      return const _StatusPanel(
        icon: Icons.error_outline_rounded,
        message: 'Não foi possível carregar as tarefas.',
      );
    }

    if (tasks.isEmpty) {
      return const _StatusPanel(
        icon: Icons.assignment_outlined,
        message: 'Nenhuma tarefa ligada a esta disciplina.',
      );
    }

    return _PanelCard(
      child: Column(
        children: [
          for (final entry in tasks.indexed) ...[
            _TaskRow(
              task: entry.$2,
              accentColor: accentColor,
              onTap: onOpenTasks,
            ),
            if (entry.$1 != tasks.length - 1) const _PanelDivider(),
          ],
        ],
      ),
    );
  }
}

class _SubjectNotesPanel extends StatelessWidget {
  final List<SubjectNote> notes;
  final bool isLoading;
  final bool hasError;
  final Color accentColor;
  final ValueChanged<SubjectNote> onOpen;

  const _SubjectNotesPanel({
    required this.notes,
    required this.isLoading,
    required this.hasError,
    required this.accentColor,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _StatusPanel(
        icon: Icons.hourglass_top_rounded,
        message: 'Carregando anotações...',
      );
    }

    if (hasError) {
      return const _StatusPanel(
        icon: Icons.error_outline_rounded,
        message: 'Não foi possível carregar as anotações.',
      );
    }

    if (notes.isEmpty) {
      return const _StatusPanel(
        icon: Icons.sticky_note_2_outlined,
        message: 'Nenhuma anotação para esta disciplina.',
      );
    }

    return _PanelCard(
      child: Column(
        children: [
          for (final entry in notes.indexed) ...[
            _SubjectNoteRow(
              note: entry.$2,
              accentColor: accentColor,
              onTap: () => onOpen(entry.$2),
            ),
            if (entry.$1 != notes.length - 1) const _PanelDivider(),
          ],
        ],
      ),
    );
  }
}

class _SubjectNoteRow extends StatelessWidget {
  final SubjectNote note;
  final Color accentColor;
  final VoidCallback onTap;

  const _SubjectNoteRow({
    required this.note,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconTile(icon: Icons.sticky_note_2_outlined, color: accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      note.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final AcademicTask task;
  final Color accentColor;
  final VoidCallback onTap;

  const _TaskRow({
    required this.task,
    required this.accentColor,
    required this.onTap,
  });

  IconData get _typeIcon {
    return switch (task.visualPriority) {
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _IconTile(icon: _typeIcon, color: accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        decoration: task.isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        MetadataChip(
                          icon: Icons.access_time,
                          label: task.deadlineLabel,
                          iconSize: 13,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          maxWidth: 160,
                        ),
                        MetadataChip(
                          icon: task.isChecked
                              ? Icons.check_circle_outline
                              : Icons.pending_actions_outlined,
                          label: task.isChecked ? 'Concluída' : 'Pendente',
                          iconSize: 13,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          maxWidth: 160,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final Widget child;

  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AppSurface.card(
      width: double.infinity,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final IconData icon;
  final String message;

  const _StatusPanel({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          children: [
            const SizedBox(width: 2),
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelDivider extends StatelessWidget {
  const _PanelDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE2E4F0),
      indent: 12,
      endIndent: 12,
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconTile({required this.icon, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Icon(icon, color: color, size: size * 0.56),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final String label;

  const _GradeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
