import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/theme/app_theme_colors.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Gradient? backgroundGradient;
  final double borderRadius;
  final double height;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool isDisabled;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.backgroundColor = AppColors.background,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.textDark,
    this.backgroundGradient,
    this.borderRadius = AppRadius.pill,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    this.textStyle,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveBackgroundColor = backgroundColor == AppColors.background
        ? colors.background
        : backgroundColor;
    final effectiveBorderColor = borderColor == AppColors.primary
        ? colors.primary
        : borderColor;
    final effectiveTextColor = textColor == AppColors.textDark
        ? colors.textDark
        : textColor;
    final bool effectiveDisabled = isDisabled || isLoading;
    final VoidCallback? effectiveOnPressed = effectiveDisabled
        ? null
        : onPressed;

    return Material(
      color: effectiveDisabled
          ? effectiveBackgroundColor.withValues(alpha: 0.5)
          : effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      elevation: effectiveDisabled ? 0 : 1,
      shadowColor: effectiveBorderColor.withValues(alpha: 0.10),
      child: InkWell(
        onTap: effectiveOnPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: double.infinity,
          height: height,
          padding: padding,
          decoration: ShapeDecoration(
            color: backgroundGradient == null ? Colors.transparent : null,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.4, color: effectiveBorderColor),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            gradient: effectiveDisabled ? null : backgroundGradient,
            shadows: effectiveDisabled
                ? null
                : [
                    BoxShadow(
                      color: effectiveBorderColor.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveTextColor,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style:
                          textStyle ??
                          AppTextStyles.button.copyWith(
                            color: effectiveTextColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
