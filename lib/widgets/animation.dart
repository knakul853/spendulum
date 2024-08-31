import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart' as anim_bg;

class CustomAnimatedBackground extends StatefulWidget {
  final Widget child;

  const CustomAnimatedBackground({Key? key, required this.child})
      : super(key: key);

  @override
  _CustomAnimatedBackgroundState createState() =>
      _CustomAnimatedBackgroundState();
}

class _CustomAnimatedBackgroundState extends State<CustomAnimatedBackground>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return anim_bg.AnimatedBackground(
      behaviour: anim_bg.BubblesBehaviour(),
      vsync: this,
      child: widget.child,
    );
  }
}

class GradientAnimatedBackground extends StatefulWidget {
  final Widget child;

  const GradientAnimatedBackground({Key? key, required this.child})
      : super(key: key);

  @override
  _GradientAnimatedBackgroundState createState() =>
      _GradientAnimatedBackgroundState();
}

class _GradientAnimatedBackgroundState extends State<GradientAnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                    Colors.blue[100], Colors.purple[100], _animation.value)!,
                Color.lerp(
                    Colors.purple[100], Colors.blue[100], _animation.value)!,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}