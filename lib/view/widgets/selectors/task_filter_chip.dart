// Chip de filtro com label e ícone de dropdown, usado na tela de tarefas.
import 'package:flutter/material.dart';

class TaskFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const TaskFilterChip({super.key, this.label = 'Todas', this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF191820),
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                height: 1.47,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF191820),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
