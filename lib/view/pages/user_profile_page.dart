import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF0FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 23, 24, 48),
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileSummaryCard(),
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
                  onTap: () {
                    // TODO: abrir edição de dados pessoais.
                  },
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
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final displayName = user?.displayName?.trim();
    final email = user?.email?.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
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
          const SizedBox(height: 6),
          const _ProfileAvatar(),
          const SizedBox(height: 56),
          Text(
            displayName == null || displayName.isEmpty
                ? 'Usuário'
                : displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.headline2.copyWith(
              fontSize: 32,
              height: 0.69,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 42),
          const _ProfileInfoPill(label: 'Engenharia de software'),
          const SizedBox(height: 18),
          const _ProfileInfoPill(label: '5° Periodo'),
          const SizedBox(height: 28),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: const ShapeDecoration(
        color: AppColors.primary,
        shape: OvalBorder(),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: AppColors.background,
        size: 116,
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0x66587DBD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE4E4FF),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
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
          color: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x66587DBD),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
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
