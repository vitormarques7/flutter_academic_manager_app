import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../services/setup/academic_setup_service.dart';
import '../dialogs/subject_dialog.dart';

class DisciplineSetupList extends StatefulWidget {
  final ValueChanged<List<AcademicSetupDisciplineDraft>>? onChanged;

  const DisciplineSetupList({super.key, this.onChanged});

  @override
  State<DisciplineSetupList> createState() => _DisciplineSetupListState();
}

class _DisciplineSetupListState extends State<DisciplineSetupList> {
  final List<AcademicSetupDisciplineDraft> _disciplines = [];

  Future<void> _openSubjectDialog() async {
    final result = await showDialog<SubjectDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => SubjectDialog(
        unavailableScheduleEntries: _unavailableScheduleEntries(),
      ),
    );

    if (result == null || !mounted) return;

    final disciplineName = result.name.trim();
    if (disciplineName.isEmpty) return;

    setState(() {
      _disciplines.add(
        AcademicSetupDisciplineDraft(
          name: disciplineName,
          teacher: result.teacher,
          workload: result.workload,
          schedules: result.schedule.map((entry) {
            return AcademicSetupScheduleDraft(
              weekdays: [entry.weekdayIndex],
              startTimeMinutes: entry.startTimeMinutes,
              endTimeMinutes: entry.endTimeMinutes,
            );
          }).toList(),
        ),
      );
      _emitChanges();
    });
  }

  void _removeDiscipline(int index) {
    if (index >= _disciplines.length) return;

    setState(() {
      _disciplines.removeAt(index);
      _emitChanges();
    });
  }

  void _emitChanges() {
    widget.onChanged?.call(List.unmodifiable(_disciplines));
  }

  List<SubjectScheduleEntry> _unavailableScheduleEntries() {
    return _disciplines.expand((discipline) {
      return discipline.schedules.expand((schedule) {
        return schedule.weekdays.map((weekdayIndex) {
          return SubjectScheduleEntry(
            weekdayIndex: weekdayIndex,
            startTime: _formatMinutes(schedule.startTimeMinutes),
            endTime: _formatMinutes(schedule.endTimeMinutes),
          );
        });
      });
    }).toList();
  }

  String _formatMinutes(int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_disciplines.isEmpty)
          const _EmptyDisciplineSetupState()
        else
          ..._disciplines.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SetupDisciplineTile(
                discipline: entry.value,
                onDelete: () => _removeDiscipline(entry.key),
              ),
            );
          }),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _openSubjectDialog,
            icon: const Icon(Icons.add, size: 22),
            label: const Text('Adicionar disciplina'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: Color(0x7F514EB6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDisciplineSetupState extends StatelessWidget {
  const _EmptyDisciplineSetupState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33514EB6)),
      ),
      child: const Text(
        'Nenhuma disciplina adicionada ainda.',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SetupDisciplineTile extends StatelessWidget {
  final AcademicSetupDisciplineDraft discipline;
  final VoidCallback onDelete;

  const _SetupDisciplineTile({
    required this.discipline,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleSummary = _scheduleSummary();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33514EB6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.primary,
              size: 22,
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
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  scheduleSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover disciplina',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _scheduleSummary() {
    if (discipline.schedules.isEmpty) return 'Sem horário definido';

    final days = discipline.schedules
        .expand((schedule) => schedule.weekdays)
        .toSet()
        .map(_weekdayShortName)
        .join(', ');

    return '$days • ${discipline.schedules.length} ${discipline.schedules.length == 1 ? 'horário' : 'horários'}';
  }

  String _weekdayShortName(int weekdayIndex) {
    return switch (weekdayIndex) {
      0 => 'dom',
      1 => 'seg',
      2 => 'ter',
      3 => 'qua',
      4 => 'qui',
      5 => 'sex',
      6 => 'sab',
      _ => 'dia',
    };
  }
}
