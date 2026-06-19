import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../models/discipline.dart';
import '../../models/study_cycle.dart';
import '../../models/study_session.dart';
import '../../models/study_topic.dart';
import '../../models/subject_event.dart';
import '../../models/subject_note.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/study_session_repository.dart';
import '../../repositories/study_topic_repository.dart';
import '../../repositories/subject_event_repository.dart';
import '../../repositories/subject_note_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/summary_metric_tile.dart';
import 'subject_note_details_page.dart';
import 'subject_details_page.dart';

class AcademicOverviewPage extends StatefulWidget {
  final int initialTab;

  const AcademicOverviewPage({super.key, this.initialTab = 0});

  @override
  State<AcademicOverviewPage> createState() => _AcademicOverviewPageState();
}

class _AcademicOverviewPageState extends State<AcademicOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final DisciplineRepository _disciplineRepository = DisciplineRepository();
  final SubjectNoteRepository _noteRepository = SubjectNoteRepository();
  final StudyCycleRepository _studyCycleRepository = StudyCycleRepository();
  final StudySessionRepository _studySessionRepository =
      StudySessionRepository();
  final StudyTopicRepository _studyTopicRepository = StudyTopicRepository();
  final SubjectEventRepository _eventRepository = SubjectEventRepository();
  late Future<String?> _activeStudyCycleIdFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _activeStudyCycleIdFuture = _userProfileRepository
        .resolveActiveStudyCycleId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textDark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Visão Geral',
          style: TextStyle(
            color: colors.textDark,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: colors.subtleShadows,
              ),
              labelColor: colors.primary,
              unselectedLabelColor: colors.textMuted,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Progresso'),
                Tab(text: 'Anotações'),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<String?>(
        future: _activeStudyCycleIdFuture,
        builder: (context, activeCycleSnapshot) {
          if (activeCycleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (activeCycleSnapshot.hasError) {
            return const EmptyStateCard(
              icon: Icons.error_outline_rounded,
              message: 'Não foi possível carregar seu ciclo de estudos.',
            );
          }

          final activeStudyCycleId = activeCycleSnapshot.data;

          return StreamBuilder<List<StudyCycle>>(
            stream: _studyCycleRepository.watchStudyCycles(),
            builder: (context, studyCycleSnapshot) {
              final studyCycles = studyCycleSnapshot.data ?? const [];
              final activeCycle = studyCycles.where((cycle) {
                return cycle.id == activeStudyCycleId;
              }).firstOrNull;
              final isIndependent =
                  activeCycle?.type == StudyCycleType.independent;

              return TabBarView(
                controller: _tabController,
                children: [
                  if (isIndependent)
                    _IndependentProgressTab(
                      studyCycleId: activeStudyCycleId,
                      sessionRepository: _studySessionRepository,
                      topicRepository: _studyTopicRepository,
                      eventRepository: _eventRepository,
                    )
                  else
                    _AttendanceTab(
                      studyCycleId: activeStudyCycleId,
                      disciplineRepository: _disciplineRepository,
                    ),
                  _NotesTab(
                    studyCycleId: activeStudyCycleId,
                    disciplineRepository: _disciplineRepository,
                    noteRepository: _noteRepository,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  final String? studyCycleId;
  final DisciplineRepository disciplineRepository;

  const _AttendanceTab({
    required this.studyCycleId,
    required this.disciplineRepository,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return StreamBuilder<List<Discipline>>(
      stream: disciplineRepository.watchDisciplines(studyCycleId: studyCycleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const EmptyStateCard(
            icon: Icons.error_outline_rounded,
            message: 'Não foi possível carregar as faltas.',
          );
        }

        final disciplines = snapshot.data ?? [];

        if (disciplines.isEmpty) {
          return const EmptyStateCard(
            icon: Icons.menu_book_outlined,
            message: 'Nenhuma disciplina cadastrada neste ciclo.',
          );
        }

        final totalAbsences = disciplines.fold<int>(
          0,
          (sum, d) => sum + d.absences,
        );
        final warningCount = disciplines.where((d) {
          final max = d.maxAbsences > 0 ? d.maxAbsences : 12;
          return d.absences >= max * 0.8;
        }).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: SummaryMetricTile(
                        label: 'Total de Faltas',
                        value: '$totalAbsences',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryMetricTile(
                        label: 'No Limite',
                        value: '$warningCount',
                        icon: Icons.report_problem_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'CONTROLE DE FALTAS',
                style: TextStyle(
                  color: colors.textSubtle,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: disciplines.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final discipline = disciplines[index];
                  final accentColor = Color(discipline.colorValue);
                  final absences = discipline.absences;
                  final maxAbsences = discipline.maxAbsences > 0
                      ? discipline.maxAbsences
                      : 12;
                  final pct = absences / maxAbsences;
                  final pctClamped = pct.clamp(0.0, 1.0);

                  Color statusColor = colors.success;
                  if (pct >= 0.8) {
                    statusColor = colors.danger;
                  } else if (pct >= 0.5) {
                    statusColor = colors.warning;
                  }

                  return AppSurface.card(
                    padding: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SubjectDetailsPage(
                              disciplineId: discipline.id,
                              studyCycleId: discipline.studyCycleId,
                              name: discipline.name,
                              teacher: discipline.teacher,
                              average: null,
                              workload: discipline.workload,
                              colorValue: discipline.colorValue,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 60,
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
                                    discipline.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.textDark,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    discipline.teacher.isEmpty
                                        ? 'Professor não informado'
                                        : discipline.teacher,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.textMuted,
                                      fontSize: 12,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: pctClamped,
                                            minHeight: 6,
                                            backgroundColor: colors.surfaceAlt,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  statusColor,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$absences/$maxAbsences',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 13,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CircleActionButton(
                                  icon: Icons.remove,
                                  onPressed: absences > 0
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          disciplineRepository.updateAbsences(
                                            discipline.id,
                                            absences - 1,
                                          );
                                        }
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                _CircleActionButton(
                                  icon: Icons.add,
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    disciplineRepository.updateAbsences(
                                      discipline.id,
                                      absences + 1,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IndependentProgressTab extends StatelessWidget {
  final String? studyCycleId;
  final StudySessionRepository sessionRepository;
  final StudyTopicRepository topicRepository;
  final SubjectEventRepository eventRepository;

  const _IndependentProgressTab({
    required this.studyCycleId,
    required this.sessionRepository,
    required this.topicRepository,
    required this.eventRepository,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudySession>>(
      stream: sessionRepository.watchSessions(studyCycleId: studyCycleId),
      builder: (context, sessionSnapshot) {
        return StreamBuilder<List<StudyTopic>>(
          stream: topicRepository.watchTopics(studyCycleId: studyCycleId),
          builder: (context, topicSnapshot) {
            return StreamBuilder<List<SubjectEvent>>(
              stream: eventRepository.watchEvents(
                studyCycleId: studyCycleId,
                upcomingOnly: true,
              ),
              builder: (context, eventSnapshot) {
                if ((sessionSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !sessionSnapshot.hasData) ||
                    (topicSnapshot.connectionState == ConnectionState.waiting &&
                        !topicSnapshot.hasData) ||
                    (eventSnapshot.connectionState == ConnectionState.waiting &&
                        !eventSnapshot.hasData)) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (sessionSnapshot.hasError ||
                    topicSnapshot.hasError ||
                    eventSnapshot.hasError) {
                  return const EmptyStateCard(
                    icon: Icons.error_outline_rounded,
                    message: 'Não foi possível carregar seu progresso.',
                  );
                }

                final sessions = sessionSnapshot.data ?? const <StudySession>[];
                final topics = topicSnapshot.data ?? const <StudyTopic>[];
                final revisions = (eventSnapshot.data ?? const <SubjectEvent>[])
                    .where((event) => event.type == SubjectEventType.revision)
                    .toList();
                final seenTopics = topics.where((topic) => topic.isSeen).length;
                final pendingTopics = topics.length - seenTopics;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: SummaryMetricTile(
                                label: 'Horas',
                                value: _formatStudyDuration(
                                  StudySession.totalMinutes(sessions),
                                ),
                                icon: Icons.timer_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SummaryMetricTile(
                                label: 'Sessões',
                                value: '${sessions.length}',
                                icon: Icons.history_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: SummaryMetricTile(
                                label: 'Vistos',
                                value: '$seenTopics/${topics.length}',
                                icon: Icons.checklist_rtl_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SummaryMetricTile(
                                label: 'Revisões',
                                value: '${revisions.length}',
                                icon: Icons.event_repeat_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _IndependentProgressList(
                        pendingTopics: pendingTopics,
                        revisions: revisions,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatStudyDuration(int minutes) {
    if (minutes <= 0) return '0h';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) return '${remainingMinutes}min';
    if (remainingMinutes == 0) return '${hours}h';

    return '${hours}h ${remainingMinutes}min';
  }
}

class _IndependentProgressList extends StatelessWidget {
  final int pendingTopics;
  final List<SubjectEvent> revisions;

  const _IndependentProgressList({
    required this.pendingTopics,
    required this.revisions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface.card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMO DE ESTUDO',
            style: TextStyle(
              color: colors.textSubtle,
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          _ProgressSummaryRow(
            icon: Icons.checklist_rtl_outlined,
            title:
                '$pendingTopics ${pendingTopics == 1 ? 'assunto a ver' : 'assuntos a ver'}',
            subtitle: pendingTopics == 0
                ? 'Seu checklist está em dia.'
                : 'Continue avançando pelo checklist das disciplinas.',
          ),
          const SizedBox(height: 12),
          _ProgressSummaryRow(
            icon: Icons.event_repeat_outlined,
            title: revisions.isEmpty
                ? 'Sem revisões próximas'
                : '${revisions.length} ${revisions.length == 1 ? 'revisão marcada' : 'revisões marcadas'}',
            subtitle: revisions.isEmpty
                ? 'Marque revisões no calendário para fixar os assuntos.'
                : 'Próxima: ${revisions.first.displayDateTimeLabel}.',
          ),
        ],
      ),
    );
  }
}

class _ProgressSummaryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProgressSummaryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textDark,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textMuted,
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

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDisabled = onPressed == null;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDisabled
            ? colors.surfaceAlt
            : colors.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: isDisabled
              ? colors.outline
              : colors.primary.withValues(alpha: 0.16),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 18,
            color: isDisabled ? colors.textMuted : colors.primary,
          ),
        ),
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final String? studyCycleId;
  final DisciplineRepository disciplineRepository;
  final SubjectNoteRepository noteRepository;

  const _NotesTab({
    required this.studyCycleId,
    required this.disciplineRepository,
    required this.noteRepository,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return StreamBuilder<List<Discipline>>(
      stream: disciplineRepository.watchDisciplines(studyCycleId: studyCycleId),
      builder: (context, disciplineSnapshot) {
        final disciplines = disciplineSnapshot.data ?? [];
        final disciplineMap = {for (final d in disciplines) d.id: d};

        return StreamBuilder<List<SubjectNote>>(
          stream: noteRepository.watchNotes(studyCycleId: studyCycleId),
          builder: (context, noteSnapshot) {
            if (noteSnapshot.connectionState == ConnectionState.waiting &&
                !noteSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (noteSnapshot.hasError) {
              return const EmptyStateCard(
                icon: Icons.error_outline_rounded,
                message: 'Não foi possível carregar as anotações.',
              );
            }

            final notes = noteSnapshot.data ?? [];

            if (notes.isEmpty) {
              return const EmptyStateCard(
                icon: Icons.sticky_note_2_outlined,
                message: 'Nenhuma anotação criada neste ciclo.',
              );
            }

            final noteGroups = _groupNotesByDiscipline(
              notes: notes,
              disciplineMap: disciplineMap,
              fallbackColor: colors.primary,
            );

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: noteGroups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                return _NoteDisciplineSection(
                  group: noteGroups[index],
                  noteRepository: noteRepository,
                  formatDateTime: _formatDateTime,
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }

  List<_NoteDisciplineGroup> _groupNotesByDiscipline({
    required List<SubjectNote> notes,
    required Map<String, Discipline> disciplineMap,
    required Color fallbackColor,
  }) {
    final groupsByKey = <String, _NoteDisciplineGroup>{};

    for (final note in notes) {
      final discipline = disciplineMap[note.disciplineId];
      final title = _disciplineLabel(note, discipline);
      final key = discipline?.id ?? note.disciplineId ?? title.toLowerCase();

      groupsByKey.putIfAbsent(
        key,
        () => _NoteDisciplineGroup(
          title: title,
          accentColor: discipline != null
              ? Color(discipline.colorValue)
              : fallbackColor,
          notes: [],
        ),
      );
      groupsByKey[key]!.notes.add(note);
    }

    return groupsByKey.values.toList();
  }

  String _disciplineLabel(SubjectNote note, Discipline? discipline) {
    final disciplineName = discipline?.name.trim();
    if (disciplineName != null && disciplineName.isNotEmpty) {
      return disciplineName;
    }

    final noteDisciplineName = note.disciplineName.trim();
    if (noteDisciplineName.isNotEmpty) return noteDisciplineName;

    return 'Sem disciplina';
  }
}

class _NoteDisciplineGroup {
  final String title;
  final Color accentColor;
  final List<SubjectNote> notes;

  const _NoteDisciplineGroup({
    required this.title,
    required this.accentColor,
    required this.notes,
  });
}

class _NoteDisciplineSection extends StatelessWidget {
  final _NoteDisciplineGroup group;
  final SubjectNoteRepository noteRepository;
  final String Function(DateTime dt) formatDateTime;

  const _NoteDisciplineSection({
    required this.group,
    required this.noteRepository,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: group.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textDark,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${group.notes.length} ${group.notes.length == 1 ? 'anotação' : 'anotações'}',
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
        for (final entry in group.notes.indexed) ...[
          _OverviewNoteCard(
            note: entry.$2,
            accentColor: group.accentColor,
            noteRepository: noteRepository,
            formatDateTime: formatDateTime,
          ),
          if (entry.$1 != group.notes.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _OverviewNoteCard extends StatelessWidget {
  final SubjectNote note;
  final Color accentColor;
  final SubjectNoteRepository noteRepository;
  final String Function(DateTime dt) formatDateTime;

  const _OverviewNoteCard({
    required this.note,
    required this.accentColor,
    required this.noteRepository,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface.card(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          Navigator.of(context).push(
            AppRoutes.detailRoute(
              page: SubjectNoteDetailsPage(
                note: note,
                accentColor: accentColor,
                onDelete: (n) => noteRepository.deleteNote(n.id),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textDark,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        height: 1.4,
                      ),
                    ),
                    if (note.updatedAt != null || note.createdAt != null) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatDateTime(note.updatedAt ?? note.createdAt!),
                          style: TextStyle(
                            color: colors.textSubtle,
                            fontSize: 11,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
