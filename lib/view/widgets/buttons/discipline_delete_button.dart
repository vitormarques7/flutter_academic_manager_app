import 'package:flutter/material.dart';

class DisciplineDeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DisciplineDeleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Excluir disciplina',
      icon: Image.asset(
        'lib/view/assets/image_discipline_trash.png',
        width: 25,
        height: 25,
        fit: BoxFit.contain,
      ),
    );
  }
}
