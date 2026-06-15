import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../models/discipline.dart';
import '../../models/subject_note.dart';
import '../../repositories/discipline_repository.dart';
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
  late Future<String?> _activeStudyCycleIdFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _activeStudyCycleIdFuture = _userProfileRepository.resolveActiveStudyCycleId();
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
                Tab(text: 'Faltas e Presenças'),
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

          return TabBarView(
            controller: _tabController,
            children: [
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
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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

        final totalAbsences = disciplines.fold<int>(0, (sum, d) => sum + d.absences);
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
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final discipline = disciplines[index];
                  final accentColor = Color(discipline.colorValue);
                  final absences = discipline.absences;
                  final maxAbsences = discipline.maxAbsences > 0 ? discipline.maxAbsences : 12;
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: pctClamped,
                                            minHeight: 6,
                                            backgroundColor: colors.surfaceAlt,
                                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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
            if (noteSnapshot.connectionState == ConnectionState.waiting && !noteSnapshot.hasData) {
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

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = notes[index];
                final discipline = disciplineMap[note.disciplineId];
                final accentColor = discipline != null
                    ? Color(discipline.colorValue)
                    : colors.primary;

                return AppSurface.card(
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SubjectNoteDetailsPage(
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
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: accentColor.withValues(alpha: 0.24),
                                        ),
                                      ),
                                      child: Text(
                                        note.disciplineName.isEmpty
                                            ? 'Sem Disciplina'
                                            : note.disciplineName,
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 11,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (note.updatedAt != null || note.createdAt != null)
                                      Text(
                                        _formatDateTime(note.updatedAt ?? note.createdAt!),
                                        style: TextStyle(
                                          color: colors.textSubtle,
                                          fontSize: 11,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
}
