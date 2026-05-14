import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const OrDivider({
    super.key,
    this.text = 'ou',
    this.color = const Color(0xFF514EB6),
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: color)),
      ],
    );
  }
}
