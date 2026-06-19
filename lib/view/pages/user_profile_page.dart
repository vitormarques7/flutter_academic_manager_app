import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_theme_extension.dart';
import '../../services/theme/theme_controller.dart';
import '../../models/academic_subject.dart';
import '../../models/academic_task.dart';
import '../../models/user_profile.dart';
import '../../repositories/subject_repository.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../widgets/common/hero_form_sheet.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  static final _profileRepository = UserProfileRepository();
  static final _subjectRepository = SubjectRepository();
  static final _taskRepository = TaskRepository();

  Future<void> _onSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text('Deseja encerrar sua sessão neste dispositivo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await AuthService().signOut();
      if (context.mounted) AppRoutes.toAuthGateClearingStack(context);
    } on AuthException catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _openPersonalDataSheet(
    BuildContext context, {
    required UserProfile profile,
  }) async {
    await showHeroFormDialog<void>(
      context: context,
      child: _PersonalDataSheet(
        profile: profile,
        profileRepository: _profileRepository,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: appTheme.surfaceTint,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: StreamBuilder<UserProfile>(
            stream: _profileRepository.watchProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting &&
                  !profileSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final profile = profileSnapshot.data ?? const UserProfile();

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 23, 24, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileSummaryCard(profile: profile),
                      const SizedBox(height: 24),
                      const _SectionLabel(title: 'RESUMO ACADÊMICO'),
                      const SizedBox(height: 12),
                      StreamBuilder<List<AcademicSubject>>(
                        stream: _subjectRepository.watchSubjects(),
                        builder: (context, subjectsSnapshot) {
                          return StreamBuilder<List<AcademicTask>>(
                            stream: _taskRepository.watchTasks(),
                            builder: (context, tasksSnapshot) {
                              final subjects = subjectsSnapshot.data ?? [];
                              final tasks = tasksSnapshot.data ?? [];
                              final pendingTasks =
                                  tasks.where((task) => !task.isChecked).length;
                              final average = _overallAverage(subjects);

                              return _ProfileStatsGrid(
                                subjectCount: subjects.length,
                                taskCount: tasks.length,
                                pendingTaskCount: pendingTasks,
                                averageLabel: subjects.isEmpty
                                    ? '—'
                                    : average.toStringAsFixed(1),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      const _SectionLabel(title: 'CONFIGURAÇÕES'),
                      const SizedBox(height: 14),
                      _SettingsTile(
                        label: 'Dados pessoais',
                        subtitle: 'Nome, curso e período',
                        icon: Icons.badge_outlined,
                        iconColor: AppColors.primary,
                        iconBackgroundColor: const Color(0x4C514EB6),
                        onTap: () => _openPersonalDataSheet(
                          context,
                          profile: profile,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListenableBuilder(
                        listenable: ThemeController.instance,
                        builder: (context, _) {
                          return _DarkModeTile(
                            enabled: ThemeController.instance.isDarkMode,
                            onChanged: ThemeController.instance.setDarkMode,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _SettingsInfoTile(
                        label: 'Conta',
                        subtitle: AuthService().currentUser?.email ??
                            'E-mail não disponível',
                        icon: Icons.mail_outline,
                        iconColor: AppColors.primary,
                        iconBackgroundColor: const Color(0x4C514EB6),
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        label: 'Sair',
                        subtitle: 'Encerrar sessão neste dispositivo',
                        icon: Icons.logout,
                        iconColor: const Color(0xFFED2B2B),
                        iconBackgroundColor: const Color(0x66FF8989),
                        textColor: const Color(0xFFED2B2B),
                        onTap: () => _onSignOut(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static double _overallAverage(List<AcademicSubject> subjects) {
    if (subjects.isEmpty) return 0;

    final total = subjects.fold<double>(
      0,
      (sum, subject) => sum + subject.average,
    );

    return total / subjects.length;
  }
}

class _PersonalDataSheet extends StatefulWidget {
  final UserProfile profile;
  final UserProfileRepository profileRepository;

  const _PersonalDataSheet({
    required this.profile,
    required this.profileRepository,
  });

  @override
  State<_PersonalDataSheet> createState() => _PersonalDataSheetState();
}

class _PersonalDataSheetState extends State<_PersonalDataSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _courseController;
  late final TextEditingController _periodController;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isIndependent => widget.profile.studentType == 'independente';

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _nameController = TextEditingController(
      text: user?.displayName?.trim() ?? '',
    );
    _courseController = TextEditingController(
      text: widget.profile.course?.trim() ??
          widget.profile.goal?.trim() ??
          '',
    );
    _periodController = TextEditingController(
      text: widget.profile.periodLabel?.trim() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final course = _courseController.text.trim();
      final period = _periodController.text.trim();

      if (_isIndependent) {
        await widget.profileRepository.saveProfile(
          UserProfileInput(goal: course),
        );
        await widget.profileRepository.updatePersonalData(
          displayName: name,
          course: null,
          periodLabel: null,
        );
      } else {
        await widget.profileRepository.updatePersonalData(
          displayName: name,
          course: course,
          periodLabel: period,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso.')),
        );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage =
            'Não foi possível salvar seus dados. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeroFormSheet(
      heroIcon: Icons.badge_outlined,
      title: 'Dados pessoais',
      subtitle: 'Atualize suas informações acadêmicas',
      badge: 'Perfil',
      onSave: _save,
      isSaving: _isSaving,
      formContent: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroFormField(
              label: 'NOME',
              child: TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: heroFormInputDecoration(context,hintText: 'Seu nome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu nome.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            HeroFormField(
              label: _isIndependent ? 'OBJETIVO DE ESTUDO' : 'CURSO',
              child: TextFormField(
                controller: _courseController,
                decoration: heroFormInputDecoration(context,
                  hintText: _isIndependent
                      ? 'Ex: Passar no ENEM'
                      : 'Ex: Engenharia de Software',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _isIndependent
                        ? 'Informe seu objetivo.'
                        : 'Informe seu curso.';
                  }
                  return null;
                },
              ),
            ),
            if (!_isIndependent) ...[
              const SizedBox(height: 20),
              HeroFormField(
                label: 'PERÍODO OU SÉRIE',
                child: TextFormField(
                  controller: _periodController,
                  decoration: heroFormInputDecoration(context,
                    hintText: 'Ex: 5º período ou 2º ano',
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final UserProfile profile;

  const _ProfileSummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final displayName = user?.displayName?.trim();
    final email = user?.email?.trim();
    final resolvedName = displayName == null || displayName.isEmpty
        ? 'Usuário'
        : displayName;
    final primaryLabel = profile.primaryLabel;
    final secondaryLabel = profile.secondaryLabel;
    final studentTypeLabel = profile.studentTypeLabel;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.appTheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: context.appTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.appTheme.textPrimary,
                size: 28,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              tooltip: 'Voltar',
            ),
          ),
          const SizedBox(height: 8),
          _ProfileAvatar(name: resolvedName),
          const SizedBox(height: 20),
          Text(
            resolvedName,
            textAlign: TextAlign.center,
            style: AppTextStyles.headline2.copyWith(
              fontSize: 28,
              height: 1.1,
              letterSpacing: -0.5,
              color: context.appTheme.textPrimary,
            ),
          ),
          if (studentTypeLabel != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                studentTypeLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (primaryLabel != null) ...[
            const SizedBox(height: 20),
            _ProfileInfoPill(
              icon: Icons.school_outlined,
              label: primaryLabel,
            ),
          ],
          if (secondaryLabel != null) ...[
            const SizedBox(height: 10),
            _ProfileInfoPill(
              icon: Icons.calendar_today_outlined,
              label: secondaryLabel,
            ),
          ],
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              email,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular.copyWith(
                color: context.appTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String name;

  const _ProfileAvatar({required this.name});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first == 'Usuário') return 'U';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const ShapeDecoration(
        color: AppColors.primary,
        shape: OvalBorder(),
        shadows: [
          BoxShadow(
            color: Color(0x4C514EB6),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileInfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: appTheme.badgeBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyRegular.copyWith(
                color: appTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsGrid extends StatelessWidget {
  final int subjectCount;
  final int taskCount;
  final int pendingTaskCount;
  final String averageLabel;

  const _ProfileStatsGrid({
    required this.subjectCount,
    required this.taskCount,
    required this.pendingTaskCount,
    required this.averageLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.menu_book_outlined,
                label: 'Disciplinas',
                value: '$subjectCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.assignment_outlined,
                label: 'Tarefas',
                value: '$taskCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.pending_actions_outlined,
                label: 'Pendentes',
                value: '$pendingTaskCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.bar_chart_rounded,
                label: 'Média geral',
                value: averageLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: appTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: appTheme.textMuted,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: appTheme.textPrimary,
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.appTheme.textPrimary,
        fontSize: 15,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        height: 1.47,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DarkModeTile extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _DarkModeTile({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsInfoTile(
      label: 'Modo escuro',
      subtitle: enabled ? 'Tema escuro ativado' : 'Tema claro ativado',
      icon: enabled ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      iconColor: AppColors.primary,
      iconBackgroundColor: const Color(0x4C514EB6),
      trailing: Switch(
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingsInfoTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Widget? trailing;

  const _SettingsInfoTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: appTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: appTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: iconBackgroundColor,
              shape: const OvalBorder(),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: appTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: appTheme.textMuted,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final labelColor = textColor ?? appTheme.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          width: double.infinity,
          decoration: ShapeDecoration(
            color: appTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            shadows: [
              BoxShadow(
                color: appTheme.shadow,
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(
                  color: iconBackgroundColor,
                  shape: const OvalBorder(),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: labelColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: appTheme.textMuted,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: labelColor.withValues(alpha: 0.55),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
