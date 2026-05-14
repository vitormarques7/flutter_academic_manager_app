import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double height;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final Widget? leading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF514EB6),
    this.textColor = const Color(0xFFE7E7E7),
    this.borderRadius = 35,
    this.height = 65,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.textStyle,
    this.leading,
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
              Text(
                label,
                style:
                    textStyle ??
                    TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
