import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

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
    return IconButton(
      icon: Icon(
        isObscureText
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: AppColors.primary,
      ),
      onPressed: onTap,
    );
  }
}
