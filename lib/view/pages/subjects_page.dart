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
import '../widgets/common/floating_add_button.dart';
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
    final result = await showDialog<SubjectDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const SubjectDialog(),
    );

    if (result == null || !mounted) return;

    final activeStudyCycleId = await _activeStudyCycleIdFuture;
    if (activeStudyCycleId == null) {
      _showError('Configure um ciclo de estudos antes de criar disciplinas.');
      return;
    }

    try {
      await _disciplineRepository.createDiscipline(
        DisciplineInput(
          name: result.name,
          teacher: result.teacher,
          workload: result.workload,
          colorValue: Discipline.defaultColorValue,
          studyCycleId: activeStudyCycleId,
        ),
      );

      for (final schedule in _groupScheduleEntries(result.schedule)) {
        await _scheduleRepository.createSchedule(
          ScheduleInput(
            studyCycleId: activeStudyCycleId,
            disciplineName: result.name,
            weekdays: schedule.sortedWeekdays,
            startTimeMinutes: schedule.startTimeMinutes,
            endTimeMinutes: schedule.endTimeMinutes,
            colorValue: Schedule.defaultColorValue,
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
                                                name: discipline.name,
                                                teacher:
                                                    discipline.teacher.isEmpty
                                                    ? 'Professor não informado'
                                                    : discipline.teacher,
                                                average: 0,
                                                workload: discipline.workload,
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

          // Botão flutuante
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
