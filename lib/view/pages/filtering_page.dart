import 'package:academic_manager_app/config/theme/app_text_styles.dart';
import 'package:academic_manager_app/config/theme/app_theme_colors.dart';
import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:academic_manager_app/view/widgets/buttons/cancel_button.dart';
import 'package:academic_manager_app/view/widgets/selectors/profile_card.dart';
import 'package:flutter/material.dart';

class StudentFilteringPage extends StatelessWidget {
  const StudentFilteringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = Padding(
              padding: const EdgeInsets.fromLTRB(37, 44, 37, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Qual o seu perfil de ',
                      style: AppTextStyles.headline2.copyWith(
                        color: colors.textDark,
                      ),
                      children: [
                        TextSpan(
                          text: 'estudante?',
                          style: AppTextStyles.headline2.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Personalize sua experiência selecionando o perfil que mais se encaixa com você',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: colors.textLight,
                    ),
                  ),

                  const SizedBox(height: 28),
                  ProfileCard(
                    title: 'Estudante\nUniversitário',
                    subtitle: 'Estudantes de Graduação, Pós ou Pesquisa',
                    onTap: () => AppRoutes.toUniversityConfig(context),
                  ),

                  const SizedBox(height: 16),

                  ProfileCard(
                    title: 'Estudante de\nEnsino Médio',
                    subtitle: '1º, 2º ou 3º ano',
                    onTap: () => AppRoutes.toHighSchoolConfig(context),
                  ),

                  const SizedBox(height: 16),

                  ProfileCard(
                    title: 'Estudante\nIndependente',
                    subtitle: 'Estudando para Vestibular, Concurso ou outros',
                    onTap: () => AppRoutes.toIndependentConfig(context),
                  ),

                  const Spacer(),
                  const CancelButton(),
                ],
              ),
            );

            if (constraints.maxHeight < 760) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(child: content),
                ),
              );
            }

            return content;
          },
        ),
      ),
    );
  }
}
