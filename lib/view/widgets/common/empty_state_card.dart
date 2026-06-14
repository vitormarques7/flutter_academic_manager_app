import 'package:flutter/material.dart';
import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_theme_colors.dart';
import 'app_surface.dart';

class EmptyStateCard extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppSurface.card(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: colors.primary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMedium,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
