import 'package:academic_manager_app/config/register_page.dart';
import 'package:academic_manager_app/view/widgets/app_routes.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/or_divider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            children: [
              const Spacer(flex: 2),

              const AppLogo(),

              const Spacer(flex: 2),

              Text('Bem vindo', style: AppTextStyles.headline1),

              const SizedBox(height: 16),

              Text(
                'Tudo que você precisa para uma boa organização dos seus estudos em um só lugar',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.textLight,
                ),
              ),

              const Spacer(flex: 2),

              PrimaryButton(
                label: 'Login',
                onPressed: () {
                  // TODO: navegar para Tela Login
                },
              ),

              const SizedBox(height: 20),

              SecondaryButton(
                label: 'Cadastrar',
                onPressed: () => AppRoutes.toRegister(context),
              ),

              const SizedBox(height: 24),

              const OrDivider(),

              const SizedBox(height: 24),

              SecondaryButton(
                label: 'Continuar com Google',
                leading: Image.asset(
                  'lib/view/assets/devicon_google.webp',
                  width: 30,
                  height: 30,
                ),
                onPressed: () {
                  // TODO: autenticação com Google
                },
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
