import 'package:flutter/material.dart';
import '../../../config/theme/app_theme_colors.dart';
import 'section_label.dart';

class ListSectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Widget? trailing;

  const ListSectionHeader({
    super.key,
    required this.label,
    required this.count,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        SectionLabel(label: label),
        const Spacer(),
        Text(
          '$count ${count == 1 ? 'item' : 'itens'}',
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 13,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}
