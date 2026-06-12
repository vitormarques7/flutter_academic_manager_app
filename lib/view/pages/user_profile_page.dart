import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/study_cycle.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/user_profile_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  Future<void> _onSignOut(BuildContext context) async {
    try {
      await AuthService().signOut();
      if (context.mounted) AppRoutes.toWelcomeClearingStack(context);
    } on AuthException catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 23, 24, 48),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileSummaryCard(),
              const SizedBox(height: 28),
              const Text(
                'CONFIGURAÇÕES',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  height: 1.47,
                ),
              ),
              const SizedBox(height: 14),
              _SettingsTile(
                label: 'Dados pessoais',
                icon: Icons.badge_outlined,
                iconColor: AppColors.primary,
                iconBackgroundColor: const Color(0x4C514EB6),
                onTap: () => AppRoutes.toPersonalData(context),
              ),
              const SizedBox(height: 18),
              _SettingsTile(
                label: 'Sair',
                icon: Icons.logout,
                iconColor: const Color(0xFFED2B2B),
                iconBackgroundColor: const Color(0x66FF8989),
                textColor: const Color(0xFFED2B2B),
                onTap: () => _onSignOut(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  _ProfileSummaryCard();

  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final StudyCycleRepository _studyCycleRepository = StudyCycleRepository();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final displayName = user?.displayName?.trim();
    final email = user?.email?.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark,
                size: 32,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              tooltip: 'Voltar',
            ),
          ),
          const SizedBox(height: 2),
          const _ProfileAvatar(),
          const SizedBox(height: 26),
          Text(
            displayName == null || displayName.isEmpty
                ? 'Usuário'
                : displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.headline2.copyWith(
              fontSize: 28,
              height: 1.08,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 24),
          _ProfileAcademicInfo(
            userProfileRepository: _userProfileRepository,
            studyCycleRepository: _studyCycleRepository,
          ),
          const SizedBox(height: 22),
          Text(
            email == null || email.isEmpty ? 'E-mail não disponível' : email,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textDark,
              fontSize: 15,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAcademicInfo extends StatefulWidget {
  final UserProfileRepository userProfileRepository;
  final StudyCycleRepository studyCycleRepository;

  const _ProfileAcademicInfo({
    required this.userProfileRepository,
    required this.studyCycleRepository,
  });

  @override
  State<_ProfileAcademicInfo> createState() => _ProfileAcademicInfoState();
}

class _ProfileAcademicInfoState extends State<_ProfileAcademicInfo> {
  late Future<_AcademicInfoLabels> _academicInfoFuture;

  @override
  void initState() {
    super.initState();
    _academicInfoFuture = _loadAcademicInfo();
  }

  Future<_AcademicInfoLabels> _loadAcademicInfo() async {
    final activeStudyCycleId = await widget.userProfileRepository
        .resolveActiveStudyCycleId();

    if (activeStudyCycleId == null) {
      return const _AcademicInfoLabels(
        primary: 'Ciclo acadêmico não configurado',
        secondary: 'Configure seus estudos',
      );
    }

    final studyCycles = await widget.studyCycleRepository.fetchStudyCycles();
    final activeStudyCycle = studyCycles.where(
      (cycle) => cycle.id == activeStudyCycleId,
    );

    if (activeStudyCycle.isEmpty) {
      return const _AcademicInfoLabels(
        primary: 'Ciclo acadêmico não encontrado',
        secondary: 'Configure seus estudos',
      );
    }

    return _AcademicInfoLabels.fromStudyCycle(activeStudyCycle.first);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AcademicInfoLabels>(
      future: _academicInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              _ProfileInfoPill(label: 'Carregando dados acadêmicos...'),
              SizedBox(height: 18),
              _ProfileInfoPill(label: 'Aguarde um instante'),
            ],
          );
        }

        if (snapshot.hasError) {
          return const Column(
            children: [
              _ProfileInfoPill(label: 'Dados acadêmicos indisponíveis'),
              SizedBox(height: 18),
              _ProfileInfoPill(label: 'Tente novamente mais tarde'),
            ],
          );
        }

        final labels = snapshot.data;

        return Column(
          children: [
            _ProfileInfoPill(
              label: labels?.primary ?? 'Ciclo acadêmico não configurado',
            ),
            const SizedBox(height: 18),
            _ProfileInfoPill(
              label: labels?.secondary ?? 'Configure seus estudos',
            ),
          ],
        );
      },
    );
  }
}

class _AcademicInfoLabels {
  final String primary;
  final String secondary;

  const _AcademicInfoLabels({required this.primary, required this.secondary});

  factory _AcademicInfoLabels.fromStudyCycle(StudyCycle studyCycle) {
    return switch (studyCycle.type) {
      StudyCycleType.university => _AcademicInfoLabels(
        primary: studyCycle.courseName ?? 'Curso não informado',
        secondary: studyCycle.period == null
            ? 'Período não informado'
            : '${studyCycle.period}º período',
      ),
      StudyCycleType.highSchool => _AcademicInfoLabels(
        primary: 'Ensino médio',
        secondary: studyCycle.schoolYear == null
            ? 'Ano letivo não informado'
            : '${studyCycle.schoolYear}º ano',
      ),
      StudyCycleType.independent => _AcademicInfoLabels(
        primary: studyCycle.goal ?? 'Objetivo não informado',
        secondary: 'Estudo independente',
      ),
    };
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.subtle,
      ),
      child: Image.asset(
        'lib/view/assets/profile_pic_v2.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ProfileInfoPill extends StatelessWidget {
  final String label;

  const _ProfileInfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 296, minHeight: 54),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.subtle,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyRegular.copyWith(
          color: AppColors.textDark,
          fontSize: 15,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.onTap,
    this.textColor = AppColors.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 74,
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          shadows: AppShadows.subtle,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: iconBackgroundColor,
                shape: const OvalBorder(),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: textColor,
                  fontSize: 20,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
