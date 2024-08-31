import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedCardShape extends StatefulWidget {
  @override
  _AnimatedCardShapeState createState() => _AnimatedCardShapeState();
}

class _AnimatedCardShapeState extends State<AnimatedCardShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: ShapePainter(_controller.value),
        );
      },
    );
  }
}

class ShapePainter extends CustomPainter {
  final double animationValue;

  ShapePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * (0.5 + 0.1 * math.sin(animationValue * 2 * math.pi)),
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * (0.5 - 0.1 * math.sin(animationValue * 2 * math.pi)),
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
