import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/or_divider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            children: [
              const Spacer(flex: 2),

              const AppLogo(),

              const Spacer(flex: 2),

              const Text(
                'Bem vindo',
                style: TextStyle(
                  color: Color(0xFF191820),
                  fontSize: 40,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Tudo que você precisa para uma boa organização dos seus estudos em um só lugar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.38,
                  letterSpacing: -1,
                ),
              ),

              const Spacer(flex: 2),

              PrimaryButton(
                label: 'Login',
                onPressed: () {
                  // TODO: navegar para Tela login
                },
              ),

              const SizedBox(height: 20),

              SecondaryButton(
                label: 'Cadastrar',
                onPressed: () {
                  // TODO: navegar para Tela cadastro
                },
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
