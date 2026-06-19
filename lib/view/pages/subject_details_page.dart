import 'package:flutter/material.dart';

import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_theme_extension.dart';
import '../../models/academic_subject.dart';
import '../../models/academic_task.dart';
import '../../repositories/task_repository.dart';
import '../widgets/common/app_bottom_nav_bar.dart';
import '../widgets/common/empty_state_card.dart';

class SubjectDetailsPage extends StatelessWidget {
  final AcademicSubject subject;

  const SubjectDetailsPage({super.key, required this.subject});

  static final _taskRepository = TaskRepository();

  static const _weekdayLabels = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 1) {
      Navigator.of(context).maybePop();
      return;
    }

    final route = switch (index) {
      0 => AppRoutes.home,
      2 => AppRoutes.tasks,
      3 => AppRoutes.schedule,
      _ => AppRoutes.subjects,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      backgroundColor: appTheme.background,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: ScrollConfiguration(
          behavior: const _NoStretchScrollBehavior(),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            clipBehavior: Clip.hardEdge,
            slivers: [
              const SliverToBoxAdapter(child: _DetailsHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 37, 24, 34),
                sliver: SliverList.list(
                  children: [
                    _SubjectSummaryCard(subject: subject),
                    const SizedBox(height: 36),
                    const _SectionTitle(label: 'Horário'),
                    const SizedBox(height: 16),
                    _ScheduleSection(subject: subject),
                    const SizedBox(height: 36),
                    const _SectionTitle(label: 'Tarefas relacionadas'),
                    const SizedBox(height: 16),
                    StreamBuilder<List<AcademicTask>>(
                      stream: _taskRepository.watchTasks(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const EmptyStateCard(
                            icon: Icons.cloud_off_outlined,
                            title: 'Erro ao carregar tarefas',
                            subtitle:
                                'Não foi possível carregar as tarefas desta disciplina.',
                          );
                        }

                        final relatedTasks = (snapshot.data ?? [])
                            .where((task) => task.subject == subject.name)
                            .toList();

                        if (relatedTasks.isEmpty) {
                          return const EmptyStateCard(
                            icon: Icons.assignment_outlined,
                            title: 'Nenhuma tarefa vinculada',
                            subtitle:
                                'As tarefas criadas para esta disciplina aparecerão aqui.',
                          );
                        }

                        return Column(
                          children: relatedTasks.map((task) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RelatedTaskTile(task: task),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _weekdayLabel(int index) {
    if (index < 0 || index >= _weekdayLabels.length) {
      return 'Dia não informado';
    }
    return _weekdayLabels[index];
  }
}

class _ScheduleSection extends StatelessWidget {
  final AcademicSubject subject;

  const _ScheduleSection({required this.subject});

  @override
  Widget build(BuildContext context) {
    if (subject.schedule.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.schedule_outlined,
        title: 'Sem horário cadastrado',
        subtitle: 'Edite a disciplina para adicionar dias e horários de aula.',
      );
    }

    return Column(
      children: subject.schedule.map((entry) {
        final weekdayIndex = entry['weekdayIndex'] as int? ?? 0;
        final startTime = entry['startTime'] as String? ?? '';
        final endTime = entry['endTime'] as String? ?? '';
        final timeLabel = startTime.isEmpty && endTime.isEmpty
            ? 'Horário não informado'
            : '$startTime${endTime.isEmpty ? '' : ' - $endTime'}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ScheduleEntryTile(
            weekday: SubjectDetailsPage._weekdayLabel(weekdayIndex),
            timeLabel: timeLabel,
          ),
        );
      }).toList(),
    );
  }
}

class _RelatedTaskTile extends StatelessWidget {
  final AcademicTask task;

  const _RelatedTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: appTheme.card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: appTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            task.visualPriority == 'Prova'
                ? Icons.edit_square
                : Icons.assignment_outlined,
            color: task.isChecked
                ? AppColors.primary.withValues(alpha: 0.7)
                : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headline3.copyWith(
                    color: appTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    decoration: task.isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: appTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.isChecked ? 'Concluída · ${task.deadlineLabel}' : task.deadlineLabel,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: task.isChecked
                        ? AppColors.primary.withValues(alpha: 0.85)
                        : appTheme.textSecondary,
                    fontSize: 14,
                    fontWeight:
                        task.isChecked ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (task.isChecked)
            Icon(
              Icons.check_circle,
              color: AppColors.primary.withValues(alpha: 0.85),
              size: 22,
            ),
        ],
      ),
    );
  }
}

class _ScheduleEntryTile extends StatelessWidget {
  final String weekday;
  final String timeLabel;

  const _ScheduleEntryTile({
    required this.weekday,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: appTheme.card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: appTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: AppTextStyles.headline3.copyWith(
                    color: appTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeLabel,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: appTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoStretchScrollBehavior extends ScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      height: 62,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: appTheme.inputBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 13),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appTheme.textPrimary,
              size: 32,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 48),
            tooltip: 'Voltar',
          ),
          Text(
            'Detalhes da disciplina',
            textAlign: TextAlign.center,
            style: AppTextStyles.headline3.copyWith(
              color: appTheme.textPrimary,
              fontWeight: FontWeight.w600,
              height: 0.92,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectSummaryCard extends StatelessWidget {
  final AcademicSubject subject;

  const _SubjectSummaryCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      width: double.infinity,
      height: 133,
      decoration: ShapeDecoration(
        color: appTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadows: [
          BoxShadow(
            color: appTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(17, 23, 17, 21),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headline3.copyWith(
                    color: appTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 0.92,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  subject.teacher,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: appTheme.textSecondary,
                    letterSpacing: -1,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: appTheme.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Carga horária: ${subject.workload}h',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: appTheme.textSecondary,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 112,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Média geral',
                  maxLines: 1,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: appTheme.textSecondary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subject.average.toStringAsFixed(1),
                  style: TextStyle(
                    color: appTheme.textPrimary,
                    fontSize: 40,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.55,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Text(
      label,
      style: TextStyle(
        color: appTheme.textPrimary,
        fontSize: 20,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    );
  }
}
