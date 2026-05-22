// Botão flutuante de adição ("+") usado nas telas de disciplinas e tarefas.
import 'package:flutter/material.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const ShapeDecoration(
          color: Color(0xFFE4E4FF),
          shape: OvalBorder(),
          shadows: [
            BoxShadow(
              color: Color(0x7F514EB6),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Color(0xFF514EB6), size: 28),
      ),
    );
  }
}
