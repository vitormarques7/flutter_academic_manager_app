import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../widgets/common/app_bottom_nav_bar.dart';

class SubjectDetailsPage extends StatelessWidget {
  final String name;
  final String teacher;
  final double average;
  final int workload;

  const SubjectDetailsPage({
    super.key,
    required this.name,
    required this.teacher,
    required this.average,
    required this.workload,
  });

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
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    _SubjectSummaryCard(
                      name: name,
                      teacher: teacher,
                      average: average,
                      workload: workload,
                    ),
                    const SizedBox(height: 36),
                    const _SectionTitle(label: 'Avaliações'),
                    const SizedBox(height: 28),
                    const _EmptyActionCard(
                      actionLabel: 'Avaliações',
                      buttonWidth: 210,
                    ),
                    const SizedBox(height: 36),
                    const _SectionTitle(label: 'Tarefas relacionadas'),
                    const SizedBox(height: 28),
                    const _EmptyActionCard(
                      actionLabel: 'Tarefas',
                      buttonWidth: 210,
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
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4FF), width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 13),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
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
  final String name;
  final String teacher;
  final double average;
  final int workload;

  const _SubjectSummaryCard({
    required this.name,
    required this.teacher,
    required this.average,
    required this.workload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 133,
      decoration: ShapeDecoration(
        color: const Color(0xFFEFF0FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadows: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
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
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headline3.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 0.92,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  teacher,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textDark,
                    letterSpacing: -1,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.textDark,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Carga horária: ${workload}h',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: AppColors.textDark,
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
                    color: AppColors.textDark,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  average.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.textDark,
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
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    );
  }
}

class _EmptyActionCard extends StatelessWidget {
  final String actionLabel;
  final double buttonWidth;

  const _EmptyActionCard({
    required this.actionLabel,
    required this.buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 262,
      decoration: ShapeDecoration(
        color: const Color(0xFFEFF0FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadows: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(left: 17, right: 17, top: 71, child: _CardDivider()),
          const Positioned(
            left: 17,
            right: 17,
            top: 148,
            child: _CardDivider(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: _AddEntryButton(label: actionLabel, width: buttonWidth),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0x4C514EB6));
  }
}

class _AddEntryButton extends StatelessWidget {
  final String label;
  final double width;

  const _AddEntryButton({required this.label, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 44,
      decoration: ShapeDecoration(
        color: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadows: const [
          BoxShadow(
            color: Color(0x7F514EB6),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: AppColors.background, size: 28),
          const SizedBox(width: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
