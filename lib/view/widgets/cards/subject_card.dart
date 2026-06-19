import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_extension.dart';

class SubjectCard extends StatelessWidget {
  final String name;
  final String teacher;
  final double frequency;
  final double average;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.name,
    required this.teacher,
    required this.frequency,
    required this.average,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: appTheme.card,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: appTheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: appTheme.textPrimary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 1.38,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        teacher,
                        style: TextStyle(
                          color: appTheme.textPrimary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.57,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Frequência',
                    style: TextStyle(
                      color: appTheme.textPrimary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      value: frequency,
                      minHeight: 10,
                      backgroundColor: const Color(0x7F514EB6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF514EB6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Média atual',
                  style: TextStyle(
                    color: appTheme.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.57,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  average.toStringAsFixed(1),
                  style: TextStyle(
                    color: appTheme.textPrimary,
                    fontSize: 48,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 0.9,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
