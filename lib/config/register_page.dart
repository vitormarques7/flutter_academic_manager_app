import 'package:flutter/material.dart';
import 'package:academic_manager_app/config/theme/app_colors.dart';
import 'package:academic_manager_app/config/theme/app_text_styles.dart';
import 'package:academic_manager_app/view/pages/filtering_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../widgets/primary_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/visibility_toggle.dart';
import '../widgets/login_link.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                Text('Vamos começar', style: AppTextStyles.headline1),

                const SizedBox(height: 40),

                AppTextField(
                  controller: _nameController,
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
                  controller: _emailController,
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
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Senha',
                  keyboardType: TextInputType.text,
                  obscureText: _obscurePassword,
                  suffixIcon: VisibilityToggle(
                    isObscureText: _obscurePassword,
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
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
                  controller: _confirmPasswordController,
                  label: 'Confirmar Senha',
                  hint: 'Confirmar Senha',
                  keyboardType: TextInputType.text,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: VisibilityToggle(
                    isObscureText: _obscureConfirmPassword,
                    onTap: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),

                      const SizedBox(height: 40),

                PrimaryButton(
                  label: 'Entrar',
                  isLoading: _isLoading,
                  onPressed: _onRegister,
                ),

                      const SizedBox(height: 60),

                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Já possui uma conta?',
                              style: TextStyle(
                                color: Color(0x7FE7E7E7),
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                letterSpacing: -1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFFF5F5F5),
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
