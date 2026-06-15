import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/routes/app_routes.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../models/academic_task.dart';
import '../../models/assessment.dart';
import '../../models/subject_event.dart';
import '../../models/subject_note.dart';
import '../../repositories/assessment_repository.dart';
import '../../repositories/subject_event_repository.dart';
import '../../repositories/subject_note_repository.dart';
import '../../repositories/task_repository.dart';
import '../widgets/common/app_bottom_nav_bar.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/common/metadata_chip.dart';
import '../widgets/inputs/date_picker_field.dart';
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
        ),
      );
      _showSuccess('Nota salva com sucesso.');
    } on AssessmentRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar a nota. Tente novamente.');
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
    final result = await showDialog<_SubjectEventDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const _SubjectEventDialog(),
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

  Future<void> _deleteEvent(SubjectEvent event) {
    return _eventRepository.deleteEvent(event.id);
  }

  void _openEventDetails(SubjectEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectEventDetailsPage(
          event: event,
          accentColor: _accentColor,
          onDelete: _deleteEvent,
        ),
      ),
    );
  }

  Future<void> _openNoteDialog() async {
    final result = await showDialog<_SubjectNoteDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const _SubjectNoteDialog(),
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
      MaterialPageRoute(
        builder: (_) => SubjectNoteDetailsPage(
          note: note,
          accentColor: _accentColor,
          onDelete: _deleteNote,
        ),
      ),
    );
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

  double? _averageFromAssessments(List<Assessment> assessments) {
    if (assessments.isEmpty) return widget.average;

    final total = assessments.fold<double>(
      0,
      (sum, assessment) => sum + assessment.grade,
    );

    return total / assessments.length;
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
                  child: StreamBuilder<List<Assessment>>(
                    stream: _assessmentRepository.watchAssessments(
                      studyCycleId: widget.studyCycleId,
                      disciplineId: widget.disciplineId,
                    ),
                    builder: (context, assessmentSnapshot) {
                      final assessments = assessmentSnapshot.data ?? const [];
                      final assessmentsAreLoading =
                          assessmentSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !assessmentSnapshot.hasData;
                      final assessmentsHaveError = assessmentSnapshot.hasError;
                      final average = _averageFromAssessments(assessments);

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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SubjectSummaryCard(
                                name: widget.name,
                                teacher: widget.teacher,
                                average: average,
                                workload: widget.workload,
                                gradeCount: assessments.length,
                                pendingTaskCount: pendingTasks,
                                accentColor: _accentColor,
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
                                onAdd: _openAssessmentDialog,
                                onDelete: _deleteAssessment,
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
                                onOpenTasks: () => _onBottomNavTap(context, 2),
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
