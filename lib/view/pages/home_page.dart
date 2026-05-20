import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _GreetingHeader(name: 'Letícia'),

              const SizedBox(height: 24),

              const _SectionTitle(title: 'VISÃO GERAL'),
              const SizedBox(height: 12),

              const _PerformanceCard(
                icon: Icons.bar_chart,
                title: 'CARD DE DESEMPENHO',
                subtitle: 'Média geral',
                value: '8.5',
              ),

              const SizedBox(height: 12),

              const _FrequencyCard(
                icon: Icons.trending_up,
                title: 'CARD DE FREQUÊNCIA',
                subtitle: 'Percentual total',
                percent: 0.92,
                percentLabel: '92%',
              ),

              const SizedBox(height: 24),

              const _SectionTitle(title: 'PRÓXIMAS TAREFAS'),
              const SizedBox(height: 12),

              const _TaskItem(
                title: 'Entrega de trabalho - Programação',
                date: '24/04',
              ),
              const SizedBox(height: 8),
              const _TaskItem(title: 'Revisar matéria de BD', date: '26/04'),
              const SizedBox(height: 8),
              const _TaskItem(
                title: 'Revisar matéria de Cálculo 1',
                date: '30/04',
              ),

              const SizedBox(height: 24),

              const _SectionTitle(title: 'ALERTAS'),
              const SizedBox(height: 12),

              const _AlertItem(title: 'Prova de Cálculo'),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String name;
  const _GreetingHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: const Icon(Icons.person, color: AppColors.primary, size: 30),
        ),
        const SizedBox(width: 16),
        Text('Olá, $name', style: AppTextStyles.headline2),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.sectionLabel);
  }
}

class _CardBase extends StatelessWidget {
  final Widget child;
  const _CardBase({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  const _PerformanceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _CardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.sectionLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.bodyRegular),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.headline2),
        ],
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double percent;
  final String percentLabel;

  const _FrequencyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.percentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return _CardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.sectionLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.bodyRegular),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(percentLabel, style: AppTextStyles.bodyBold),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
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
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final String date;

  const _TaskItem({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return _CardBase(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTextStyles.bodyRegular)),
          const SizedBox(width: 8),
          Text(date, style: AppTextStyles.bodyRegular),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title;

  const _AlertItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return _CardBase(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTextStyles.bodyRegular)),
        ],
      ),
    );
  }
}
