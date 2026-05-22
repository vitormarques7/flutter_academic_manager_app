import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../widgets/common/page_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Olá, Usuário'),

              const SizedBox(height: 24),

              const _SectionTitle(title: 'VISÃO GERAL'),
              const SizedBox(height: 12),

              const _PerformanceCard(
                title: 'CARD DE DESEMPENHO',
                subtitle: 'Média geral',
                value: '8.5',
              ),

              const SizedBox(height: 12),

              const _FrequencyCard(
                title: 'CARD DE FREQUÊNCIA',
                subtitle: 'Percentual total',
                percent: 0.92,
                percentLabel: '92%',
              ),

              const SizedBox(height: 24),

              const _SectionTitle(title: 'PRÓXIMAS TAREFAS'),
              const SizedBox(height: 12),

              const _HomeCardBase(
                child: Column(
                  children: [
                    _TaskRow(
                      title: 'Entrega de trabalho - Programação',
                      date: '24/04',
                    ),
                    _Divider(),
                    _TaskRow(title: 'Revisar matéria de BD', date: '26/04'),
                    _Divider(),
                    _TaskRow(
                      title: 'Revisar matéria de Cálculo 1',
                      date: '30/04',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const _SectionTitle(title: 'ALERTAS'),
              const SizedBox(height: 12),

              const _HomeCardBase(
                child: Column(children: [_AlertRow(title: 'Prova de Cálculo')]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ——— Componentes privados da HomePage ———

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF191820),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
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
                  style: const TextStyle(
                    color: Color(0xFF191820),
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
              style: const TextStyle(
                color: Color(0xFF191820),
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
              style: const TextStyle(
                color: Color(0xFF191820),
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
                  style: const TextStyle(
                    color: Color(0xFF191820),
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
              style: const TextStyle(
                color: Color(0xFF191820),
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
                  style: const TextStyle(
                    color: Color(0xFF191820),
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
              style: const TextStyle(
                color: Color(0xFF191820),
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
            style: const TextStyle(
              color: Color(0xFF191820),
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
              style: const TextStyle(
                color: Color(0xFF191820),
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
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0x4C514EB6),
      indent: 16,
      endIndent: 16,
    );
  }
}
