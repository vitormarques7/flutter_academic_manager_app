import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF464552),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
