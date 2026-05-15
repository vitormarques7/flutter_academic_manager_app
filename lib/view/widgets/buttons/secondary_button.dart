import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Widget? leading;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;
  final double height;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.backgroundColor = AppColors.background,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.textDark,
    this.borderRadius = 35,
    this.height = 65,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          height: height,
          padding: padding,
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 2.5, color: borderColor),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            shadows: [
              BoxShadow(
                color: borderColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Text(
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
