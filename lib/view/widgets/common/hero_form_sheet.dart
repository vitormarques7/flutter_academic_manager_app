import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

class HeroFormSheet extends StatelessWidget {
  final IconData heroIcon;
  final String title;
  final String subtitle;
  final String? badge;
  final Widget formContent;
  final VoidCallback onBack;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool saveEnabled;

  const HeroFormSheet({
    super.key,
    required this.heroIcon,
    required this.title,
    required this.subtitle,
    required this.formContent,
    required this.onBack,
    this.badge,
    this.onSave,
    this.isSaving = false,
    this.saveEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () {},
        child: Material(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: sheetHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9E3),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          _CircleHeaderButton(
                            icon: Icons.close_rounded,
                            onPressed: onBack,
                          ),
                          const Spacer(),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F2FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                badge!,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF191820),
                              fontSize: 28,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  heroIcon,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF656565),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          16,
                          24,
                          88 + bottomPadding,
                        ),
                        physics: const ClampingScrollPhysics(),
                        child: formContent,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 24,
                bottom: 24 + bottomPadding,
                child: _SaveFab(
                  onPressed: saveEnabled && !isSaving ? onSave : null,
                  isSaving: isSaving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleHeaderButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F6FA),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: const Color(0xFF191820)),
        ),
      ),
    );
  }
}

class _SaveFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isSaving;

  const _SaveFab({required this.onPressed, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF191820),
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: Colors.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 60,
          height: 60,
          child: isSaving
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 28,
                ),
        ),
      ),
    );
  }
}

class HeroFormField extends StatelessWidget {
  final String label;
  final Widget child;

  const HeroFormField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF464552),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.72,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration heroFormInputDecoration({
  String? hintText,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    hintStyle: const TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 16,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: const Color(0xFFF5F6FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: heroFormFieldBorder(),
    enabledBorder: heroFormFieldBorder(),
    focusedBorder: heroFormFieldBorder(color: AppColors.primary),
    errorBorder: heroFormFieldBorder(color: Colors.red),
    focusedErrorBorder: heroFormFieldBorder(color: Colors.red),
  );
}

OutlineInputBorder heroFormFieldBorder({Color color = const Color(0xFFE8EAF2)}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color),
  );
}

Future<T?> showHeroFormDialog<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _HeroFormDialogScaffold(
        animation: animation,
        child: child,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

class _HeroFormDialogScaffold extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _HeroFormDialogScaffold({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        ],
      ),
    );
  }
}
