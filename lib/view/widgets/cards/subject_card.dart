// Card de disciplina com nome, professor, barra de frequência e média atual.
import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String name;
  final String teacher;
  final double frequency;
  final double average;

  const SubjectCard({
    super.key,
    required this.name,
    required this.teacher,
    required this.frequency,
    required this.average,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Coluna esquerda: nome, professor, frequência
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF191820),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.38,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      teacher,
                      style: const TextStyle(
                        color: Color(0xFF191820),
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
                const Text(
                  'Frequência',
                  style: TextStyle(
                    color: Color(0xFF191820),
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

          // Coluna direita: média atual
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Média atual',
                style: TextStyle(
                  color: Color(0xFF191820),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.57,
                  letterSpacing: -1,
                ),
              ),
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFF191820),
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
    );
  }
}
