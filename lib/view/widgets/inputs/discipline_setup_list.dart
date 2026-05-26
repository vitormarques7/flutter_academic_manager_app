import 'package:flutter/material.dart';

import '../dialogs/schedule_dialog.dart';
import 'discipline_setup_card.dart';

class DisciplineSetupList extends StatefulWidget {
  const DisciplineSetupList({super.key});

  @override
  State<DisciplineSetupList> createState() => _DisciplineSetupListState();
}

class _DisciplineSetupListState extends State<DisciplineSetupList> {
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
    setState(() {
      if (index == 0) {
        _disciplines.first.controller.clear();
        _disciplines.first.isConfirmed = false;
        _removeEmptyDraftsAfterFirst();
        return;
      }

      final discipline = _disciplines.removeAt(index);
      discipline.controller.dispose();
    });
  }

  void _removeEmptyDraftsAfterFirst() {
    for (var i = _disciplines.length - 1; i > 0; i--) {
      final discipline = _disciplines[i];
      if (!discipline.isConfirmed &&
          discipline.controller.text.trim().isEmpty) {
        discipline.controller.dispose();
        _disciplines.removeAt(i);
      }
    }
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
