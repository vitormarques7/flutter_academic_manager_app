import 'package:academic_manager_app/config/theme/app_colors.dart';
import 'package:academic_manager_app/config/theme/app_text_styles.dart';
import 'package:academic_manager_app/view/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StudentFilteringPage extends StatelessWidget {
  const StudentFilteringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 60),

              RichText(
                text: TextSpan(
                  text: 'Qual oseu perfil de ',
                  style: AppTextStyles.headline2,
                  children: [
                    TextSpan(
                      text: 'estudante?',
                      style: AppTextStyles.headline2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Personalize sua experiência selecionando o perfil que mais se encaixa com você',
                style: AppTextStyles.bodyRegular,
              ),

              const SizedBox(height: 40),
              ProfileCard(
                title: 'Estudante Universitário',
                subtitle: 'Estudante de Graduação ou Pós-Graduação',
                onTap: () {},
              ),

              const SizedBox(height: 16),

              ProfileCard(
                title: 'Estudante de Ensino Médio',
                subtitle: '1º, 2º ou 3º ano do Ensino Médio',
                onTap: () {},
              ),

              const SizedBox(height: 16),

              ProfileCard(
                title: 'Estudante Independente',
                subtitle:
                    'Estudando para Vestibular, Concursos ou Aprendizado Pessoal',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
