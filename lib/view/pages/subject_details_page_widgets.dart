part of 'subject_details_page.dart';

LinearGradient _disciplineSurfaceGradient({
  required BuildContext context,
  required AppThemeColors colors,
  required Color accentColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  if (isDark) {
    final glow = Color.alphaBlend(
      accentColor.withValues(alpha: 0.052),
      colors.surface,
    );
    final whisper = Color.alphaBlend(
      accentColor.withValues(alpha: 0.026),
      colors.surface,
    );
    final fade = Color.alphaBlend(
      accentColor.withValues(alpha: 0.010),
      colors.surface,
    );

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [glow, whisper, fade, colors.surface],
      stops: const [0.0, 0.30, 0.68, 1.0],
    );
  }

  final glow = Color.alphaBlend(
    accentColor.withValues(alpha: 0.050),
    colors.surface,
  );
  final whisper = Color.alphaBlend(
    accentColor.withValues(alpha: 0.020),
    colors.surface,
  );
  final fade = Color.alphaBlend(
    accentColor.withValues(alpha: 0.006),
    colors.surface,
  );

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glow, whisper, fade, colors.surface],
    stops: const [0.0, 0.24, 0.58, 1.0],
  );
}

class _DisciplineAccentMark extends StatelessWidget {
  final Color accentColor;

  const _DisciplineAccentMark({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 54,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? accentColor : null,
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.82),
                  accentColor.withValues(alpha: 0.46),
                ],
              ),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.textDark,
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
                color: colors.textDark,
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
  final double? average;
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
    final colors = context.appColors;

    return AppSurface.card(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      gradient: _disciplineSurfaceGradient(
        context: context,
        colors: colors,
        accentColor: accentColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DisciplineAccentMark(accentColor: accentColor),
          const SizedBox(height: 14),
          Row(
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
                                style: TextStyle(
                                  color: colors.textDark,
                                  fontSize: 22,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  height: 1.12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: colors.textMuted,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      teacher,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.textMuted,
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
                          foregroundColor: accentColor,
                          backgroundColor: accentColor.withValues(alpha: 0.08),
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
        ],
      ),
    );
  }
}

class _AverageRing extends StatelessWidget {
  final double? average;

  const _AverageRing({required this.average});

  Color _statusColor(AppThemeColors colors) {
    if (average == null) return colors.textMuted;
    if (average! >= 7) return colors.success;
    if (average! >= 5) return colors.warning;
    return colors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
                    value: average == null
                        ? 0.0
                        : (average! / 10).clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: colors.surfaceAlt,
                    color: _statusColor(colors),
                  ),
                ),
                Text(
                  average == null ? '—' : average!.toStringAsFixed(1),
                  style: TextStyle(
                    color: colors.textDark,
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
          Text(
            'Média',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
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
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colors.textDark,
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
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colors.primary, size: 18),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: colors.primary,
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
    final colors = context.appColors;

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
                      style: TextStyle(
                        color: colors.textDark,
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
                          foregroundColor: accentColor,
                          backgroundColor: accentColor.withValues(alpha: 0.08),
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
                          foregroundColor: colors.primary,
                          backgroundColor: colors.primary.withValues(
                            alpha: 0.08,
                          ),
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
                        style: TextStyle(
                          color: colors.textMuted,
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
              Icon(Icons.chevron_right, color: colors.textMuted),
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
    final colors = context.appColors;

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
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  assessment.displayDateLabel,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _GradeBadge(
            label: assessment.formattedGrade,
            grade: assessment.grade,
          ),
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
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 64,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textDark,
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
                      style: TextStyle(
                        color: colors.textMuted,
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
              Icon(Icons.chevron_right, color: colors.textMuted),
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
    final colors = context.appColors;

    return Opacity(
      opacity: task.isChecked ? 0.6 : 1.0,
      child: Material(
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
                          color: colors.textDark,
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
                            foregroundColor: colors.textMedium,
                            backgroundColor: colors.surfaceAlt,
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
                            foregroundColor: task.isChecked
                                ? colors.success
                                : colors.warning,
                            backgroundColor: task.isChecked
                                ? colors.success.withValues(alpha: 0.08)
                                : colors.warning.withValues(alpha: 0.08),
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
                Icon(Icons.chevron_right, color: colors.textMuted),
              ],
            ),
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
    final colors = context.appColors;

    return _PanelCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          children: [
            const SizedBox(width: 2),
            Icon(icon, color: colors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.textDark,
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
    final colors = context.appColors;

    return Divider(
      height: 1,
      thickness: 1,
      color: colors.divider,
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
  final double grade;

  const _GradeBadge({required this.label, required this.grade});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final badgeColor = grade >= 7
        ? colors.success
        : grade >= 5
        ? colors.warning
        : colors.danger;

    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.32),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: badgeColor,
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AttendanceManagementCard extends StatelessWidget {
  final Discipline discipline;
  final Color accentColor;
  final ValueChanged<int> onUpdateAbsences;
  final ValueChanged<int> onUpdateMaxAbsences;

  const _AttendanceManagementCard({
    required this.discipline,
    required this.accentColor,
    required this.onUpdateAbsences,
    required this.onUpdateMaxAbsences,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final absences = discipline.absences;
    final maxAbsences = discipline.maxAbsences > 0
        ? discipline.maxAbsences
        : 12;
    final pct = absences / maxAbsences;
    final pctClamped = pct.clamp(0.0, 1.0);

    Color progressColor = colors.success;
    String riskLabel = 'Frequência regular';
    if (pct >= 0.8) {
      progressColor = colors.danger;
      riskLabel = 'Perigo: limite de faltas!';
    } else if (pct >= 0.5) {
      progressColor = colors.warning;
      riskLabel = 'Atenção: faltas elevadas';
    }

    return AppSurface.card(
      padding: const EdgeInsets.all(16),
      gradient: _disciplineSurfaceGradient(
        context: context,
        colors: colors,
        accentColor: accentColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DisciplineAccentMark(accentColor: accentColor),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Presenças e Faltas',
                style: TextStyle(
                  color: colors.textDark,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: colors.textMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ajustar',
                        style: TextStyle(
                          color: colors.textMedium,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$absences',
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 32,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ $maxAbsences faltas permitidas',
                    style: TextStyle(
                      color: colors.textLight,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                riskLabel,
                style: TextStyle(
                  color: progressColor,
                  fontSize: 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pctClamped,
              minHeight: 8,
              backgroundColor: colors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _PresenceActionButton(
                label: '-1',
                accentColor: accentColor,
                onPressed: absences > 0
                    ? () {
                        HapticFeedback.lightImpact();
                        onUpdateAbsences(absences - 1);
                      }
                    : null,
                isNegative: true,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _PresenceActionButton(
                        label: '+1',
                        accentColor: accentColor,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onUpdateAbsences(absences + 1);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _PresenceActionButton(
                        label: '+2',
                        accentColor: accentColor,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onUpdateAbsences(absences + 2);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _PresenceActionButton(
                        label: '+3',
                        accentColor: accentColor,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onUpdateAbsences(absences + 3);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _PresenceActionButton(
                        label: '+4',
                        accentColor: accentColor,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onUpdateAbsences(absences + 4);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final colors = context.appColors;
    final absencesController = TextEditingController(
      text: discipline.absences.toString(),
    );
    final maxAbsencesController = TextEditingController(
      text: discipline.maxAbsences.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'Ajustar Presença',
            style: TextStyle(
              color: colors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: absencesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Faltas atuais',
                    labelStyle: TextStyle(color: colors.textMedium),
                    hintText: 'Ex: 4',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe as faltas.';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val < 0) return 'Valor inválido.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: maxAbsencesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Limite máximo de faltas',
                    labelStyle: TextStyle(color: colors.textMedium),
                    hintText: 'Ex: 12',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o limite.';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'O limite deve ser maior que 0.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colors.textMedium),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final newAbsences = int.parse(absencesController.text);
                final newMax = int.parse(maxAbsencesController.text);
                onUpdateAbsences(newAbsences);
                onUpdateMaxAbsences(newMax);
                Navigator.of(dialogContext).pop();
              },
              style: FilledButton.styleFrom(backgroundColor: colors.primary),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}

class _PresenceActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isNegative;
  final Color accentColor;

  const _PresenceActionButton({
    required this.label,
    required this.onPressed,
    required this.accentColor,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDisabled = onPressed == null;
    final backgroundColor = isDisabled
        ? colors.surfaceAlt
        : isNegative
        ? colors.surfaceAlt
        : accentColor.withValues(alpha: 0.08);
    final borderColor = isDisabled
        ? colors.outline
        : isNegative
        ? colors.outlineStrong
        : accentColor.withValues(alpha: 0.24);
    final foregroundColor = isDisabled
        ? colors.textMuted
        : isNegative
        ? colors.textMedium
        : accentColor;

    return SizedBox(
      height: 40,
      width: isNegative ? 64 : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
