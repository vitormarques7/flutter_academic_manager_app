import 'package:flutter/material.dart';

class AnimatedAuthPanel extends StatelessWidget {
  final Widget child;

  const AnimatedAuthPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, value, animatedChild) {
          final slideDistance = 72 * (1 - value);
          final scale = 0.985 + (0.015 * value);

          return Transform.translate(
            offset: Offset(0, slideDistance),
            child: Transform.scale(
              alignment: Alignment.bottomCenter,
              scale: scale,
              child: animatedChild,
            ),
          );
        },
        child: child,
      ),
    );
  }
}
