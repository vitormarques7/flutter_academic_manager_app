import 'package:flutter/material.dart';
import 'package:academic_manager_app/services/auth/auth_service.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../config/routes/app_routes.dart';
import '../widgets/auth/animated_auth_panel.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/auth_text_field.dart';
import '../widgets/inputs/visibility_toggle.dart';
import '../widgets/buttons/back_image_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final RegExp _emailRegex = RegExp(
    r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
  );

  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSendingPasswordReset = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) AppRoutes.toHomeClearingStack(context);
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onPasswordReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Informe seu e-mail para recuperar a senha.');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      _showMessage('Informe um e-mail válido para recuperar a senha.');
      return;
    }

    setState(() => _isSendingPasswordReset = true);
    try {
      await _authService.sendPasswordReset(email);
      if (mounted) {
        _showMessage('Enviamos um link de recuperação para seu e-mail.');
      }
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isSendingPasswordReset = false);
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
                    'Bem vindo\nde volta',
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
                            const SizedBox(height: 40),

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
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _isSendingPasswordReset
                                    ? null
                                    : _onPasswordReset,
                                child: Text(
                                  _isSendingPasswordReset
                                      ? 'Enviando...'
                                      : 'Esqueceu a senha?',
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
                              ),
                            ),

                            const SizedBox(height: 46),

                            PrimaryButton(
                              label: 'Entrar',
                              isLoading: _isLoading,
                              onPressed: _onLogin,
                              backgroundColor: colors.background,
                              textColor: colors.textDark,
                            ),

                            const SizedBox(height: 54),

                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Ainda não possui um cadastro?',
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
                                    onTap: () => AppRoutes.toRegister(context),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'Cadastrar',
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

          const Positioned(left: 47, bottom: 32, child: BackImageButton()),
        ],
      ),
    );
  }
}
