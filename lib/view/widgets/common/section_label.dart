import 'package:flutter/material.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/theme/app_theme_colors.dart';

class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text(
      label,
      style: AppTextStyles.sectionLabel.copyWith(color: colors.textMedium),
    );
  }
}
