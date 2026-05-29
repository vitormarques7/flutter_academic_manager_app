import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:academic_manager_app/view/pages/welcome_page.dart';
import 'package:academic_manager_app/view/shell/main_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasData) {
          return const MainShell();
        }

        return const WelcomePage();
      },
    );
  }
}
