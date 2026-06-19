import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme_extension.dart';

class HeroFormSheet extends StatelessWidget {
  final IconData heroIcon;
  final String title;
  final String subtitle;
  final String? badge;
  final Widget formContent;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool saveEnabled;

  const HeroFormSheet({
    super.key,
    required this.heroIcon,
    required this.title,
    required this.subtitle,
    required this.formContent,
    this.badge,
    this.onSave,
    this.isSaving = false,
    this.saveEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.92;

    return SizedBox(
      width: double.infinity,
      height: sheetHeight,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: sheetHeight,
              decoration: BoxDecoration(
                color: appTheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.shadow,
                    blurRadius: 24,
                    offset: const Offset(0, -6),
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
                        color: appTheme.handle,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: appTheme.badgeBackground,
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
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      badge != null ? 12 : 16,
                      24,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: appTheme.textPrimary,
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
                                style: TextStyle(
                                  color: appTheme.textMuted,
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
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: const Color(0x7F514EB6),
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
          style: TextStyle(
            color: context.appTheme.textSecondary,
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

InputDecoration heroFormInputDecoration(
  BuildContext context, {
  String? hintText,
  Widget? prefixIcon,
}) {
  final appTheme = context.appTheme;

  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    hintStyle: TextStyle(
      color: appTheme.textMuted,
      fontSize: 16,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: appTheme.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: heroFormFieldBorder(context),
    enabledBorder: heroFormFieldBorder(context),
    focusedBorder: heroFormFieldBorder(context, color: AppColors.primary),
    errorBorder: heroFormFieldBorder(context, color: Colors.red),
    focusedErrorBorder: heroFormFieldBorder(context, color: Colors.red),
  );
}

OutlineInputBorder heroFormFieldBorder(
  BuildContext context, {
  Color? color,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color ?? context.appTheme.inputBorder),
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
      return _HeroFormSheetHost(
        animation: animation,
        child: child,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

class _HeroFormSheetHost extends StatefulWidget {
  final Animation<double> animation;
  final Widget child;

  const _HeroFormSheetHost({
    required this.animation,
    required this.child,
  });

  @override
  State<_HeroFormSheetHost> createState() => _HeroFormSheetHostState();
}

class _HeroFormSheetHostState extends State<_HeroFormSheetHost> {
  double _dragOffset = 0;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    if (_dragOffset > 120 || velocity > 700) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: widget.animation,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(curved),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
