import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class SeriesSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SeriesSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = ['1º Ano', '2º Ano', '3º Ano', '4º Ano'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(options.length, (index) {
        final isSelected = index == selectedIndex;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                // O PROJECT_CONTEXT cita AppColors.chipSelected e chipUnselected.
                // Se não existirem, utilize as cores diretas do Figma: 0xFF514EB6 e 0xFFEFF4FF
                color: isSelected ? AppColors.primary : const Color(0xFFEFF4FF),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFC7C4D8),
                ),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                options[index],
                style: AppTextStyles.bodyRegular.copyWith(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
