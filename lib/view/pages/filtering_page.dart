import 'package:flutter/material.dart';
import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:academic_manager_app/config/theme/app_colors.dart';
import 'package:academic_manager_app/config/theme/app_text_styles.dart';

class StudentFilteringPage extends StatelessWidget {
  const StudentFilteringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'CONFIGURAÇÃO INICIAL',
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.headline1.copyWith(height: 1.15),
                        children: [
                          const TextSpan(
                            text:
                                'Qual o seu perfil\n'
                                'de ',
                          ),
                          TextSpan(
                            text: 'estudante?',
                            style: AppTextStyles.headline1.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Personalize sua experiência selecionando o perfil que mais se encaixa com você.',
                style: AppTextStyles.bodyRegular.copyWith(height: 1.5),
              ),

              const SizedBox(height: 40),

              _ProfileOptionCard(
                icon: Icons.school_outlined,
                title: 'Estudante\nUniversitário',
                subtitle: 'Estudantes de Graduação, Pós ou Pesquisa',
                onTap: () => AppRoutes.toUniversityConfig(context),
              ),

              const SizedBox(height: 20),

              _ProfileOptionCard(
                icon: Icons.menu_book_outlined,
                title: 'Estudante de\nEnsino Médio',
                subtitle: '1º, 2º ou 3º ano',
                onTap: () => AppRoutes.toHighSchoolConfig(context),
              ),

              const SizedBox(height: 20),

              _ProfileOptionCard(
                icon: Icons.track_changes_outlined,
                title: 'Estudante\nIndependente',
                subtitle: 'Estudando para Vestibular, Concurso ou outros',
                onTap: () => AppRoutes.toIndependentConfig(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, size: 38, color: AppColors.primary),
              ),

              const SizedBox(width: 18),

              Container(width: 1, height: 80, color: Colors.grey.shade200),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline3.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      subtitle,
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
