import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import '../../config/scroll/app_scroll_behavior.dart';
import '../../config/theme/app_colors.dart';
import '../widgets/common/list_section_header.dart';
import '../widgets/common/metadata_chip.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/summary_metric_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _overview = _HomeOverview(
    averageGrade: 8.5,
    frequency: 0.92,
    pendingTasks: 3,
    nextClass: 'Programação',
  );

  static const _tasks = [
    _HomeTask(
      title: 'Entrega de trabalho - Programação',
      subject: 'Programação',
      dueLabel: '24/04',
      type: 'Trabalho',
    ),
    _HomeTask(
      title: 'Revisar matéria de BD',
      subject: 'Banco de Dados',
      dueLabel: '26/04',
      type: 'Estudo',
    ),
    _HomeTask(
      title: 'Revisar matéria de Cálculo 1',
      subject: 'Cálculo I',
      dueLabel: '30/04',
      type: 'Revisão',
    ),
  ];

  static const _alerts = [
    _HomeAlert(
      title: 'Prova de Cálculo',
      description: 'Reserve um bloco de revisão antes da aula.',
      level: _AlertLevel.warning,
    ),
    _HomeAlert(
      title: 'Frequência de Cálculo I em atenção',
      description: '60% registrado no mock atual.',
      level: _AlertLevel.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final firstName = _firstNameFromDisplayName(
      AuthService().currentUser?.displayName,
    );

    return SafeArea(
      child: ScrollConfiguration(
        behavior: const AppScrollBehavior(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(title: 'Olá, $firstName'),
              const SizedBox(height: 24),
              const _StudyFocusCard(overview: _overview),
              const SizedBox(height: 18),
              const _OverviewMetrics(overview: _overview),
              const SizedBox(height: 24),
              ListSectionHeader(
                label: 'PRÓXIMAS TAREFAS',
                count: _tasks.length,
              ),
              const SizedBox(height: 12),
              const _UpcomingTasksCard(tasks: _tasks),
              const SizedBox(height: 24),
              ListSectionHeader(label: 'ALERTAS', count: _alerts.length),
              const SizedBox(height: 12),
              const _AlertsCard(alerts: _alerts),
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

class _StudyFocusCard extends StatelessWidget {
  final _HomeOverview overview;

  const _StudyFocusCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final frequencyPercent = (overview.frequency * 100).round();

    return _HomeCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33587DBD),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seu painel de hoje',
                      style: TextStyle(
                        color: Color(0xFF191820),
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${overview.pendingTasks} tarefas pendentes e $frequencyPercent% de frequência geral.',
                      style: const TextStyle(
                        color: Color(0xFF464552),
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: overview.frequency.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.82),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetadataChip(
                icon: Icons.school_outlined,
                label: 'Próxima aula: ${overview.nextClass}',
              ),
              MetadataChip(
                icon: Icons.bar_chart_outlined,
                label: 'Média ${overview.averageGrade.toStringAsFixed(1)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  final _HomeOverview overview;

  const _OverviewMetrics({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryMetricTile(
            label: 'Média',
            value: overview.averageGrade.toStringAsFixed(1),
            icon: Icons.bar_chart_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryMetricTile(
            label: 'Freq.',
            value: '${(overview.frequency * 100).round()}%',
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryMetricTile(
            label: 'Pendentes',
            value: '${overview.pendingTasks}',
            icon: Icons.pending_actions_outlined,
          ),
        ),
      ],
    );
  }
}

class _UpcomingTasksCard extends StatelessWidget {
  final List<_HomeTask> tasks;

  const _UpcomingTasksCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final entry in tasks.indexed) ...[
            _TaskRow(task: entry.$2),
            if (entry.$1 != tasks.length - 1) const _HomeDivider(),
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final _HomeTask task;

  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: Icons.assignment_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF191820),
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    height: 1.24,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    MetadataChip(
                      icon: Icons.school_outlined,
                      label: task.subject,
                      iconSize: 14,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                    ),
                    MetadataChip(
                      icon: Icons.sell_outlined,
                      label: task.type,
                      iconSize: 14,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _DateBadge(label: task.dueLabel),
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  final List<_HomeAlert> alerts;

  const _AlertsCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final entry in alerts.indexed) ...[
            _AlertRow(alert: entry.$2),
            if (entry.$1 != alerts.length - 1) const _HomeDivider(),
          ],
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final _HomeAlert alert;

  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isWarning = alert.level == _AlertLevel.warning;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(
            icon: isWarning
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            backgroundColor: isWarning
                ? const Color(0xFFFFF3E8)
                : AppColors.primary.withValues(alpha: 0.12),
            foregroundColor: isWarning ? const Color(0xFF9A3412) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF191820),
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    height: 1.24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF464552),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    height: 1.3,
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

class _HomeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _HomeCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E4F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22587DBD),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _IconBadge({
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4C514EB6)),
      ),
      child: Icon(icon, color: foregroundColor ?? AppColors.primary, size: 23),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String label;

  const _DateBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF464552),
          fontSize: 13,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _HomeDivider extends StatelessWidget {
  const _HomeDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE2E4F0),
      indent: 14,
      endIndent: 14,
    );
  }
}

class _HomeOverview {
  final double averageGrade;
  final double frequency;
  final int pendingTasks;
  final String nextClass;

  const _HomeOverview({
    required this.averageGrade,
    required this.frequency,
    required this.pendingTasks,
    required this.nextClass,
  });
}

class _HomeTask {
  final String title;
  final String subject;
  final String dueLabel;
  final String type;

  const _HomeTask({
    required this.title,
    required this.subject,
    required this.dueLabel,
    required this.type,
  });
}

class _HomeAlert {
  final String title;
  final String description;
  final _AlertLevel level;

  const _HomeAlert({
    required this.title,
    required this.description,
    required this.level,
  });
}

enum _AlertLevel { info, warning }
