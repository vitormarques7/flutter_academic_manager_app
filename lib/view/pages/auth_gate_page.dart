import 'dart:async';

import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:academic_manager_app/services/user_data_bootstrap_service.dart';
import 'package:academic_manager_app/view/pages/welcome_page.dart';
import 'package:academic_manager_app/view/shell/main_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  final AuthService _authService = AuthService();
  final UserDataBootstrapService _bootstrapService = UserDataBootstrapService();
  String? _bootstrappedUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
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
          _ensureCurrentUserData(snapshot.data!);
          return const MainShell();
        }

        return const WelcomePage();
      },
    );
  }

  void _ensureCurrentUserData(User user) {
    if (_bootstrappedUserId == user.uid) return;

    _bootstrappedUserId = user.uid;
    unawaited(
      _bootstrapService
          .ensureCurrentUserData(
            displayName: user.displayName,
            email: user.email,
          )
          .catchError((_) {}),
    );
  }
}
