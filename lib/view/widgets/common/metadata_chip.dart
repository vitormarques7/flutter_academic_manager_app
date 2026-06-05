import 'package:flutter/material.dart';

class MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;

  const MetadataChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: maxWidth == null
          ? null
          : BoxConstraints(maxWidth: maxWidth!),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF464552), size: iconSize),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF464552),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
