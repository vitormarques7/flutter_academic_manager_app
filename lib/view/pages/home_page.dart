import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme_extension.dart';
import '../../models/academic_subject.dart';
import '../../models/academic_task.dart';
import '../../repositories/subject_repository.dart';
import '../../repositories/task_repository.dart';
import '../shell/main_shell_scope.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/page_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final TaskRepository _taskRepository = TaskRepository();
  static final SubjectRepository _subjectRepository = SubjectRepository();

  @override
  Widget build(BuildContext context) {
    final firstName = _firstNameFromDisplayName(
      AuthService().currentUser?.displayName,
    );

    return SafeArea(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(title: 'Olá, $firstName'),

              const SizedBox(height: 24),

              const _SectionTitle(title: 'VISÃO GERAL'),
              const SizedBox(height: 12),

              StreamBuilder<List<AcademicSubject>>(
                stream: _subjectRepository.watchSubjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const _HomeOverviewLoading();
                  }

                  if (snapshot.hasError) {
                    return const EmptyStateCard(
                      icon: Icons.cloud_off_outlined,
                      title: 'Não foi possível carregar o desempenho',
                      subtitle: 'Verifique sua conexão e tente novamente.',
                    );
                  }

                  final subjects = snapshot.data ?? [];
                  final overallAverage = _overallAverage(subjects);
                  final overallFrequency = _overallFrequency(subjects);

                  if (subjects.isEmpty) {
                    return EmptyStateCard(
                      icon: Icons.school_outlined,
                      title: 'Sem disciplinas ainda',
                      subtitle:
                          'Cadastre suas disciplinas para acompanhar média e frequência.',
                      actionLabel: 'Ir para Disciplinas',
                      onAction: () =>
                          MainShellScope.maybeOf(context)?.selectTab(1),
                    );
                  }

                  return Column(
                    children: [
                      _PerformanceCard(
                        title: 'Desempenho',
                        subtitle: 'Média geral',
                        value: _formatOverallAverage(
                          overallAverage,
                          hasSubjects: subjects.isNotEmpty,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FrequencyCard(
                        title: 'Frequência',
                        subtitle: 'Percentual total',
                        percent: overallFrequency,
                        percentLabel: _formatOverallFrequencyLabel(
                          overallFrequency,
                          hasSubjects: subjects.isNotEmpty,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              StreamBuilder<List<AcademicTask>>(
                stream: _taskRepository.watchTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const _HomeTasksLoading();
                  }

                  if (snapshot.hasError) {
                    return const EmptyStateCard(
                      icon: Icons.cloud_off_outlined,
                      title: 'Não foi possível carregar as tarefas',
                      subtitle: 'Verifique sua conexão e tente novamente.',
                    );
                  }

                  final tasks = snapshot.data ?? [];
                  final upcomingTasks = _upcomingTasks(tasks);
                  final alertTasks = _alertTasks(tasks);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(title: 'PRÓXIMAS TAREFAS'),
                      const SizedBox(height: 12),
                      _UpcomingTasksCard(tasks: upcomingTasks),
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'ALERTAS'),
                      const SizedBox(height: 12),
                      _AlertsCard(tasks: alertTasks),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _firstNameFromDisplayName(String? displayName) {
    final trimmedName = displayName?.trim();
    if (trimmedName == null || trimmedName.isEmpty) return 'Usuário';

    return trimmedName.split(RegExp(r'\s+')).first;
  }
}

double _overallAverage(List<AcademicSubject> subjects) {
  if (subjects.isEmpty) return 0;

  final total = subjects.fold<double>(0, (sum, subject) => sum + subject.average);
  return total / subjects.length;
}

double _overallFrequency(List<AcademicSubject> subjects) {
  if (subjects.isEmpty) return 0;

  final total = subjects.fold<double>(
    0,
    (sum, subject) => sum + subject.frequency.clamp(0, 1),
  );

  return (total / subjects.length).clamp(0, 1);
}

String _formatOverallAverage(double average, {required bool hasSubjects}) {
  if (!hasSubjects) return '—';

  return average.toStringAsFixed(1);
}

String _formatOverallFrequencyLabel(double frequency, {required bool hasSubjects}) {
  if (!hasSubjects) return '—';

  return '${(frequency * 100).round()}%';
}

List<AcademicTask> _upcomingTasks(List<AcademicTask> tasks) {
  final pending = tasks.where((task) => !task.isChecked).toList();

  pending.sort((a, b) {
    final aDate = _parseDeadline(a.deadline);
    final bDate = _parseDeadline(b.deadline);

    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;

    return aDate.compareTo(bDate);
  });

  return pending.take(3).toList();
}

List<AcademicTask> _alertTasks(List<AcademicTask> tasks) {
  return tasks
      .where(
        (task) => !task.isChecked && task.visualPriority == 'Prova',
      )
      .take(3)
      .toList();
}

DateTime? _parseDeadline(String deadline) {
  final parts = deadline.split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) return null;

  return DateTime(year, month, day);
}

String _shortDeadlineLabel(String deadline) {
  final parts = deadline.split('/');
  if (parts.length == 3) {
    return '${parts[0]}/${parts[1]}';
  }

  return deadline.isEmpty ? '—' : deadline;
}

// ——— Componentes privados da HomePage ———

class _HomeOverviewLoading extends StatelessWidget {
  const _HomeOverviewLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _HomeTasksLoading extends StatelessWidget {
  const _HomeTasksLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'PRÓXIMAS TAREFAS'),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _UpcomingTasksCard extends StatelessWidget {
  final List<AcademicTask> tasks;

  const _UpcomingTasksCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyStateCard(
        icon: Icons.event_available_outlined,
        title: 'Nenhuma tarefa pendente',
        subtitle: 'Suas próximas entregas aparecerão aqui.',
        actionLabel: 'Criar tarefa',
        onAction: () => MainShellScope.maybeOf(context)?.selectTab(2),
      );
    }

    return _HomeCardBase(
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const _Divider(),
            _TaskRow(
              title: tasks[i].title,
              date: _shortDeadlineLabel(tasks[i].deadline),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  final List<AcademicTask> tasks;

  const _AlertsCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.notifications_none_outlined,
        title: 'Nenhum alerta no momento',
        subtitle: 'Provas e prazos importantes aparecerão aqui.',
      );
    }

    return _HomeCardBase(
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const _Divider(),
            _AlertRow(title: 'Prova de ${tasks[i].subject}'),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Text(
      title,
      style: TextStyle(
        color: appTheme.textPrimary,
        fontSize: 15,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        height: 1.47,
      ),
    );
  }
}

class _HomeCardBase extends StatelessWidget {
  final Widget child;
  const _HomeCardBase({required this.child});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;

  const _PerformanceCard({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return _HomeCardBase(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: appTheme.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: appTheme.textPrimary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.57,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: appTheme.textPrimary,
                fontSize: 36,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0.61,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percent;
  final String percentLabel;

  const _FrequencyCard({
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.percentLabel,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return _HomeCardBase(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: appTheme.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: appTheme.textPrimary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.57,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  percentLabel,
                  style: TextStyle(
                    color: appTheme.textPrimary,
                    fontSize: 36,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 0.61,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: const Color(0x7F514EB6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final String title;
  final String date;

  const _TaskRow({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: appTheme.textPrimary,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.38,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            date,
            style: TextStyle(
              color: appTheme.textSecondary,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.47,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String title;

  const _AlertRow({required this.title});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: appTheme.textPrimary,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.primary.withValues(alpha: 0.3),
      indent: 16,
      endIndent: 16,
    );
  }
}
