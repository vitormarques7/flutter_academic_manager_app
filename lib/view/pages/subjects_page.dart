import 'package:flutter/material.dart';
import 'subject_details_page.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/section_label.dart';
import '../widgets/inputs/search_field.dart';
import '../widgets/common/floating_add_button.dart';
import '../widgets/cards/subject_card.dart';
import '../widgets/dialogs/subject_dialog.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final _searchController = TextEditingController();

  // Dados mockados — substituir por dados reais quando integrar Firebase
  final List<Map<String, dynamic>> _subjects = [
    {
      'name': 'Programação',
      'teacher': 'Prof. Alguem',
      'frequency': 0.85,
      'average': 8.5,
      'workload': 60,
    },
    {
      'name': 'Cálculo I',
      'teacher': 'Prof. Alguem',
      'frequency': 0.60,
      'average': 8.0,
      'workload': 60,
    },
    {
      'name': 'Cálculo II',
      'teacher': 'Prof. Alguem',
      'frequency': 1.0,
      'average': 7.0,
      'workload': 60,
    },
  ];

  List<Map<String, dynamic>> get _filteredSubjects {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return _subjects;

    return _subjects
        .where(
          (subject) =>
              subject['name'].toLowerCase().contains(query) ||
              subject['teacher'].toLowerCase().contains(query),
        )
        .toList();
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
      _subjects.insert(0, {
        'name': result.name,
        'teacher': result.teacher,
        'frequency': 0.0,
        'average': 0.0,
        'workload': result.workload,
        'schedule': result.schedule.map((entry) => entry.toMap()).toList(),
      });
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

                    ..._filteredSubjects.map(
                      (subject) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SubjectCard(
                          name: subject['name'],
                          teacher: subject['teacher'],
                          frequency: subject['frequency'],
                          average: subject['average'],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SubjectDetailsPage(
                                  name: subject['name'],
                                  teacher: subject['teacher'],
                                  average: subject['average'],
                                  workload: subject['workload'],
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
