import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

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
                color: isSelected ? const Color(0xFF7B79BF) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF7B79BF)
                      : AppColors.textMuted,
                ),
              ),
              child: Text(
                options[index],
                style: AppTextStyles.bodyRegular.copyWith(
                  color: Colors.black,
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
