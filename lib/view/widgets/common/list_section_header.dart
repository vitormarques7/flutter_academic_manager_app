import 'package:flutter/material.dart';
import 'section_label.dart';

class ListSectionHeader extends StatelessWidget {
  final String label;
  final int count;

  const ListSectionHeader({
    super.key,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SectionLabel(label: label),
        const Spacer(),
        Text(
          '$count ${count == 1 ? 'item' : 'itens'}',
          style: const TextStyle(
            color: Color(0xFF464552),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
