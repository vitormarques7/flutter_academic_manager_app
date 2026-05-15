import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const OrDivider({
    super.key,
    this.text = 'ou',
    this.color = AppColors.divider,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: AppTextStyles.bodyBold.copyWith(
              color: color,
              fontSize: fontSize,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: color)),
      ],
    );
  }
}
