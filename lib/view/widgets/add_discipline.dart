import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class AddDisciplineButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AddDisciplineButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(35),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Adicionar Disciplina',
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
