// Card de tarefa com checkbox, título, disciplina e prazo.
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String subject;
  final String deadline;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;

  const TaskCard({
    super.key,
    required this.title,
    required this.subject,
    required this.deadline,
    this.isChecked = false,
    this.onChanged,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          Container(
            width: 44,
            height: 44,
            decoration: ShapeDecoration(
              color: const Color(0xFFF8F9FF),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0x4C514EB6)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: const Color(0xFF514EB6),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Título e disciplina
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF191820),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.38,
                  ),
                ),
                Text(
                  'Disciplina: $subject',
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
          ),

          const SizedBox(width: 8),

          // Prazo com ícone de relógio
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFF191820), size: 18),
              const SizedBox(width: 4),
              Text(
                'Prazo: $deadline',
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
        ],
      ),
    );
  }
}
