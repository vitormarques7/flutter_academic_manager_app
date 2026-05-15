import 'package:flutter/material.dart';
import '../../../config/theme/app_text_styles.dart';

class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.sectionLabel);
  }
}
