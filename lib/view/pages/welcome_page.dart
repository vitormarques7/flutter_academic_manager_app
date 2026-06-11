import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../widgets/common/app_logo.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/common/or_divider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _authService = AuthService();

  bool _isGoogleLoading = false;

  Future<void> _onGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) return;

      final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
      if (!mounted) return;

      if (isNewUser) {
        AppRoutes.toStudentProfileClearingStack(context);
      } else {
        AppRoutes.toHomeClearingStack(context);
      }
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final showGoogleSignIn = _authService.isGoogleSignInSupported;

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

              Text(
                'Bem-vindo',
                style: AppTextStyles.headline1.copyWith(height: 1.05),
              ),

              const SizedBox(height: 16),

              Text(
                'Tudo que você precisa para uma boa organização dos seus estudos em um só lugar',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.textLight,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),

              const Spacer(flex: 2),

              PrimaryButton(
                label: 'Login',
                onPressed: () => AppRoutes.toLogin(context),
              ),

              const SizedBox(height: 20),

              SecondaryButton(
                label: 'Cadastrar',
                onPressed: () => AppRoutes.toRegister(context),
              ),

              if (showGoogleSignIn) ...[
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
                  isLoading: _isGoogleLoading,
                  onPressed: _onGoogleSignIn,
                ),
              ],

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
