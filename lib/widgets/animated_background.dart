import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget? child;
  final Color color;

  const AnimatedBackground({Key? key, this.child, required this.color})
      : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
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
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return CustomPaint(
              painter: BackgroundPainter(_controller.value, widget.color),
              child: Container(),
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  BackgroundPainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < 5; i++) {
      double factor = i / 5;
      path.moveTo(0, size.height * (0.2 + 0.6 * factor));
      path.quadraticBezierTo(
        size.width * 0.25,
        size.height *
            (0.2 +
                0.6 * factor +
                0.1 *
                    math.sin(animationValue * 2 * math.pi + factor * math.pi)),
        size.width * 0.5,
        size.height * (0.2 + 0.6 * factor),
      );
      path.quadraticBezierTo(
        size.width * 0.75,
        size.height *
            (0.2 +
                0.6 * factor -
                0.1 *
                    math.sin(animationValue * 2 * math.pi + factor * math.pi)),
        size.width,
        size.height * (0.2 + 0.6 * factor),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
