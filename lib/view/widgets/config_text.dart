import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class ConfigTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const ConfigTextField({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textDark),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.defaultFieldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(
            color: AppColors.defaultFieldBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(
            color: AppColors.defaultFieldBorder,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
      ),
    );
  }
}
