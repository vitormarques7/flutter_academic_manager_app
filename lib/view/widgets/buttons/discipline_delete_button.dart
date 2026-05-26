import 'package:flutter/material.dart';

class DisciplineDeleteButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double buttonSize;
  final double opacity;

  const DisciplineDeleteButton({
    super.key,
    required this.onPressed,
    this.color,
    this.buttonSize = 48,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'lib/view/assets/image_discipline_trash.png',
      width: 25,
      height: 25,
      fit: BoxFit.contain,
    );

    final icon = color == null
        ? image
        : ColorFiltered(
            colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
            child: image,
          );

    return IconButton(
      onPressed: onPressed,
      tooltip: 'Excluir disciplina',
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: buttonSize,
        height: buttonSize,
      ),
      icon: Opacity(opacity: opacity, child: icon),
    );
  }
}
