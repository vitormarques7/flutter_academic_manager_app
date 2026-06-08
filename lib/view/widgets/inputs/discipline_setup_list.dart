import 'package:flutter/material.dart';

import '../../../services/setup/academic_setup_service.dart';
import '../dialogs/schedule_dialog.dart';
import 'discipline_setup_card.dart';

class DisciplineSetupList extends StatefulWidget {
  final ValueChanged<List<AcademicSetupDisciplineDraft>>? onChanged;

  const DisciplineSetupList({super.key, this.onChanged});

  @override
  State<DisciplineSetupList> createState() => _DisciplineSetupListState();
}

class _DisciplineSetupListState extends State<DisciplineSetupList> {
  final List<_DisciplineDraft> _disciplines = [];

  @override
  void initState() {
    super.initState();
    _addDraft();
  }

  @override
  void dispose() {
    for (final discipline in _disciplines) {
      _disposeDraft(discipline);
    }
    super.dispose();
  }

  void _addDraft() {
    final controller = TextEditingController();
    controller.addListener(_emitChanges);
    _disciplines.add(_DisciplineDraft(controller: controller));
  }

  void _disposeDraft(_DisciplineDraft discipline) {
    discipline.controller.removeListener(_emitChanges);
    discipline.controller.dispose();
  }

  void _emitChanges() {
    final drafts = _disciplines
        .where((discipline) {
          return discipline.isConfirmed &&
              discipline.controller.text.trim().isNotEmpty;
        })
        .map((discipline) {
          return AcademicSetupDisciplineDraft(
            name: discipline.controller.text.trim(),
            schedules: discipline.schedules,
          );
        })
        .toList();

    widget.onChanged?.call(drafts);
  }

  void _removeDiscipline(int index) {
    if (index >= _disciplines.length) return;

    setState(() {
      final discipline = _disciplines[index];

      if (!discipline.isConfirmed) {
        discipline.schedules = const [];
        discipline.controller.clear();
        _emitChanges();
        return;
      }

      final removedDiscipline = _disciplines.removeAt(index);
      _disposeDraft(removedDiscipline);

      final hasDraft = _disciplines.any(
        (discipline) => !discipline.isConfirmed,
      );
      if (!hasDraft) {
        _addDraft();
      }

      _emitChanges();
    });
  }

  void _completeDiscipline(
    int index,
    List<AcademicSetupScheduleDraft> schedules,
  ) {
    if (index >= _disciplines.length) return;

    setState(() {
      _disciplines[index].isConfirmed = true;
      _disciplines[index].schedules = schedules;

      final hasDraft = _disciplines.any(
        (discipline) => !discipline.isConfirmed,
      );
      if (!hasDraft) {
        _addDraft();
      }

      _emitChanges();
    });
  }

  Future<void> _onDisciplineOk(int index) async {
    FocusScope.of(context).unfocus();

    final result = await showDialog<ScheduleDialogResult>(
      context: context,
      builder: (_) => const ScheduleDialog(),
    );

    if (result == null || !mounted || index >= _disciplines.length) return;
    if (_disciplines[index].controller.text.trim().isEmpty) return;

    final schedules = result.weekdays.isEmpty
        ? const <AcademicSetupScheduleDraft>[]
        : result.timeRanges.map((timeRange) {
            return AcademicSetupScheduleDraft(
              weekdays: result.weekdays,
              startTimeMinutes: timeRange.startTimeMinutes,
              endTimeMinutes: timeRange.endTimeMinutes,
            );
          }).toList();

    _completeDiscipline(index, schedules);
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
  List<AcademicSetupScheduleDraft> schedules = const [];

  _DisciplineDraft({required this.controller});
}
