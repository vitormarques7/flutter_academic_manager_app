import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/routes/app_routes.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/visibility_toggle.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

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
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) AppRoutes.toStudentProfile(context);
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
              child: Text(
                'Bem vindo\nde volta',
                style: AppTextStyles.headline1,
              ),
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

                      // Campo E-mail
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

                      // Campo Senha
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

                      // Esqueceu a senha
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: recuperação de senha
                          },
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              color: Color(0x7FE7E7E7),
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Botão Entrar (fundo branco sobre roxo)
                      PrimaryButton(
                        label: 'Entrar',
                        isLoading: _isLoading,
                        onPressed: _onLogin,
                        backgroundColor: AppColors.background,
                        textColor: AppColors.textDark,
                      ),

                      const SizedBox(height: 80),

                      // Rodapé: Ainda não possui cadastro?
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Ainda não possui um cadastro?',
                              style: TextStyle(
                                color: Color(0x7FE7E7E7),
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                letterSpacing: -1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => AppRoutes.toRegister(context),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Cadastrar',
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
