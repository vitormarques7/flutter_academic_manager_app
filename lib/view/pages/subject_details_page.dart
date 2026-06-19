import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/routes/app_routes.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../models/academic_task.dart';
import '../../models/assessment.dart';
import '../../models/discipline.dart';
import '../../models/grade_summary.dart';
import '../../models/study_cycle.dart';
import '../../models/study_session.dart';
import '../../models/study_topic.dart';
import '../../models/subject_event.dart';
import '../../models/subject_note.dart';
import '../../repositories/assessment_repository.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/study_session_repository.dart';
import '../../repositories/study_topic_repository.dart';
import '../../repositories/subject_event_repository.dart';
import '../../repositories/subject_note_repository.dart';
import '../../repositories/task_repository.dart';
import '../widgets/common/app_bottom_nav_bar.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/metadata_chip.dart';
import '../widgets/dialogs/task_dialog.dart';
import '../widgets/inputs/date_picker_field.dart';
import '../widgets/inputs/time_range_picker_field.dart';
import 'task_details_page.dart';
import 'subject_event_details_page.dart';
import 'subject_note_details_page.dart';

part 'subject_details_page_widgets.dart';
part 'subject_details_page_dialogs.dart';

class SubjectDetailsPage extends StatefulWidget {
  final String disciplineId;
  final String studyCycleId;
  final String name;
  final String teacher;
  final double? average;
  final int workload;
  final int colorValue;

  const SubjectDetailsPage({
    super.key,
    required this.disciplineId,
    required this.studyCycleId,
    required this.name,
    required this.teacher,
    required this.average,
    required this.workload,
    required this.colorValue,
  });

  @override
  State<SubjectDetailsPage> createState() => _SubjectDetailsPageState();
}

class _SubjectDetailsPageState extends State<SubjectDetailsPage> {
  final AssessmentRepository _assessmentRepository = AssessmentRepository();
  final SubjectEventRepository _eventRepository = SubjectEventRepository();
  final SubjectNoteRepository _noteRepository = SubjectNoteRepository();
  final TaskRepository _taskRepository = TaskRepository();
  final DisciplineRepository _disciplineRepository = DisciplineRepository();
  final StudyCycleRepository _studyCycleRepository = StudyCycleRepository();
  final StudySessionRepository _studySessionRepository =
      StudySessionRepository();
  final StudyTopicRepository _studyTopicRepository = StudyTopicRepository();

  Color get _accentColor => Color(widget.colorValue);

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 1) {
      Navigator.of(context).maybePop();
      return;
    }

    final route = switch (index) {
      0 => AppRoutes.home,
      2 => AppRoutes.tasks,
      3 => AppRoutes.schedule,
      _ => AppRoutes.subjects,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  Future<void> _openAssessmentDialog() async {
    final result = await showDialog<_AssessmentDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const _AssessmentDialog(),
    );

    if (result == null) return;

    try {
      await _assessmentRepository.createAssessment(
        AssessmentInput(
          studyCycleId: widget.studyCycleId,
          disciplineId: widget.disciplineId,
          disciplineName: widget.name,
          title: result.title,
          dateLabel: result.dateLabel,
          grade: result.grade,
          weight: result.weight,
        ),
      );
      _showSuccess('Nota salva com sucesso.');
    } on AssessmentRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar a nota. Tente novamente.');
    }
  }

  Future<void> _editAssessment(Assessment assessment) async {
    final result = await showDialog<_AssessmentDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => _AssessmentDialog(initialAssessment: assessment),
    );

    if (result == null) return;

    try {
      await _assessmentRepository.updateAssessment(
        id: assessment.id,
        input: AssessmentInput(
          studyCycleId: widget.studyCycleId,
          disciplineId: widget.disciplineId,
          disciplineName: widget.name,
          title: result.title,
          dateLabel: result.dateLabel,
          grade: result.grade,
          weight: result.weight,
        ),
      );
      _showSuccess('Nota atualizada com sucesso.');
    } on AssessmentRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível atualizar a nota. Tente novamente.');
    }
  }

  Future<void> _deleteAssessment(Assessment assessment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir nota?'),
          content: Text(
            'Isso removerá "${assessment.title}" desta disciplina.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _assessmentRepository.deleteAssessment(assessment.id);
      _showSuccess('Nota excluída.');
    } on AssessmentRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível excluir a nota.');
    }
  }

  Future<void> _openEventDialog() async {
    final result = await showDialog<SubjectEventDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const SubjectEventDialog(),
    );

    if (result == null) return;

    try {
      await _eventRepository.createEvent(
        SubjectEventInput(
          studyCycleId: widget.studyCycleId,
          disciplineId: widget.disciplineId,
          disciplineName: widget.name,
          title: result.title,
          type: result.type,
          eventDate: result.eventDate,
          startTimeMinutes: result.startTimeMinutes,
          endTimeMinutes: result.endTimeMinutes,
          topicIds: result.topicIds,
          description: result.description,
        ),
      );
      _showSuccess('Evento salvo com sucesso.');
    } on SubjectEventRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar o evento. Tente novamente.');
    }
  }

  Future<void> _openStudySessionDialog(List<StudyTopic> topics) async {
    final result = await showDialog<_StudySessionDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => _StudySessionDialog(topics: topics),
    );

    if (result == null) return;

    try {
      await _studySessionRepository.createSession(
        StudySessionInput(
          studyCycleId: widget.studyCycleId,
          disciplineId: widget.disciplineId,
          disciplineName: widget.name,
          studiedAt: result.studiedAt,
          durationMinutes: result.durationMinutes,
          topicIds: result.topicIds,
          notes: result.notes,
        ),
      );
      for (final topic in topics) {
        if (!result.topicIds.contains(topic.id) || topic.isSeen) continue;

        await _studyTopicRepository.updateStatus(
          topic: topic,
          status: StudyTopicStatus.seen,
        );
      }
      _showSuccess('Sessão de estudo salva.');
    } on StudySessionRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar a sessão de estudo.');
    }
  }

  Future<void> _openStudyTopicDialog({required int position}) async {
    final result = await showDialog<_StudyTopicDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const _StudyTopicDialog(),
    );

    if (result == null) return;

    try {
      await _studyTopicRepository.createTopic(
        StudyTopicInput(
          studyCycleId: widget.studyCycleId,
          disciplineId: widget.disciplineId,
          disciplineName: widget.name,
          title: result.title,
          position: position,
        ),
      );
      _showSuccess('Assunto salvo.');
    } on StudyTopicRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar o assunto.');
    }
  }

  Future<void> _toggleStudyTopic(StudyTopic topic, bool isSeen) async {
    try {
      await _studyTopicRepository.updateStatus(
        topic: topic,
        status: isSeen ? StudyTopicStatus.seen : StudyTopicStatus.todo,
      );
    } on StudyTopicRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível atualizar o assunto.');
    }
  }

  Future<void> _deleteEvent(SubjectEvent event) {
    return _eventRepository.deleteEvent(event.id);
  }

  void _openEventDetails(SubjectEvent event) {
    Navigator.of(context).push(
      AppRoutes.detailRoute(
        page: SubjectEventDetailsPage(
          event: event,
          accentColor: _accentColor,
          onDelete: _deleteEvent,
        ),
      ),
    );
  }

  Future<void> _openNoteDialog() async {
    final result = await showDialog<SubjectNoteDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const SubjectNoteDialog(),
    );

    if (result == null) return;

    try {
      await _noteRepository.createNote(
        SubjectNoteInput(
          studyCycleId: widget.studyCycleId,
          disciplineId: widget.disciplineId,
          disciplineName: widget.name,
          title: result.title,
          content: result.content,
        ),
      );
      _showSuccess('Anotação salva com sucesso.');
    } on SubjectNoteRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar a anotação. Tente novamente.');
    }
  }

  Future<void> _deleteNote(SubjectNote note) {
    return _noteRepository.deleteNote(note.id);
  }

  void _openNoteDetails(SubjectNote note) {
    Navigator.of(context).push(
      AppRoutes.detailRoute(
        page: SubjectNoteDetailsPage(
          note: note,
          accentColor: _accentColor,
          onDelete: _deleteNote,
        ),
      ),
    );
  }

  void _openTaskDetails(AcademicTask task, List<TaskDialogSubject> subjects) {
    Navigator.of(context).push(
      AppRoutes.detailRoute(
        page: TaskDetailsPage(
          task: task,
          subjects: subjects,
          activeStudyCycleId: widget.studyCycleId,
        ),
      ),
    );
  }

  List<TaskDialogSubject> _taskSubjectsFromDisciplines(
    List<Discipline> disciplines,
  ) {
    final subjects = disciplines
        .where((discipline) => discipline.name.trim().isNotEmpty)
        .map(
          (discipline) => TaskDialogSubject(
            id: discipline.id,
            name: discipline.name.trim(),
          ),
        )
        .toList();

    final includesCurrentDiscipline = subjects.any(
      (subject) => subject.id == widget.disciplineId,
    );
    if (!includesCurrentDiscipline && widget.name.trim().isNotEmpty) {
      subjects.add(
        TaskDialogSubject(id: widget.disciplineId, name: widget.name.trim()),
      );
    }

    subjects.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return subjects;
  }

  List<AcademicTask> _relatedTasks(List<AcademicTask> tasks) {
    final subjectKey = _normalizedText(widget.name);
    final cycleId = widget.studyCycleId.trim();

    return tasks.where((task) {
      final sameDiscipline = task.disciplineId == widget.disciplineId;
      final legacySameSubject =
          task.disciplineId == null &&
          _normalizedText(task.subject) == subjectKey;
      if (!sameDiscipline && !legacySameSubject) return false;

      if (cycleId.isEmpty) return true;

      return task.studyCycleId == null || task.studyCycleId == cycleId;
    }).toList();
  }

  Widget _buildIndependentDetailsContent({
    required Discipline currentDiscipline,
    required List<Assessment> assessments,
    required bool assessmentsAreLoading,
    required bool assessmentsHaveError,
    required List<AcademicTask> tasks,
    required bool tasksAreLoading,
    required bool tasksHaveError,
    required List<TaskDialogSubject> taskSubjects,
  }) {
    final pendingTasks = tasks.where((task) => !task.isChecked).length;

    return StreamBuilder<List<StudyTopic>>(
      stream: _studyTopicRepository.watchTopics(
        studyCycleId: widget.studyCycleId,
        disciplineId: widget.disciplineId,
      ),
      builder: (context, topicSnapshot) {
        final topics = topicSnapshot.data ?? const <StudyTopic>[];
        final topicsAreLoading =
            topicSnapshot.connectionState == ConnectionState.waiting &&
            !topicSnapshot.hasData;
        final topicsHaveError = topicSnapshot.hasError;
        final seenTopics = topics.where((topic) => topic.isSeen).length;

        return StreamBuilder<List<StudySession>>(
          stream: _studySessionRepository.watchSessions(
            studyCycleId: widget.studyCycleId,
            disciplineId: widget.disciplineId,
          ),
          builder: (context, sessionSnapshot) {
            final sessions = sessionSnapshot.data ?? const <StudySession>[];
            final sessionsAreLoading =
                sessionSnapshot.connectionState == ConnectionState.waiting &&
                !sessionSnapshot.hasData;
            final sessionsHaveError = sessionSnapshot.hasError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IndependentSubjectSummaryCard(
                  name: currentDiscipline.name,
                  totalStudyMinutes: StudySession.totalMinutes(sessions),
                  topicCount: topics.length,
                  seenTopicCount: seenTopics,
                  pendingTaskCount: pendingTasks,
                  accentColor: _accentColor,
                ),
                const SizedBox(height: 26),
                _StudyProgressCard(
                  sessions: sessions,
                  topics: topics,
                  accentColor: _accentColor,
                  onAddSession: () => _openStudySessionDialog(topics),
                  onAddTopic: () =>
                      _openStudyTopicDialog(position: topics.length),
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Assuntos',
                  trailing: _InlineActionButton(
                    label: 'Adicionar',
                    icon: Icons.add,
                    onTap: () => _openStudyTopicDialog(position: topics.length),
                  ),
                ),
                const SizedBox(height: 12),
                _StudyTopicsPanel(
                  topics: topics,
                  isLoading: topicsAreLoading,
                  hasError: topicsHaveError,
                  accentColor: _accentColor,
                  onMarkSeen: (topic) => _toggleStudyTopic(topic, true),
                  onMarkTodo: (topic) => _toggleStudyTopic(topic, false),
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Sessões recentes',
                  trailing: _InlineActionButton(
                    label: 'Registrar',
                    icon: Icons.timer_outlined,
                    onTap: () => _openStudySessionDialog(topics),
                  ),
                ),
                const SizedBox(height: 12),
                _StudySessionsPanel(
                  sessions: sessions,
                  isLoading: sessionsAreLoading,
                  hasError: sessionsHaveError,
                  accentColor: _accentColor,
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Revisões e eventos',
                  trailing: _InlineActionButton(
                    label: 'Adicionar',
                    icon: Icons.event_available_outlined,
                    onTap: _openEventDialog,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<SubjectEvent>>(
                  stream: _eventRepository.watchEvents(
                    studyCycleId: widget.studyCycleId,
                    disciplineId: widget.disciplineId,
                    upcomingOnly: true,
                  ),
                  builder: (context, eventSnapshot) {
                    return _SubjectEventsPanel(
                      events: eventSnapshot.data ?? const [],
                      isLoading:
                          eventSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !eventSnapshot.hasData,
                      hasError: eventSnapshot.hasError,
                      accentColor: _accentColor,
                      onOpen: _openEventDetails,
                    );
                  },
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Simulados',
                  trailing: _InlineActionButton(
                    label: 'Adicionar',
                    icon: Icons.add,
                    onTap: _openAssessmentDialog,
                  ),
                ),
                const SizedBox(height: 12),
                _AssessmentsPanel(
                  assessments: assessments,
                  isLoading: assessmentsAreLoading,
                  hasError: assessmentsHaveError,
                  accentColor: _accentColor,
                  passingGrade: 0,
                  onAdd: _openAssessmentDialog,
                  onDelete: _deleteAssessment,
                  onEdit: _editAssessment,
                ),
                const SizedBox(height: 28),
                const _SectionHeader(title: 'Tarefas relacionadas'),
                const SizedBox(height: 12),
                _RelatedTasksPanel(
                  tasks: tasks,
                  isLoading: tasksAreLoading,
                  hasError: tasksHaveError,
                  accentColor: _accentColor,
                  onOpen: (task) => _openTaskDetails(task, taskSubjects),
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Anotações',
                  trailing: _InlineActionButton(
                    label: 'Adicionar',
                    icon: Icons.note_add_outlined,
                    onTap: _openNoteDialog,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<SubjectNote>>(
                  stream: _noteRepository.watchNotes(
                    studyCycleId: widget.studyCycleId,
                    disciplineId: widget.disciplineId,
                  ),
                  builder: (context, noteSnapshot) {
                    return _SubjectNotesPanel(
                      notes: noteSnapshot.data ?? const [],
                      isLoading:
                          noteSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !noteSnapshot.hasData,
                      hasError: noteSnapshot.hasError,
                      accentColor: _accentColor,
                      onOpen: _openNoteDetails,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _normalizedText(String value) {
    return value.trim().toLowerCase();
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _DetailsHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 34),
                sliver: SliverToBoxAdapter(
                  child: StreamBuilder<List<StudyCycle>>(
                    stream: _studyCycleRepository.watchStudyCycles(),
                    builder: (context, studyCycleSnapshot) {
                      final studyCycles = studyCycleSnapshot.data ?? const [];
                      final currentCycle = studyCycles.firstWhere(
                        (c) => c.id == widget.studyCycleId,
                        orElse: () => StudyCycle(
                          id: widget.studyCycleId,
                          type: StudyCycleType.independent,
                          passingGrade: 7.0,
                        ),
                      );
                      final passingGrade = currentCycle.passingGrade;

                      return StreamBuilder<List<Discipline>>(
                        stream: _disciplineRepository.watchDisciplines(
                          studyCycleId: widget.studyCycleId,
                        ),
                        builder: (context, disciplineSnapshot) {
                          final disciplines =
                              disciplineSnapshot.data ?? const [];
                          final currentDiscipline = disciplines.firstWhere(
                            (d) => d.id == widget.disciplineId,
                            orElse: () => Discipline(
                              id: widget.disciplineId,
                              name: widget.name,
                              teacher: widget.teacher,
                              workload: widget.workload,
                              colorValue: widget.colorValue,
                              studyCycleId: widget.studyCycleId,
                            ),
                          );

                          return StreamBuilder<List<Assessment>>(
                            stream: _assessmentRepository.watchAssessments(
                              studyCycleId: widget.studyCycleId,
                              disciplineId: widget.disciplineId,
                            ),
                            builder: (context, assessmentSnapshot) {
                              final assessments =
                                  assessmentSnapshot.data ?? const [];
                              final assessmentsAreLoading =
                                  assessmentSnapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  !assessmentSnapshot.hasData;
                              final assessmentsHaveError =
                                  assessmentSnapshot.hasError;

                              final summary = GradeSummary.calculate(
                                disciplines: [currentDiscipline],
                                assessments: assessments,
                                passingGrade: passingGrade,
                              );
                              final average = summary.averageFor(
                                currentDiscipline.id,
                              );
                              final totalWeights = summary.totalWeightFor(
                                currentDiscipline.id,
                              );

                              return StreamBuilder<List<AcademicTask>>(
                                stream: _taskRepository.watchTasks(
                                  studyCycleId: widget.studyCycleId,
                                ),
                                builder: (context, taskSnapshot) {
                                  final tasks = _relatedTasks(
                                    taskSnapshot.data ?? const [],
                                  );
                                  final tasksAreLoading =
                                      taskSnapshot.connectionState ==
                                          ConnectionState.waiting &&
                                      !taskSnapshot.hasData;
                                  final tasksHaveError = taskSnapshot.hasError;
                                  final pendingTasks = tasks
                                      .where((task) => !task.isChecked)
                                      .length;
                                  final taskSubjects =
                                      _taskSubjectsFromDisciplines(disciplines);

                                  if (currentCycle.type ==
                                      StudyCycleType.independent) {
                                    return _buildIndependentDetailsContent(
                                      currentDiscipline: currentDiscipline,
                                      assessments: assessments,
                                      assessmentsAreLoading:
                                          assessmentsAreLoading,
                                      assessmentsHaveError:
                                          assessmentsHaveError,
                                      tasks: tasks,
                                      tasksAreLoading: tasksAreLoading,
                                      tasksHaveError: tasksHaveError,
                                      taskSubjects: taskSubjects,
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _SubjectSummaryCard(
                                        name: currentDiscipline.name,
                                        teacher: currentDiscipline.teacher,
                                        average: average,
                                        workload: currentDiscipline.workload,
                                        gradeCount: assessments.length,
                                        pendingTaskCount: pendingTasks,
                                        accentColor: _accentColor,
                                        passingGrade: passingGrade,
                                        totalWeights: totalWeights,
                                      ),
                                      const SizedBox(height: 26),
                                      _AttendanceManagementCard(
                                        discipline: currentDiscipline,
                                        accentColor: _accentColor,
                                        onUpdateAbsences: (absences) {
                                          _disciplineRepository.updateAbsences(
                                            currentDiscipline.id,
                                            absences,
                                          );
                                        },
                                        onUpdateMaxAbsences: (maxAbsences) {
                                          _disciplineRepository
                                              .updateMaxAbsences(
                                                currentDiscipline.id,
                                                maxAbsences,
                                              );
                                        },
                                      ),
                                      const SizedBox(height: 26),
                                      _SectionHeader(
                                        title: 'Eventos',
                                        trailing: _InlineActionButton(
                                          label: 'Adicionar',
                                          icon: Icons.event_available_outlined,
                                          onTap: _openEventDialog,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      StreamBuilder<List<SubjectEvent>>(
                                        stream: _eventRepository.watchEvents(
                                          studyCycleId: widget.studyCycleId,
                                          disciplineId: widget.disciplineId,
                                          upcomingOnly: true,
                                        ),
                                        builder: (context, eventSnapshot) {
                                          return _SubjectEventsPanel(
                                            events:
                                                eventSnapshot.data ?? const [],
                                            isLoading:
                                                eventSnapshot.connectionState ==
                                                    ConnectionState.waiting &&
                                                !eventSnapshot.hasData,
                                            hasError: eventSnapshot.hasError,
                                            accentColor: _accentColor,
                                            onOpen: _openEventDetails,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 28),
                                      _SectionHeader(
                                        title: 'Notas',
                                        trailing: _InlineActionButton(
                                          label: 'Adicionar',
                                          icon: Icons.add,
                                          onTap: _openAssessmentDialog,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _AssessmentsPanel(
                                        assessments: assessments,
                                        isLoading: assessmentsAreLoading,
                                        hasError: assessmentsHaveError,
                                        accentColor: _accentColor,
                                        passingGrade: passingGrade,
                                        onAdd: _openAssessmentDialog,
                                        onDelete: _deleteAssessment,
                                        onEdit: _editAssessment,
                                      ),
                                      const SizedBox(height: 28),
                                      const _SectionHeader(
                                        title: 'Tarefas relacionadas',
                                      ),
                                      const SizedBox(height: 12),
                                      _RelatedTasksPanel(
                                        tasks: tasks,
                                        isLoading: tasksAreLoading,
                                        hasError: tasksHaveError,
                                        accentColor: _accentColor,
                                        onOpen: (task) => _openTaskDetails(
                                          task,
                                          taskSubjects,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      _SectionHeader(
                                        title: 'Anotações',
                                        trailing: _InlineActionButton(
                                          label: 'Adicionar',
                                          icon: Icons.note_add_outlined,
                                          onTap: _openNoteDialog,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      StreamBuilder<List<SubjectNote>>(
                                        stream: _noteRepository.watchNotes(
                                          studyCycleId: widget.studyCycleId,
                                          disciplineId: widget.disciplineId,
                                        ),
                                        builder: (context, noteSnapshot) {
                                          return _SubjectNotesPanel(
                                            notes:
                                                noteSnapshot.data ?? const [],
                                            isLoading:
                                                noteSnapshot.connectionState ==
                                                    ConnectionState.waiting &&
                                                !noteSnapshot.hasData,
                                            hasError: noteSnapshot.hasError,
                                            accentColor: _accentColor,
                                            onOpen: _openNoteDetails,
                                          );
                                        },
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
