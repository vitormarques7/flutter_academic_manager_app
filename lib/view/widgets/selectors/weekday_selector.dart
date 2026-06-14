import 'package:flutter/material.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/theme/app_theme_colors.dart';

class WeekdaySelector extends StatelessWidget {
  final Set<int> selectedIndexes;
  final ValueChanged<int> onChanged;

  const WeekdaySelector({
    super.key,
    required this.selectedIndexes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final options = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sab'];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(options.length, (index) {
        final isSelected = selectedIndexes.contains(index);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 44,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.outlineStrong,
                ),
              ),
              child: Text(
                options[index],
                style: AppTextStyles.bodyRegular.copyWith(
                  color: isSelected ? colors.textOnPrimary : colors.textDark,
                  fontSize: 12,
                  height: 1,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
