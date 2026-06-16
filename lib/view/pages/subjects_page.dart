import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../models/academic_subject.dart';
import '../../repositories/subject_repository.dart';
import 'subject_details_page.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/section_label.dart';
import '../widgets/inputs/search_field.dart';
import '../widgets/common/floating_add_button.dart';
import '../widgets/common/hero_form_sheet.dart';
import '../widgets/cards/swipeable_subject_card.dart';
import '../widgets/dialogs/subject_dialog.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final _searchController = TextEditingController();
  final _subjectRepository = SubjectRepository();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  List<AcademicSubject> _filterSubjects(List<AcademicSubject> subjects) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return subjects;

    return subjects
        .where(
          (subject) =>
              subject.name.toLowerCase().contains(query) ||
              subject.teacher.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<bool> _confirmDeleteSubject(AcademicSubject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir disciplina'),
          content: Text(
            'Deseja excluir "${subject.name}"? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _deleteSubject(AcademicSubject subject) async {
    try {
      await _subjectRepository.deleteSubject(subject.id);
    } on SubjectRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível excluir a disciplina. Tente novamente.');
    }
  }

  Future<void> _openSubjectDialog() async {
    final result = await showHeroFormDialog<SubjectDialogResult>(
      context: context,
      child: const SubjectDialog(),
    );

    if (result == null || !mounted) return;

    try {
      await _subjectRepository.createSubject(
        SubjectInput(
          name: result.name,
          teacher: result.teacher,
          workload: result.workload,
          schedule: result.schedule.map((entry) => entry.toMap()).toList(),
        ),
      );
    } on SubjectRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível salvar a disciplina. Tente novamente.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
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
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(title: 'Suas Disciplinas'),

                    const SizedBox(height: 24),

                    SearchField(
                      controller: _searchController,
                      hint: 'Pesquise por disciplina',
                    ),

                    const SizedBox(height: 20),

                    const SectionLabel(label: 'MINHAS DISCIPLINAS'),

                    const SizedBox(height: 12),

                    StreamBuilder<List<AcademicSubject>>(
                      stream: _subjectRepository.watchSubjects(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const _SubjectsStateMessage(
                            message:
                                'Não foi possível carregar suas disciplinas agora.',
                          );
                        }

                        final subjects = _filterSubjects(snapshot.data ?? []);

                        if (subjects.isEmpty) {
                          return const _SubjectsStateMessage(
                            message:
                                'Nenhuma disciplina cadastrada. Adicione uma no cadastro ou pelo botão +.',
                          );
                        }

                        return Column(
                          children: subjects.map((subject) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: SwipeableSubjectCard(
                                dismissKey: subject.id,
                                name: subject.name,
                                teacher: subject.teacher,
                                frequency: subject.frequency,
                                average: subject.average,
                                onConfirmDelete: () =>
                                    _confirmDeleteSubject(subject),
                                onDismissed: () => _deleteSubject(subject),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SubjectDetailsPage(
                                        name: subject.name,
                                        teacher: subject.teacher,
                                        average: subject.average,
                                        workload: subject.workload,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 24,
            bottom: 16,
            child: FloatingAddButton(onTap: _openSubjectDialog),
          ),
        ],
      ),
    );
  }
}

class _SubjectsStateMessage extends StatelessWidget {
  final String message;

  const _SubjectsStateMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF464552),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
