import 'package:academic_manager_app/config/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../models/assessment.dart';
import '../../models/discipline.dart';
import '../../models/grade_summary.dart';
import '../../models/study_cycle.dart';
import '../../models/study_session.dart';
import '../../models/study_topic.dart';
import '../../models/schedule.dart';
import '../../models/subject_event.dart';
import '../../repositories/assessment_repository.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/study_session_repository.dart';
import '../../repositories/study_topic_repository.dart';
import '../../repositories/subject_event_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'subject_details_page.dart';
import 'academic_overview_page.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/inputs/search_field.dart';
import '../widgets/cards/subject_card.dart';
import '../widgets/dialogs/subject_dialog.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/list_section_header.dart';
import '../widgets/inputs/discipline_setup_list.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final _searchController = TextEditingController();
  final AssessmentRepository _assessmentRepository = AssessmentRepository();
  final DisciplineRepository _disciplineRepository = DisciplineRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final StudyCycleRepository _studyCycleRepository = StudyCycleRepository();
  final StudySessionRepository _studySessionRepository =
      StudySessionRepository();
  final StudyTopicRepository _studyTopicRepository = StudyTopicRepository();
  final SubjectEventRepository _subjectEventRepository =
      SubjectEventRepository();
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  late Future<String?> _activeStudyCycleIdFuture;

  List<Discipline> _filterDisciplines(List<Discipline> disciplines) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return disciplines;

    return disciplines.where((discipline) {
      return discipline.name.toLowerCase().contains(query) ||
          discipline.teacher.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _activeStudyCycleIdFuture = _userProfileRepository
        .resolveActiveStudyCycleId();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _openSubjectDialog() async {
    final activeStudyCycleId = await _activeStudyCycleIdFuture;
    if (activeStudyCycleId == null) {
      _showError('Configure um ciclo de estudos antes de criar disciplinas.');
      return;
    }

    final activeCycle = await _loadActiveCycle(activeStudyCycleId);
    if (activeCycle == null) return;
    if (activeCycle.type == StudyCycleType.independent) {
      await _openIndependentSubjectDialog(activeStudyCycleId);
      return;
    }

    List<SubjectScheduleEntry> unavailableScheduleEntries;
    try {
      final existingSchedules = await _scheduleRepository.fetchSchedules(
        studyCycleId: activeStudyCycleId,
      );
      unavailableScheduleEntries = _subjectScheduleEntriesFromSchedules(
        existingSchedules,
      );
    } on ScheduleRepositoryException catch (error) {
      _showError(error.message);
      return;
    } catch (_) {
      _showError('Não foi possível verificar os horários existentes.');
      return;
    }

    if (!mounted) return;

    final result = await showDialog<SubjectDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) =>
          SubjectDialog(unavailableScheduleEntries: unavailableScheduleEntries),
    );

    if (result == null || !mounted) return;

    try {
      final disciplineId = await _disciplineRepository.createDiscipline(
        DisciplineInput(
          name: result.name,
          teacher: result.teacher,
          workload: result.workload,
          maxAbsences: result.maxAbsences,
          colorValue: Schedule.colorValueForDisciplineName(result.name),
          studyCycleId: activeStudyCycleId,
        ),
      );

      for (final schedule in _groupScheduleEntries(result.schedule)) {
        await _scheduleRepository.createSchedule(
          ScheduleInput(
            studyCycleId: activeStudyCycleId,
            disciplineId: disciplineId,
            disciplineName: result.name,
            weekdays: schedule.sortedWeekdays,
            startTimeMinutes: schedule.startTimeMinutes,
            endTimeMinutes: schedule.endTimeMinutes,
            colorValue: Schedule.colorValueForDisciplineName(result.name),
          ),
        );
      }

      _showSuccess('Disciplina salva com sucesso.');
    } on DisciplineRepositoryException catch (error) {
      _showError(error.message);
    } on ScheduleRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar a disciplina. Tente novamente.');
    }
  }

  Future<StudyCycle?> _loadActiveCycle(String activeStudyCycleId) async {
    try {
      final studyCycles = await _studyCycleRepository.fetchStudyCycles();
      for (final studyCycle in studyCycles) {
        if (studyCycle.id == activeStudyCycleId) return studyCycle;
      }
    } on StudyCycleRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível carregar seu ciclo de estudos.');
    }

    return null;
  }

  Future<void> _openIndependentSubjectDialog(String activeStudyCycleId) async {
    if (!mounted) return;

    final result = await showDialog<IndependentDisciplineDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const IndependentDisciplineDialog(),
    );

    if (result == null || !mounted) return;

    try {
      final disciplineId = await _disciplineRepository.createDiscipline(
        DisciplineInput(
          name: result.name,
          teacher: '',
          workload: 0,
          maxAbsences: 12,
          colorValue: Schedule.colorValueForDisciplineName(result.name),
          studyCycleId: activeStudyCycleId,
        ),
      );

      for (final entry in result.topics.asMap().entries) {
        final topicTitle = entry.value.trim();
        if (topicTitle.isEmpty) continue;

        await _studyTopicRepository.createTopic(
          StudyTopicInput(
            studyCycleId: activeStudyCycleId,
            disciplineId: disciplineId,
            disciplineName: result.name,
            title: topicTitle,
            position: entry.key,
          ),
        );
      }

      _showSuccess('Disciplina salva com sucesso.');
    } on DisciplineRepositoryException catch (error) {
      _showError(error.message);
    } on StudyTopicRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar a disciplina. Tente novamente.');
    }
  }

  List<SubjectScheduleEntry> _subjectScheduleEntriesFromSchedules(
    List<Schedule> schedules,
  ) {
    return schedules.expand((schedule) {
      return schedule.weekdays.map((weekdayIndex) {
        return SubjectScheduleEntry(
          weekdayIndex: weekdayIndex,
          startTime: Schedule.formatMinutes(schedule.startTimeMinutes),
          endTime: Schedule.formatMinutes(schedule.endTimeMinutes),
        );
      });
    }).toList();
  }

  List<_GroupedScheduleEntry> _groupScheduleEntries(
    List<SubjectScheduleEntry> entries,
  ) {
    final groupedEntries = <String, _GroupedScheduleEntry>{};

    for (final entry in entries) {
      final key = '${entry.startTimeMinutes}:${entry.endTimeMinutes}';
      final group = groupedEntries.putIfAbsent(
        key,
        () => _GroupedScheduleEntry(
          weekdays: <int>{},
          startTimeMinutes: entry.startTimeMinutes,
          endTimeMinutes: entry.endTimeMinutes,
        ),
      );

      group.weekdays.add(entry.weekdayIndex);
    }

    return groupedEntries.values.toList();
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    final colors = context.appColors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleEditAction(_SubjectEditAction action) async {
    switch (action) {
      case _SubjectEditAction.add:
        await _openSubjectDialog();
      case _SubjectEditAction.delete:
        await _openDeleteDisciplineSheet();
    }
  }

  Future<void> _openDeleteDisciplineSheet() async {
    final activeStudyCycleId = await _activeStudyCycleIdFuture;
    if (activeStudyCycleId == null) {
      _showError('Configure um ciclo de estudos antes de excluir disciplinas.');
      return;
    }

    List<Discipline> disciplines;
    try {
      disciplines = await _disciplineRepository.fetchDisciplines(
        studyCycleId: activeStudyCycleId,
      );
    } on DisciplineRepositoryException catch (error) {
      _showError(error.message);
      return;
    } catch (_) {
      _showError('Não foi possível carregar suas disciplinas.');
      return;
    }

    if (!mounted) return;
    if (disciplines.isEmpty) {
      _showError('Nenhuma disciplina cadastrada para excluir.');
      return;
    }

    final selectedDiscipline = await showModalBottomSheet<Discipline>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteDisciplineSheet(disciplines: disciplines),
    );

    if (selectedDiscipline == null || !mounted) return;

    final shouldDelete = await _confirmDisciplineDeletion(selectedDiscipline);
    if (shouldDelete != true || !mounted) return;

    try {
      await _disciplineRepository.deleteDisciplineWithRelatedData(
        selectedDiscipline,
      );
      _showSuccess('Disciplina excluída com sucesso.');
    } on DisciplineRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível excluir a disciplina. Tente novamente.');
    }
  }

  Future<bool?> _confirmDisciplineDeletion(Discipline discipline) {
    final colors = context.appColors;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir disciplina?'),
          content: Text(
            'Isso removerá "${discipline.name}", seus horários e suas notas vinculadas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: colors.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIndependentSubjectsSection({
    required String? studyCycleId,
    required List<Discipline> allDisciplines,
    required List<Discipline> disciplines,
  }) {
    return StreamBuilder<List<StudySession>>(
      stream: _studySessionRepository.watchSessions(studyCycleId: studyCycleId),
      builder: (context, sessionSnapshot) {
        final sessions = sessionSnapshot.data ?? const <StudySession>[];

        return StreamBuilder<List<StudyTopic>>(
          stream: _studyTopicRepository.watchTopics(studyCycleId: studyCycleId),
          builder: (context, topicSnapshot) {
            final topics = topicSnapshot.data ?? const <StudyTopic>[];

            return StreamBuilder<List<SubjectEvent>>(
              stream: _subjectEventRepository.watchEvents(
                studyCycleId: studyCycleId,
                upcomingOnly: true,
              ),
              builder: (context, eventSnapshot) {
                final revisions = (eventSnapshot.data ?? const <SubjectEvent>[])
                    .where((event) => event.type == SubjectEventType.revision)
                    .toList();
                final seenTopics = topics
                    .where((topic) => topic.status == StudyTopicStatus.seen)
                    .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IndependentSubjectsOverview(
                      total: allDisciplines.length,
                      hoursLabel: _formatStudyDuration(
                        StudySession.totalMinutes(sessions),
                      ),
                      topicProgress: '$seenTopics/${topics.length}',
                      revisionCount: revisions.length,
                    ),
                    const SizedBox(height: 16),
                    SearchField(
                      controller: _searchController,
                      hint: 'Pesquise por disciplina',
                      height: 48,
                    ),
                    const SizedBox(height: 16),
                    ListSectionHeader(
                      label: 'MINHAS DISCIPLINAS',
                      count: disciplines.length,
                      trailing: _EditSubjectsButton(
                        onSelected: _handleEditAction,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (disciplines.isEmpty)
                      EmptyStateCard(
                        message: allDisciplines.isEmpty
                            ? 'Nenhuma disciplina criada ainda.'
                            : 'Nenhuma disciplina encontrada.',
                        icon: allDisciplines.isEmpty
                            ? Icons.menu_book_outlined
                            : Icons.search_off_outlined,
                      )
                    else
                      ...disciplines.map((discipline) {
                        final disciplineSessions = sessions
                            .where(
                              (session) => _belongsToDiscipline(
                                entityDisciplineId: session.disciplineId,
                                entityDisciplineName: session.disciplineName,
                                discipline: discipline,
                              ),
                            )
                            .toList();
                        final disciplineTopics = topics
                            .where(
                              (topic) => _belongsToDiscipline(
                                entityDisciplineId: topic.disciplineId,
                                entityDisciplineName: topic.disciplineName,
                                discipline: discipline,
                              ),
                            )
                            .toList();
                        final disciplineRevisions = revisions
                            .where(
                              (event) => _belongsToDiscipline(
                                entityDisciplineId: event.disciplineId,
                                entityDisciplineName: event.disciplineName,
                                discipline: discipline,
                              ),
                            )
                            .toList();
                        final seen = disciplineTopics
                            .where(
                              (topic) => topic.status == StudyTopicStatus.seen,
                            )
                            .length;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _IndependentSubjectCard(
                            name: discipline.name,
                            hoursLabel: _formatStudyDuration(
                              StudySession.totalMinutes(disciplineSessions),
                            ),
                            topicProgress: '$seen/${disciplineTopics.length}',
                            nextRevisionLabel: disciplineRevisions.isEmpty
                                ? 'Sem revisão marcada'
                                : disciplineRevisions.first.displayDateLabel,
                            accentColor: Color(discipline.colorValue),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SubjectDetailsPage(
                                    disciplineId: discipline.id,
                                    studyCycleId: discipline.studyCycleId,
                                    name: discipline.name,
                                    teacher: '',
                                    average: null,
                                    workload: 0,
                                    colorValue: discipline.colorValue,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    if (sessionSnapshot.hasError ||
                        topicSnapshot.hasError ||
                        eventSnapshot.hasError) ...[
                      const SizedBox(height: 4),
                      const EmptyStateCard(
                        icon: Icons.info_outline_rounded,
                        message:
                            'Alguns dados de estudo não puderam carregar agora.',
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  bool _belongsToDiscipline({
    required String? entityDisciplineId,
    required String entityDisciplineName,
    required Discipline discipline,
  }) {
    final normalizedId = entityDisciplineId?.trim();
    if (normalizedId != null && normalizedId.isNotEmpty) {
      return normalizedId == discipline.id;
    }

    return _normalizedText(entityDisciplineName) ==
        _normalizedText(discipline.name);
  }

  String _normalizedText(String value) {
    return value.trim().toLowerCase();
  }

  String _formatStudyDuration(int minutes) {
    if (minutes <= 0) return '0h';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) return '${remainingMinutes}min';
    if (remainingMinutes == 0) return '${hours}h';

    return '${hours}h ${remainingMinutes}min';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: const AppScrollBehavior(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SubjectsHeader(),

                    const SizedBox(height: 18),

                    FutureBuilder<String?>(
                      future: _activeStudyCycleIdFuture,
                      builder: (context, activeCycleSnapshot) {
                        if (activeCycleSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _SubjectsLoadingState();
                        }

                        if (activeCycleSnapshot.hasError) {
                          return const EmptyStateCard(
                            icon: Icons.error_outline_rounded,
                            message:
                                'Não foi possível carregar seu ciclo de estudos.',
                          );
                        }

                        final activeStudyCycleId = activeCycleSnapshot.data;

                        return StreamBuilder<List<StudyCycle>>(
                          stream: _studyCycleRepository.watchStudyCycles(),
                          builder: (context, studyCycleSnapshot) {
                            final studyCycles =
                                studyCycleSnapshot.data ?? const [];
                            final activeCycle = studyCycles.firstWhere(
                              (c) => c.id == activeStudyCycleId,
                              orElse: () => StudyCycle(
                                id: activeStudyCycleId ?? '',
                                type: StudyCycleType.independent,
                                passingGrade: 7.0,
                              ),
                            );
                            final passingGrade = activeCycle.passingGrade;

                            return StreamBuilder<List<Discipline>>(
                              stream: _disciplineRepository.watchDisciplines(
                                studyCycleId: activeStudyCycleId,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    !snapshot.hasData) {
                                  return const _SubjectsLoadingState();
                                }

                                if (snapshot.hasError) {
                                  return const EmptyStateCard(
                                    icon: Icons.error_outline_rounded,
                                    message:
                                        'Não foi possível carregar suas disciplinas agora.',
                                  );
                                }

                                final allDisciplines = snapshot.data ?? [];
                                final disciplines = _filterDisciplines(
                                  allDisciplines,
                                );

                                if (activeCycle.type ==
                                    StudyCycleType.independent) {
                                  return _buildIndependentSubjectsSection(
                                    studyCycleId: activeStudyCycleId,
                                    allDisciplines: allDisciplines,
                                    disciplines: disciplines,
                                  );
                                }

                                return StreamBuilder<List<Assessment>>(
                                  stream: _assessmentRepository
                                      .watchAssessments(
                                        studyCycleId: activeStudyCycleId,
                                      ),
                                  builder: (context, assessmentSnapshot) {
                                    final assessments =
                                        assessmentSnapshot.data ?? const [];
                                    final stats = GradeSummary.calculate(
                                      disciplines: allDisciplines,
                                      assessments: assessments,
                                      passingGrade: passingGrade,
                                    );

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _SubjectsOverview(
                                          total: allDisciplines.length,
                                          gradeCount: stats.totalGrades,
                                          riskCount: stats.countByStatus(
                                            GradeStatus.risk,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SearchField(
                                          controller: _searchController,
                                          hint: 'Pesquise por disciplina',
                                          height: 48,
                                        ),
                                        const SizedBox(height: 16),
                                        ListSectionHeader(
                                          label: 'MINHAS DISCIPLINAS',
                                          count: disciplines.length,
                                          trailing: _EditSubjectsButton(
                                            onSelected: _handleEditAction,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        if (disciplines.isEmpty)
                                          EmptyStateCard(
                                            message: allDisciplines.isEmpty
                                                ? 'Nenhuma disciplina criada ainda.'
                                                : 'Nenhuma disciplina encontrada.',
                                            icon: allDisciplines.isEmpty
                                                ? Icons.menu_book_outlined
                                                : Icons.search_off_outlined,
                                          )
                                        else
                                          ...disciplines.map(
                                            (discipline) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: SubjectCard(
                                                name: discipline.name,
                                                teacher:
                                                    discipline.teacher.isEmpty
                                                    ? 'Professor não informado'
                                                    : discipline.teacher,
                                                frequency: 0,
                                                showFrequency: false,
                                                average: stats.averageFor(
                                                  discipline.id,
                                                ),
                                                passingGrade: passingGrade,
                                                workload: discipline.workload,
                                                accentColor: Color(
                                                  discipline.colorValue,
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          SubjectDetailsPage(
                                                            disciplineId:
                                                                discipline.id,
                                                            studyCycleId:
                                                                discipline
                                                                    .studyCycleId,
                                                            name:
                                                                discipline.name,
                                                            teacher:
                                                                discipline
                                                                    .teacher
                                                                    .isEmpty
                                                                ? 'Professor não informado'
                                                                : discipline
                                                                      .teacher,
                                                            average: stats
                                                                .averageFor(
                                                                  discipline.id,
                                                                ),
                                                            workload: discipline
                                                                .workload,
                                                            colorValue:
                                                                discipline
                                                                    .colorValue,
                                                          ),
                                                    ),
                                                  );
                                                },
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditSubjectsButton extends StatelessWidget {
  final ValueChanged<_SubjectEditAction> onSelected;

  const _EditSubjectsButton({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return PopupMenuButton<_SubjectEditAction>(
      tooltip: 'Editar disciplinas',
      onSelected: onSelected,
      color: colors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _SubjectEditAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: colors.danger, size: 20),
              const SizedBox(width: 10),
              Text(
                'Excluir Disciplina',
                style: TextStyle(color: colors.textDark),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: _SubjectEditAction.add,
          child: Row(
            children: [
              Icon(Icons.add, color: colors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Adicionar Nova Disciplina',
                style: TextStyle(color: colors.textDark),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.primary.withValues(alpha: 0.20)),
        ),
        child: Text(
          'Editar',
          style: TextStyle(
            color: colors.primary,
            fontSize: 12,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SubjectsHeader extends StatelessWidget {
  const _SubjectsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: colors.subtleShadows,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink.image(
              image: const AssetImage('lib/view/assets/profile_pic_v2.png'),
              fit: BoxFit.cover,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => AppRoutes.toProfile(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Suas Disciplinas',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textDark,
              fontSize: 26,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _AcademicOverviewMenuButton(),
      ],
    );
  }
}

class _DeleteDisciplineSheet extends StatelessWidget {
  final List<Discipline> disciplines;

  const _DeleteDisciplineSheet({required this.disciplines});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: AppSurface.card(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        borderRadius: AppRadius.xl,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Excluir disciplina',
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 22,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: colors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Escolha qual disciplina deseja remover.',
                style: TextStyle(
                  color: colors.textMedium,
                  fontSize: 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: disciplines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final discipline = disciplines[index];
                    final teacher = discipline.teacher.isEmpty
                        ? 'Professor não informado'
                        : discipline.teacher;

                    return Material(
                      color: colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        onTap: () => Navigator.of(context).pop(discipline),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.primary.withValues(
                                      alpha: 0.28,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.menu_book_outlined,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                        fontSize: 15,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      teacher,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.textMedium,
                                        fontSize: 12,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.delete_outline, color: colors.danger),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectsOverview extends StatelessWidget {
  final int total;
  final int gradeCount;
  final int riskCount;

  const _SubjectsOverview({
    required this.total,
    required this.gradeCount,
    required this.riskCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface.card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shadows: colors.subtleShadows,
      child: Row(
        children: [
          Expanded(
            child: _SubjectMetric(
              label: 'Disciplinas',
              value: '$total',
              icon: Icons.menu_book_outlined,
            ),
          ),
          _MetricDivider(color: colors.divider),
          Expanded(
            child: _SubjectMetric(
              label: 'Notas',
              value: '$gradeCount',
              icon: Icons.fact_check_outlined,
            ),
          ),
          _MetricDivider(color: colors.divider),
          Expanded(
            child: _SubjectMetric(
              label: 'Em risco',
              value: '$riskCount',
              icon: Icons.warning_amber_rounded,
              valueColor: riskCount > 0 ? colors.danger : colors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndependentSubjectsOverview extends StatelessWidget {
  final int total;
  final String hoursLabel;
  final String topicProgress;
  final int revisionCount;

  const _IndependentSubjectsOverview({
    required this.total,
    required this.hoursLabel,
    required this.topicProgress,
    required this.revisionCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface.card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shadows: colors.subtleShadows,
      child: Row(
        children: [
          Expanded(
            child: _SubjectMetric(
              label: 'Disciplinas',
              value: '$total',
              icon: Icons.menu_book_outlined,
            ),
          ),
          _MetricDivider(color: colors.divider),
          Expanded(
            child: _SubjectMetric(
              label: 'Horas',
              value: hoursLabel,
              icon: Icons.timer_outlined,
            ),
          ),
          _MetricDivider(color: colors.divider),
          Expanded(
            child: _SubjectMetric(
              label: 'Assuntos',
              value: topicProgress,
              icon: Icons.checklist_rtl_outlined,
            ),
          ),
          _MetricDivider(color: colors.divider),
          Expanded(
            child: _SubjectMetric(
              label: 'Revisões',
              value: '$revisionCount',
              icon: Icons.event_repeat_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndependentSubjectCard extends StatelessWidget {
  final String name;
  final String hoursLabel;
  final String topicProgress;
  final String nextRevisionLabel;
  final Color accentColor;
  final VoidCallback? onTap;

  const _IndependentSubjectCard({
    required this.name,
    required this.hoursLabel,
    required this.topicProgress,
    required this.nextRevisionLabel,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AppSurface.card(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shadows: colors.subtleShadows,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 5,
                child: ColoredBox(color: accentColor),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 14, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_stories_outlined,
                        color: accentColor,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textDark,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w900,
                              height: 1.14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _IndependentSubjectChip(
                                icon: Icons.timer_outlined,
                                label: hoursLabel,
                                color: accentColor,
                              ),
                              _IndependentSubjectChip(
                                icon: Icons.checklist_rtl_outlined,
                                label: '$topicProgress vistos',
                                color: colors.success,
                              ),
                              _IndependentSubjectChip(
                                icon: Icons.event_repeat_outlined,
                                label: nextRevisionLabel,
                                color: colors.event,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _IndependentSubjectChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _IndependentSubjectChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
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

class _SubjectMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _SubjectMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.primary, size: 18),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor ?? colors.textDark,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textMedium,
                  fontSize: 10.5,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  final Color color;

  const _MetricDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: color);
  }
}

class _SubjectsLoadingState extends StatelessWidget {
  const _SubjectsLoadingState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(child: CircularProgressIndicator(color: colors.primary)),
    );
  }
}

class _GroupedScheduleEntry {
  final Set<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;

  const _GroupedScheduleEntry({
    required this.weekdays,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
  });

  List<int> get sortedWeekdays => weekdays.toList()..sort();
}

enum _SubjectEditAction { delete, add }

class _AcademicOverviewMenuButton extends StatelessWidget {
  const _AcademicOverviewMenuButton();

  void _openAcademicOverviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = sheetContext.appColors;
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Menu Acadêmico',
                        style: TextStyle(
                          color: colors.textDark,
                          fontSize: 22,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: Icon(Icons.close, color: colors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppSurface.soft(
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AcademicOverviewPage(initialTab: 0),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.assessment_outlined,
                              color: colors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Visão Geral de Progresso e Anotações',
                                  style: TextStyle(
                                    color: colors.textDark,
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Acompanhe estudos, faltas e anotações das disciplinas',
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
                          Icon(Icons.chevron_right, color: colors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Tooltip(
      message: 'Menu Acadêmico',
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () => _openAcademicOverviewSheet(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.outline),
              boxShadow: colors.subtleShadows,
            ),
            child: Icon(Icons.menu_rounded, color: colors.primary, size: 26),
          ),
        ),
      ),
    );
  }
}
