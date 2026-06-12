import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double scale;
  final Color color;
  final double blockPulse;
  final double secondaryBlockPulse;
  final Offset blockOffset;
  final Offset secondaryBlockOffset;
  final List<double> dotPulses;

  const AppLogo({
    super.key,
    this.scale = 1.0,
    this.color = AppColors.primary,
    this.blockPulse = 1.0,
    this.secondaryBlockPulse = 1.0,
    this.blockOffset = Offset.zero,
    this.secondaryBlockOffset = Offset.zero,
    this.dotPulses = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Dimensões base (extraídas do Figma)
    // Quadrado 1: left=0, top=0, 129x120
    // Quadrado 2: left=99, top=70, 129x120
    // Total: width = 99+129 = 228, height = 70+120 = 190

    final double w = 228 * scale;
    final double h = 190 * scale;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Transform.translate(
              offset: blockOffset,
              child: Transform.scale(
                scale: blockPulse,
                child: _LogoBlockGroup(
                  scale: scale,
                  color: color,
                  dotPositions: const [
                    Offset(18, 88),
                    Offset(31, 90),
                    Offset(51, 73),
                  ],
                  dotSizes: const [10, 26, 18],
                  dotPulses: [_dotPulseAt(0), _dotPulseAt(1), _dotPulseAt(2)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 99 * scale,
            top: 70 * scale,
            child: Transform.translate(
              offset: secondaryBlockOffset,
              child: Transform.scale(
                scale: secondaryBlockPulse,
                child: _LogoBlockGroup(
                  scale: scale,
                  color: color,
                  dotPositions: const [
                    Offset(73, 33),
                    Offset(87, 38),
                    Offset(106, 19),
                  ],
                  dotSizes: const [10, 26, 18],
                  dotPulses: [_dotPulseAt(3), _dotPulseAt(4), _dotPulseAt(5)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _dotPulseAt(int index) {
    if (index >= dotPulses.length) return 1.0;
    return dotPulses[index];
  }
}

class _LogoBlockGroup extends StatelessWidget {
  final double scale;
  final Color color;
  final List<Offset> dotPositions;
  final List<double> dotSizes;
  final List<double> dotPulses;

  const _LogoBlockGroup({
    required this.scale,
    required this.color,
    required this.dotPositions,
    required this.dotSizes,
    required this.dotPulses,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 129 * scale,
      height: 120 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _Block(
            width: 129 * scale,
            height: 120 * scale,
            radius: 30 * scale,
            color: color,
          ),
          for (var index = 0; index < dotPositions.length; index++)
            Positioned(
              left: dotPositions[index].dx * scale,
              top: dotPositions[index].dy * scale,
              child: _PulsingDot(
                scale: dotPulses[index],
                size: dotSizes[index] * scale,
              ),
            ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _Block({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        shadows: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;

  const _Dot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: AppColors.background,
        shape: OvalBorder(),
        shadows: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final double scale;
  final double size;

  const _PulsingDot({required this.scale, required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: _Dot(size: size),
    );
  }
}
