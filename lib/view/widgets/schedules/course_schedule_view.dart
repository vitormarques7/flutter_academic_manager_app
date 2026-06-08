import 'package:flutter/material.dart';

import '../../../config/scroll/app_scroll_behavior.dart';
import '../../../config/theme/app_colors.dart';
import 'current_period_schedule.dart';
import 'schedule_models.dart';

class CourseScheduleView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const CourseScheduleView({
    super.key,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CourseScheduleHeader(onBack: onBack),
                    const SizedBox(height: 16),
                    const _ScheduleStats(),
                    const SizedBox(height: 14),
                    CurrentPeriodSchedule(
                      days: _currentPeriodDays,
                      onEdit: onEdit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const List<ScheduleDay> _currentPeriodDays = [
    ScheduleDay(
      weekday: 'Segunda',
      classes: [
        PeriodScheduleClass(
          timeRange: '07:30 - 10:00',
          title: 'Paradigmas de Linguagens de Programação',
          shortTitle: 'PLP',
          code: 'SOF0040G',
          teacher: 'Eraylson Galdino',
          note: 'Compartilhada com L.C',
          color: Color(0xFFE9E8FF),
          accentColor: Color(0xFF514EB6),
        ),
      ],
    ),
    ScheduleDay(
      weekday: 'Terça',
      classes: [
        PeriodScheduleClass(
          timeRange: '09:10 - 12:30',
          title: 'Redes de Computadores',
          shortTitle: 'Redes',
          code: 'SOF0038G',
          teacher: 'Cleiton Martins',
          note: 'Compartilhada com L.C',
          color: Color(0xFFEAF2FF),
          accentColor: Color(0xFF4C7DCC),
        ),
      ],
    ),
    ScheduleDay(
      weekday: 'Quarta',
      classes: [
        PeriodScheduleClass(
          timeRange: '07:30 - 09:10',
          title: 'DCEXT V',
          shortTitle: 'DCEXT V',
          code: 'SOF0056G',
          teacher: 'Mariana',
          color: Color(0xFFE8F6F8),
          accentColor: Color(0xFF2B9EAD),
        ),
        PeriodScheduleClass(
          timeRange: '09:10 - 12:30',
          title: 'Verificação e Validação de Sistemas',
          shortTitle: 'V&V',
          code: 'SOF0041G',
          teacher: 'Ivaldir',
          color: Color(0xFFF0ECFF),
          accentColor: Color(0xFF6D5BD2),
        ),
      ],
    ),
    ScheduleDay(
      weekday: 'Quinta',
      classes: [
        PeriodScheduleClass(
          timeRange: '08:20 - 10:50',
          title: 'Projeto I',
          shortTitle: 'Projeto I',
          code: 'SOF0056G',
          teacher: 'Marcelo Mendonça',
          color: Color(0xFFF6ECFF),
          accentColor: Color(0xFF8A38F5),
        ),
      ],
    ),
    ScheduleDay(
      weekday: 'Sexta',
      classes: [
        PeriodScheduleClass(
          timeRange: '09:10 - 12:30',
          title: 'Programação para Dispositivos Móveis',
          shortTitle: 'Mobile',
          code: 'SOF0041G',
          teacher: 'Elisson Rocha',
          color: Color(0xFFEAF2FF),
          accentColor: Color(0xFF4C7DCC),
        ),
        PeriodScheduleClass(
          timeRange: '13:30 - 16:50',
          title: 'Gerência de Projetos',
          shortTitle: 'GP',
          code: 'SOF0039G',
          teacher: 'Aêda Sousa',
          note: 'Compartilhada com L.C',
          color: Color(0xFFFFEDF5),
          accentColor: Color(0xFFE06AA5),
        ),
      ],
    ),
  ];
}

class _CourseScheduleHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _CourseScheduleHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1FB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tooltip(
                message: 'Voltar',
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Engenharia de Software',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '5º período',
            style: TextStyle(
              color: Color(0xFF656565),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleStats extends StatelessWidget {
  const _ScheduleStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ScheduleStatChip(
            icon: Icons.view_week_outlined,
            label: 'Semana',
            value: '7 aulas',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _ScheduleStatChip(
            icon: Icons.wb_sunny_outlined,
            label: 'Turnos',
            value: 'Manhã e tarde',
          ),
        ),
      ],
    );
  }
}

class _ScheduleStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ScheduleStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22587DBD),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF656565),
                    fontSize: 11,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
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
