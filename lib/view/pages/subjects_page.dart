import 'package:flutter/material.dart';
import 'subject_details_page.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/section_label.dart';
import '../widgets/inputs/search_field.dart';
import '../widgets/common/floating_add_button.dart';
import '../widgets/cards/subject_card.dart';

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

  List<Map<String, dynamic>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _subjects;
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = _subjects
          .where(
            (s) =>
                s['name'].toLowerCase().contains(query.toLowerCase()) ||
                s['teacher'].toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
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
                      onChanged: _onSearch,
                    ),

                    const SizedBox(height: 20),

                    const SectionLabel(label: 'MINHAS DISCIPLINAS'),

                    const SizedBox(height: 12),

                    ..._filtered.map(
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
            child: FloatingAddButton(
              onTap: () {
                // TODO: abrir modal/tela de adicionar disciplina
              },
            ),
          ),
        ],
      ),
    );
  }
}
