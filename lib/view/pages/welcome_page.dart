import 'dart:math' as math;

import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_theme_colors.dart';
import '../widgets/common/app_logo.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/common/or_divider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _authService = AuthService();

  bool _isGoogleLoading = false;

  Future<void> _onGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) return;

      final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
      if (!mounted) return;

      if (isNewUser) {
        AppRoutes.toStudentProfileClearingStack(context);
      } else {
        AppRoutes.toHomeClearingStack(context);
      }
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final showGoogleSignIn = _authService.isGoogleSignInSupported;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 28),
                      const _WelcomeHero(),
                      _WelcomeActions(
                        showGoogleSignIn: showGoogleSignIn,
                        isGoogleLoading: _isGoogleLoading,
                        onLogin: () => AppRoutes.toLogin(context),
                        onRegister: () => AppRoutes.toRegister(context),
                        onGoogleSignIn: _onGoogleSignIn,
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Transform.scale(scale: 0.985 + (0.015 * value), child: child),
        );
      },
      child: Column(
        children: [
          const _BrandMotionStage(),
          const SizedBox(height: 34),
          const _WelcomeTitle(),
          const SizedBox(height: 16),
          Text(
            'Tudo que você precisa para uma boa organização dos seus estudos em um só lugar',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold.copyWith(
              color: colors.textLight,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeTitle extends StatelessWidget {
  const _WelcomeTitle();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final titleStyle = AppTextStyles.headline1.copyWith(
      color: colors.textDark,
      height: 1.04,
      fontSize: 34,
    );

    return Column(
      children: [
        Text('Boas Vindas ao', textAlign: TextAlign.center, style: titleStyle),
        _PlatinumShimmerText(
          text: 'Nexo Estudos',
          style: titleStyle.copyWith(color: colors.primary),
        ),
      ],
    );
  }
}

class _PlatinumShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _PlatinumShimmerText({required this.text, required this.style});

  @override
  State<_PlatinumShimmerText> createState() => _PlatinumShimmerTextState();
}

class _PlatinumShimmerTextState extends State<_PlatinumShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(
        widget.text,
        textAlign: TextAlign.center,
        style: widget.style,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final start = -1.22 + (2.44 * progress);

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(start, -0.48),
              end: Alignment(start + 0.78, 0.48),
              colors: const [
                AppColors.primary,
                Color(0xFF5754BD),
                Color(0xFF6764CC),
                Color(0xFF8A87E3),
                Color(0xFF736FD5),
                Color(0xFF5754BD),
                AppColors.primary,
              ],
              stops: const [0, 0.26, 0.4, 0.5, 0.6, 0.74, 1],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: widget.style,
      ),
    );
  }
}

class _BrandMotionStage extends StatefulWidget {
  const _BrandMotionStage();

  @override
  State<_BrandMotionStage> createState() => _BrandMotionStageState();
}

class _BrandMotionStageState extends State<_BrandMotionStage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _accentController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6800),
    )..repeat();
    _accentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _accentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox(
        width: double.infinity,
        height: 226,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(left: 28, top: 20, child: _BrandAccent(width: 66)),
            Positioned(right: 34, bottom: 18, child: _BrandAccent(width: 50)),
            AppLogo(scale: 0.86),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 226,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: Listenable.merge([_controller, _accentController]),
            builder: (context, child) {
              final time = _controller.value * math.pi * 2;
              final accentTime = _accentController.value * math.pi * 2;
              final pulseTime = time * 2;
              final motion = _easeWave(accentTime);
              final primaryBlockWave = _pulseWave(pulseTime, 0);
              final secondaryBlockWave = _pulseWave(pulseTime, 1.55);
              final topTravel = math.max(0.0, constraints.maxWidth - 90);
              final bottomTravel = math.max(0.0, constraints.maxWidth - 88);

              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 12 + (topTravel * motion),
                    top: 20,
                    child: const _BrandAccent(width: 66),
                  ),
                  Positioned(
                    left: 20 + (bottomTravel * (1 - motion)),
                    bottom: 18,
                    child: const _BrandAccent(width: 50),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: AppLogo(
                      scale: 0.86,
                      blockPulse: _pulse(pulseTime, 0.01, 0),
                      secondaryBlockPulse: _pulse(pulseTime, 0.009, 1.55),
                      blockOffset: Offset(
                        -0.35 * primaryBlockWave,
                        -0.2 * primaryBlockWave,
                      ),
                      secondaryBlockOffset: Offset(
                        0.3 * secondaryBlockWave,
                        0.2 * secondaryBlockWave,
                      ),
                      dotPulses: [
                        _pulse(pulseTime, 0.14, 0),
                        _pulse(pulseTime, 0.17, 0.48),
                        _pulse(pulseTime, 0.14, 0.96),
                        _pulse(pulseTime, 0.13, 1.12),
                        _pulse(pulseTime, 0.16, 1.58),
                        _pulse(pulseTime, 0.13, 2.04),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  double _easeWave(double time) {
    final raw = (math.sin(time - (math.pi / 2)) + 1) / 2;
    return Curves.easeInOut.transform(raw);
  }

  double _pulse(double time, double amount, double phase) {
    return 1 + (amount * _pulseWave(time, phase));
  }

  double _pulseWave(double time, double phase) {
    final wave = (math.sin(time + phase) + 1) / 2;
    return (Curves.easeInOut.transform(wave) * 2) - 1;
  }
}

class _BrandAccent extends StatelessWidget {
  final double width;

  const _BrandAccent({required this.width});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  final bool showGoogleSignIn;
  final bool isGoogleLoading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onGoogleSignIn;

  const _WelcomeActions({
    required this.showGoogleSignIn,
    required this.isGoogleLoading,
    required this.onLogin,
    required this.onRegister,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loginBackground = isDark ? colors.primaryDark : colors.primary;

    return Column(
      children: [
        PrimaryButton(
          label: 'Login',
          onPressed: onLogin,
          backgroundColor: loginBackground,
          textColor: colors.textOnPrimary,
        ),
        const SizedBox(height: 18),
        SecondaryButton(
          label: 'Cadastrar',
          backgroundColor: colors.surface,
          borderColor: colors.primary,
          textColor: colors.textDark,
          backgroundGradient: colors.softSurfaceGradient,
          onPressed: onRegister,
        ),
        if (showGoogleSignIn) ...[
          const SizedBox(height: 22),
          const OrDivider(),
          const SizedBox(height: 22),
          SecondaryButton(
            label: 'Continuar com Google',
            backgroundColor: colors.surface,
            borderColor: colors.outlineStrong,
            textColor: colors.textDark,
            backgroundGradient: colors.softSurfaceGradient,
            leading: Image.asset(
              'lib/view/assets/devicon_google.webp',
              width: 30,
              height: 30,
            ),
            isLoading: isGoogleLoading,
            onPressed: onGoogleSignIn,
          ),
        ],
      ],
    );
  }
}
