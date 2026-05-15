import 'package:academic_manager_app/config/theme/app_colors.dart';
import 'package:academic_manager_app/config/theme/app_text_styles.dart';
import 'package:academic_manager_app/view/pages/filtering_page.dart';
import 'package:academic_manager_app/view/widgets/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../view/widgets/primary_button.dart';
import '../view/widgets/app_text_field.dart';
import '../view/widgets/visibility_toggle.dart';
import '../view/widgets/login_link.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> onRegister() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) AppRoutes.toStudentProfile(context);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                Text('Vamos começar', style: AppTextStyles.headline1),

                const SizedBox(height: 40),

                AppTextField(
                  controller: nameController,
                  label: 'Nome',
                  hint: 'Nome',
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    if (!RegExp(
                      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
                    ).hasMatch(value)) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: passwordController,
                  label: 'Senha',
                  hint: 'Senha',
                  keyboardType: TextInputType.text,
                  obscureText: obscurePassword,
                  suffixIcon: VisibilityToggle(
                    isObscureText: obscurePassword,
                    onTap: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: confirmPasswordController,
                  label: 'Confirmar Senha',
                  hint: 'Confirmar Senha',
                  keyboardType: TextInputType.text,
                  obscureText: obscureConfirmPassword,
                  suffixIcon: VisibilityToggle(
                    isObscureText: obscureConfirmPassword,
                    onTap: () => setState(
                      () => obscureConfirmPassword = !obscureConfirmPassword,
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua senha';
                    }
                    if (value != passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                PrimaryButton(
                  label: 'Entrar',
                  isLoading: isLoading,
                  onPressed: onRegister,
                ),

                const SizedBox(height: 28),

                LoginLink(
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
