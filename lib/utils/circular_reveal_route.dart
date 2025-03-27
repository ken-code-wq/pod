import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset? center;
  final Color color;

  CircularRevealRoute({
    required this.page,
    this.center,
    required this.color,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                // Background color that expands
                _CircularRevealAnimation(
                  animation: animation,
                  center: center,
                  color: color,
                ),
                // Fade in the actual child widget
                FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ],
            );
          },
        );
}

class _CircularRevealAnimation extends StatelessWidget {
  final Animation<double> animation;
  final Offset? center;
  final Color color;

  const _CircularRevealAnimation({
    required this.animation,
    this.center,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _CircularRevealPainter(
            progress: animation.value,
            center: center ?? Offset.zero,
            color: color,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _CircularRevealPainter extends CustomPainter {
  final double progress;
  final Offset center;
  final Color color;

  _CircularRevealPainter({
    required this.progress,
    required this.center,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the maximum radius needed to cover the entire screen
    final maxRadius = math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2));
    
    // Scale the radius based on the animation progress
    final radius = maxRadius * progress;
    
    // Create and draw the circle
    final paint = Paint()..color = color;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_CircularRevealPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
