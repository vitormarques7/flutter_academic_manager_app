import 'package:flutter/material.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/theme/app_theme_colors.dart';

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
    final colors = context.appColors;
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
                color: isSelected ? colors.primary : colors.chipUnselected,
                border: Border.all(
                  color: isSelected ? colors.primary : colors.outlineStrong,
                ),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                options[index],
                style: AppTextStyles.bodyRegular.copyWith(
                  color: isSelected ? colors.textOnPrimary : colors.textDark,
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
