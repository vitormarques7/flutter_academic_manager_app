import 'package:flutter/material.dart';
import '../../config/scroll/app_scroll_behavior.dart';
import '../../models/discipline.dart';
import '../../models/schedule.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'subject_details_page.dart';
import '../widgets/common/page_header.dart';
import '../widgets/inputs/search_field.dart';
import '../widgets/cards/subject_card.dart';
import '../widgets/dialogs/subject_dialog.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/list_section_header.dart';
import '../widgets/common/summary_metric_tile.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final _searchController = TextEditingController();
  final DisciplineRepository _disciplineRepository = DisciplineRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
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
      await _disciplineRepository.deleteDisciplineWithSchedules(
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
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir disciplina?'),
          content: Text(
            'Isso removerá "${discipline.name}" e os horários vinculados a ela.',
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
                    const PageHeader(title: 'Suas Disciplinas'),

                    const SizedBox(height: 24),

                    FutureBuilder<String?>(
                      future: _activeStudyCycleIdFuture,
                      builder: (context, activeCycleSnapshot) {
                        if (activeCycleSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _SubjectsLoadingState();
                        }

                        if (activeCycleSnapshot.hasError) {
                          return const EmptyStateCard(
                            message:
                                'Não foi possível carregar seu ciclo de estudos.',
                          );
                        }

                        final activeStudyCycleId = activeCycleSnapshot.data;

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
                                message:
                                    'Não foi possível carregar suas disciplinas agora.',
                              );
                            }

                            final allDisciplines = snapshot.data ?? [];
                            final disciplines = _filterDisciplines(
                              allDisciplines,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SubjectsOverview(
                                  total: allDisciplines.length,
                                  averageGrade: 0,
                                  averageFrequency: 0,
                                ),
                                const SizedBox(height: 18),
                                SearchField(
                                  controller: _searchController,
                                  hint: 'Pesquise por disciplina',
                                ),
                                const SizedBox(height: 20),
                                ListSectionHeader(
                                  label: 'MINHAS DISCIPLINAS',
                                  count: disciplines.length,
                                  trailing: _EditSubjectsButton(
                                    onSelected: _handleEditAction,
                                  ),
                                ),
                                const SizedBox(height: 12),
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
                                        teacher: discipline.teacher.isEmpty
                                            ? 'Professor não informado'
                                            : discipline.teacher,
                                        frequency: 0,
                                        average: 0,
                                        workload: discipline.workload,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => SubjectDetailsPage(
                                                disciplineId: discipline.id,
                                                studyCycleId:
                                                    discipline.studyCycleId,
                                                name: discipline.name,
                                                teacher:
                                                    discipline.teacher.isEmpty
                                                    ? 'Professor não informado'
                                                    : discipline.teacher,
                                                average: 0,
                                                workload: discipline.workload,
                                                colorValue:
                                                    discipline.colorValue,
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
    return PopupMenuButton<_SubjectEditAction>(
      tooltip: 'Editar disciplinas',
      onSelected: onSelected,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _SubjectEditAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Text('Excluir Disciplina'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _SubjectEditAction.add,
          child: Row(
            children: [
              Icon(Icons.add, color: Color(0xFF514EB6), size: 20),
              SizedBox(width: 10),
              Text('Adicionar Nova Disciplina'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x33514EB6)),
        ),
        child: const Text(
          'Editar',
          style: TextStyle(
            color: Color(0xFF514EB6),
            fontSize: 12,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DeleteDisciplineSheet extends StatelessWidget {
  final List<Discipline> disciplines;

  const _DeleteDisciplineSheet({required this.disciplines});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FF),
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
                  const Expanded(
                    child: Text(
                      'Excluir disciplina',
                      style: TextStyle(
                        color: Color(0xFF191820),
                        fontSize: 22,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF6B6875)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Escolha qual disciplina deseja remover.',
                style: TextStyle(
                  color: Color(0xFF6B6875),
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
                      color: const Color(0xFFEFF0FB),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(discipline),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF514EB6,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0x4C514EB6),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_book_outlined,
                                  color: Color(0xFF514EB6),
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
                                      style: const TextStyle(
                                        color: Color(0xFF191820),
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
                                      style: const TextStyle(
                                        color: Color(0xFF6B6875),
                                        fontSize: 12,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
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
  final double averageGrade;
  final double averageFrequency;

  const _SubjectsOverview({
    required this.total,
    required this.averageGrade,
    required this.averageFrequency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryMetricTile(
            label: 'Disciplinas',
            value: '$total',
            icon: Icons.menu_book_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryMetricTile(
            label: 'Média',
            value: averageGrade.toStringAsFixed(1),
            icon: Icons.bar_chart_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryMetricTile(
            label: 'Freq.',
            value: '${(averageFrequency * 100).round()}%',
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }
}

class _SubjectsLoadingState extends StatelessWidget {
  const _SubjectsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(child: CircularProgressIndicator()),
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
