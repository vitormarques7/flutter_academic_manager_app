import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:academic_manager_app/services/user_data_bootstrap_service.dart';
import 'package:academic_manager_app/view/pages/filtering_page.dart';
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
  String? _bootstrapUserId;
  Future<String?>? _bootstrapFuture;

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
          return _AuthenticatedGate(
            future: _ensureCurrentUserData(snapshot.data!),
            onRetry: () => _retryBootstrap(snapshot.data!),
          );
        }

        return const WelcomePage();
      },
    );
  }

  Future<String?> _ensureCurrentUserData(User user) {
    if (_bootstrapUserId != user.uid || _bootstrapFuture == null) {
      _bootstrapUserId = user.uid;
      _bootstrapFuture = _bootstrapService.ensureCurrentUserData(
        displayName: user.displayName,
        email: user.email,
      );
    }

    return _bootstrapFuture!;
  }

  void _retryBootstrap(User user) {
    setState(() {
      _bootstrapUserId = null;
      _bootstrapFuture = _bootstrapService.ensureCurrentUserData(
        displayName: user.displayName,
        email: user.email,
      );
      _bootstrapUserId = user.uid;
    });
  }
}

class _AuthenticatedGate extends StatelessWidget {
  final Future<String?> future;
  final VoidCallback onRetry;

  const _AuthenticatedGate({required this.future, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AuthGateLoading();
        }

        if (snapshot.hasError) {
          return _AuthGateError(onRetry: onRetry);
        }

        final activeStudyCycleId = snapshot.data;
        if (activeStudyCycleId == null) {
          return const StudentFilteringPage();
        }

        return const MainShell();
      },
    );
  }
}

class _AuthGateLoading extends StatelessWidget {
  const _AuthGateLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _AuthGateError extends StatelessWidget {
  final VoidCallback onRetry;

  const _AuthGateError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.primary,
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                'Não foi possível carregar seus dados.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verifique sua conexão e tente novamente.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
