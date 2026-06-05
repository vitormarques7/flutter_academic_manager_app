import 'package:flutter/material.dart';
import '../../config/scroll/app_scroll_behavior.dart';
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

  final List<_SubjectSummary> _subjects = const [
    _SubjectSummary(
      name: 'Programação',
      teacher: 'Prof. Alguem',
      frequency: 0.85,
      average: 8.5,
      workload: 60,
    ),
    _SubjectSummary(
      name: 'Cálculo I',
      teacher: 'Prof. Alguem',
      frequency: 0.60,
      average: 8.0,
      workload: 60,
    ),
    _SubjectSummary(
      name: 'Cálculo II',
      teacher: 'Prof. Alguem',
      frequency: 1.0,
      average: 7.0,
      workload: 60,
    ),
  ];

  List<_SubjectSummary> get _filteredSubjects {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return _subjects;

    return _subjects
        .where(
          (subject) =>
              subject.name.toLowerCase().contains(query) ||
              subject.teacher.toLowerCase().contains(query),
        )
        .toList();
  }

  double get _averageGrade {
    if (_subjects.isEmpty) return 0;

    final total = _subjects.fold<double>(
      0,
      (sum, subject) => sum + subject.average,
    );

    return total / _subjects.length;
  }

  double get _averageFrequency {
    if (_subjects.isEmpty) return 0;

    final total = _subjects.fold<double>(
      0,
      (sum, subject) => sum + subject.frequency,
    );

    return total / _subjects.length;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _openSubjectDialog() async {
    final result = await showDialog<SubjectDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => const SubjectDialog(),
    );

    if (result == null || !mounted) return;

    setState(() {
      _subjects.insert(
        0,
        _SubjectSummary(
          name: result.name,
          teacher: result.teacher,
          frequency: 0,
          average: 0,
          workload: result.workload,
          schedule: result.schedule.map((entry) => entry.toMap()).toList(),
        ),
      );
    });
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

                    _SubjectsOverview(
                      total: _subjects.length,
                      averageGrade: _averageGrade,
                      averageFrequency: _averageFrequency,
                    ),

                    const SizedBox(height: 18),

                    SearchField(
                      controller: _searchController,
                      hint: 'Pesquise por disciplina',
                    ),

                    const SizedBox(height: 20),

                    ListSectionHeader(
                      label: 'MINHAS DISCIPLINAS',
                      count: _filteredSubjects.length,
                    ),

                    const SizedBox(height: 12),

                    if (_filteredSubjects.isEmpty)
                      const EmptyStateCard(
                        message: 'Nenhuma disciplina encontrada.',
                        icon: Icons.search_off_outlined,
                      )
                    else
                      ..._filteredSubjects.map(
                        (subject) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SubjectCard(
                            name: subject.name,
                            teacher: subject.teacher,
                            frequency: subject.frequency,
                            average: subject.average,
                            workload: subject.workload,
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
                        ),
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

class _SubjectSummary {
  final String name;
  final String teacher;
  final double frequency;
  final double average;
  final int workload;
  final List<Map<String, dynamic>> schedule;

  const _SubjectSummary({
    required this.name,
    required this.teacher,
    required this.frequency,
    required this.average,
    required this.workload,
    this.schedule = const [],
  });
}
