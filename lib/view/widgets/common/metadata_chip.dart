import 'package:flutter/material.dart';

import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_theme_colors.dart';

class MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const MetadataChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.maxWidth,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = foregroundColor ?? colors.textMedium;
    final fill = backgroundColor ?? colors.surface;

    return Container(
      constraints: maxWidth == null
          ? null
          : BoxConstraints(maxWidth: maxWidth!),
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.16)),
        boxShadow: colors.subtleShadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'Roboto',
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
