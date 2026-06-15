import 'package:flutter/material.dart';
import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:academic_manager_app/config/theme/app_text_styles.dart';
import 'package:academic_manager_app/config/theme/app_theme_colors.dart';
import '../widgets/auth/animated_auth_panel.dart';
import '../widgets/buttons/primary_button.dart';
import '../../config/routes/app_routes.dart';
import '../widgets/inputs/auth_text_field.dart';
import '../widgets/inputs/visibility_toggle.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static final RegExp _emailRegex = RegExp(
    r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
  );

  final _authService = AuthService();
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
      await _authService.registerWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) AppRoutes.toStudentProfileClearingStack(context);
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 37,
                    right: 37,
                    top: 24,
                    bottom: 32,
                  ),
                  child: Text(
                    'Vamos começar',
                    style: AppTextStyles.headline1.copyWith(
                      color: colors.textDark,
                      height: 1.04,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: AnimatedAuthPanel(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: colors.brandGradient,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(34),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 37),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 34),

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
                                if (!_emailRegex.hasMatch(value)) {
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
                              label: 'Cadastrar',
                              isLoading: _isLoading,
                              onPressed: _onRegister,
                              backgroundColor: colors.background,
                              textColor: colors.textDark,
                            ),

                            const SizedBox(height: 42),

                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Já possui uma conta?',
                                    style: TextStyle(
                                      color: colors.textOnPrimary.withValues(
                                        alpha: 0.72,
                                      ),
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => AppRoutes.toLogin(context),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          color: colors.textOnPrimary,
                                          fontSize: 15,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0,
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
              ),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
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
