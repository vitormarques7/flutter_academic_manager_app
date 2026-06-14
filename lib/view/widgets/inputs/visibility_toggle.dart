import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';

class VisibilityToggle extends StatelessWidget {
  final bool isObscureText;
  final VoidCallback onTap;

  const VisibilityToggle({
    super.key,
    required this.isObscureText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return IconButton(
      icon: Icon(
        isObscureText
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: colors.textOnPrimary.withValues(alpha: 0.7),
      ),
      onPressed: onTap,
    );
  }
}
