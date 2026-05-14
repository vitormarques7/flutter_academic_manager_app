import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double scale;
  final Color color;

  const AppLogo({
    super.key,
    this.scale = 1.0,
    this.color = const Color(0xFF514EB6),
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
        children: [
          // Quadrado superior esquerdo
          Positioned(
            left: 0,
            top: 0,
            child: _Block(
              width: 129 * scale,
              height: 120 * scale,
              radius: 30 * scale,
              color: color,
            ),
          ),

          // Bolinha do quadrado esquerdo
          Positioned(
            left: 22 * scale,
            top: 87 * scale,
            child: _Dot(size: 20 * scale),
          ),

          // Quadrado inferior direito
          Positioned(
            left: 99 * scale,
            top: 70 * scale,
            child: _Block(
              width: 129 * scale,
              height: 120 * scale,
              radius: 30 * scale,
              color: color,
            ),
          ),

          // Bolinha do quadrado direito
          Positioned(
            left: 188 * scale,
            top: 97 * scale,
            child: _Dot(size: 20 * scale),
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
            color: color.withOpacity(0.3),
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
      decoration: const ShapeDecoration(
        color: Color(0xFFF5F5F5),
        shape: OvalBorder(),
        shadows: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
