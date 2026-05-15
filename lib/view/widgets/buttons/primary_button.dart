import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

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
    this.borderRadius = 35,
    this.height = 65,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.textStyle,
    this.leading,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading;
    final VoidCallback? effectiveOnPressed = effectiveDisabled
        ? null
        : onPressed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectiveOnPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          height: height,
          padding: padding,
          decoration: ShapeDecoration(
            color: effectiveDisabled
                ? backgroundColor.withOpacity(0.5)
                : backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            shadows: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 4),
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
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Text(
                      label,
                      style:
                          textStyle ??
                          AppTextStyles.button.copyWith(color: textColor),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
