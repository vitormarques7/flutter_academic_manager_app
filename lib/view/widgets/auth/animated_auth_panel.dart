import 'package:flutter/material.dart';

class AnimatedAuthPanel extends StatelessWidget {
  final Widget child;

  const AnimatedAuthPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutQuart,
        builder: (context, value, animatedChild) {
          final slideDistance = 500 * (1 - value);
          final scale = 0.96 + (0.04 * value);

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
