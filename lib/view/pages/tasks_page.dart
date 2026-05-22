import 'package:flutter/material.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/section_label.dart';
import '../widgets/selectors/task_filter_chip.dart';
import '../widgets/cards/task_card.dart';
import '../widgets/common/floating_add_button.dart';
import '../../config/theme/app_colors.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedFilter = 'Todas';

  // Dados mockados — substituir por dados reais quando integrar Firebase
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Atividade 1',
      'subject': 'Programação',
      'deadline': '20/04',
      'isChecked': false,
    },
    {
      'title': 'Atividade 1',
      'subject': 'Programação',
      'deadline': '20/04',
      'isChecked': false,
    },
  ];

  void _onFilterTap() {
    // TODO: implementar dropdown de filtro (Todas, Pendentes, Concluídas)
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Todas', 'Pendentes', 'Concluídas'].map((option) {
          return ListTile(
            title: Text(option),
            selected: _selectedFilter == option,
            selectedColor: const Color(0xFF514EB6),
            onTap: () {
              setState(() => _selectedFilter = option);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(title: 'Suas Tarefas'),

                    const SizedBox(height: 24),

                    TaskFilterChip(label: _selectedFilter, onTap: _onFilterTap),

                    const SizedBox(height: 20),

                    const SectionLabel(label: 'LISTA DE TAREFAS'),

                    const SizedBox(height: 12),

                    ...List.generate(_tasks.length, (index) {
                      final task = _tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCard(
                          title: task['title'],
                          subject: task['subject'],
                          deadline: task['deadline'],
                          isChecked: task['isChecked'],
                          onChanged: (value) {
                            setState(
                              () => _tasks[index]['isChecked'] = value ?? false,
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Botão flutuante
            Positioned(
              right: 24,
              bottom: 16,
              child: FloatingAddButton(
                onTap: () {
                  // TODO: abrir modal/tela de adicionar tarefa
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
