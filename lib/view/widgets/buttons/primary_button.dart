import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/theme/app_theme_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double height;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final Widget? leading;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.borderRadius = AppRadius.pill,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.textStyle,
    this.leading,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveBackgroundColor =
        backgroundColor == AppColors.primary ? colors.primary : backgroundColor;
    final effectiveTextColor =
        textColor == AppColors.textOnPrimary
            ? colors.textOnPrimary
            : textColor;
    final bool effectiveDisabled = isDisabled || isLoading;
    final VoidCallback? effectiveOnPressed = effectiveDisabled ? null : onPressed;

    return Material(
      color:
          effectiveDisabled
              ? effectiveBackgroundColor.withValues(alpha: 0.5)
              : effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      elevation: effectiveDisabled ? 0 : 2,
      child: InkWell(
        onTap: effectiveOnPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: double.infinity,
          height: height,
          padding: padding,
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
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
