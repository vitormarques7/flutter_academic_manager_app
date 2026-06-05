import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class SummaryMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const SummaryMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF191820),
              fontSize: 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF464552),
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
