import 'package:flutter/material.dart';
import 'package:academic_manager_app/config/theme/app_colors.dart';
import 'package:academic_manager_app/config/theme/app_text_styles.dart';
import 'package:academic_manager_app/view/pages/filtering_page.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/visibility_toggle.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentFilteringPage()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título (fundo claro)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 37,
                right: 37,
                top: 24,
                bottom: 32,
              ),
              child: Text('Vamos começar', style: AppTextStyles.headline1),
            ),
          ),

          // Formulário (fundo roxo)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const ShapeDecoration(
                color: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 37),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      AuthTextField(
                        controller: _nameController,
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

                      AuthTextField(
                        controller: _emailController,
                        hint: 'E-mail',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu e-mail';
                          }
                          if (!RegExp(
                            r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
                          ).hasMatch(value)) {
                            return 'Por favor, insira um e-mail válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      AuthTextField(
                        controller: _passwordController,
                        hint: 'Senha',
                        obscureText: _obscurePassword,
                        suffixIcon: VisibilityToggle(
                          isObscureText: _obscurePassword,
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
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

                      AuthTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirme a senha',
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: VisibilityToggle(
                          isObscureText: _obscureConfirmPassword,
                          onTap: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
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
                        backgroundColor: AppColors.background,
                        textColor: AppColors.textDark,
                      ),

                      const SizedBox(height: 60),

                      // Rodapé
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
