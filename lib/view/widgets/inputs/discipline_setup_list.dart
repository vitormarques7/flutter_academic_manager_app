import 'package:flutter/material.dart';

import '../dialogs/schedule_dialog.dart';
import 'discipline_setup_card.dart';

class DisciplineSetupList extends StatefulWidget {
  const DisciplineSetupList({super.key});

  @override
  State<DisciplineSetupList> createState() => DisciplineSetupListState();
}

class DisciplineSetupListState extends State<DisciplineSetupList> {
  List<String> get confirmedNames {
    return _disciplines
        .where((discipline) => discipline.isConfirmed)
        .map((discipline) => discipline.controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  final List<_DisciplineDraft> _disciplines = [
    _DisciplineDraft(controller: TextEditingController()),
  ];

  @override
  void dispose() {
    for (final discipline in _disciplines) {
      discipline.controller.dispose();
    }
    super.dispose();
  }

  void _removeDiscipline(int index) {
    if (index >= _disciplines.length) return;

    setState(() {
      final discipline = _disciplines[index];

      if (!discipline.isConfirmed) {
        discipline.controller.clear();
        return;
      }

      final removedDiscipline = _disciplines.removeAt(index);
      removedDiscipline.controller.dispose();

      final hasDraft = _disciplines.any(
        (discipline) => !discipline.isConfirmed,
      );
      if (!hasDraft) {
        _disciplines.add(_DisciplineDraft(controller: TextEditingController()));
      }
    });
  }

  void _completeDiscipline(int index) {
    if (index >= _disciplines.length) return;

    setState(() {
      _disciplines[index].isConfirmed = true;

      final hasDraft = _disciplines.any(
        (discipline) => !discipline.isConfirmed,
      );
      if (!hasDraft) {
        _disciplines.add(_DisciplineDraft(controller: TextEditingController()));
      }
    });
  }

  Future<void> _onDisciplineOk(int index) async {
    FocusScope.of(context).unfocus();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        void closeAndComplete() {
          Navigator.of(dialogContext).pop();
          if (!mounted || index >= _disciplines.length) return;
          if (_disciplines[index].controller.text.trim().isNotEmpty) {
            _completeDiscipline(index);
          }
        }

        return ScheduleDialog(
          onContinue: closeAndComplete,
          onSkip: closeAndComplete,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._disciplines.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DisciplineSetupCard(
              controller: entry.value.controller,
              isConfirmed: entry.value.isConfirmed,
              onConfirm: () => _onDisciplineOk(entry.key),
              onDelete: () => _removeDiscipline(entry.key),
            ),
          ),
        ),
      ],
    );
  }
}

class _DisciplineDraft {
  final TextEditingController controller;
  bool isConfirmed = false;

  _DisciplineDraft({required this.controller});
}
