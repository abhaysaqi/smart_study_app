// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:simple_animations/simple_animations.dart';

// class AnimatedStarBackground extends StatelessWidget {
//   final Widget child;
  
//   const AnimatedStarBackground({
//     Key? key,
//     required this.child,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Theme.of(context).colorScheme.surface,
//                   Theme.of(context).colorScheme.surface.withOpacity(0.8),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Positioned.fill(
//           child: StarField(
//             starCount: 100,
//           ),
//         ),
//         Positioned.fill(
//           child: child,
//         ),
//       ],
//     );
//   }
// }

// class StarField extends StatefulWidget {
//   final int starCount;
  
//   const StarField({
//     Key? key,
//     required this.starCount,
//   }) : super(key: key);

//   @override
//   _StarFieldState createState() => _StarFieldState();
// }

// class _StarFieldState extends State<StarField> {
//   late List<Star> stars;

//   @override
//   void initState() {
//     super.initState();
//     stars = List.generate(
//       widget.starCount,
//       (index) => Star(
//         position: Offset(
//           math.Random().nextDouble() * 400, 
//           math.Random().nextDouble() * 800,
//         ),
//         size: math.Random().nextDouble() * 4 + 1,
//         velocity: Offset(
//           (math.Random().nextDouble() - 0.5) * 2,
//           (math.Random().nextDouble() - 0.5) * 2,
//         ),
//         color: _getRandomStarColor(),
//       ),
//     );
//   }

//   Color _getRandomStarColor() {
//     final colors = [
//       Colors.white,
//       Colors.blue[200]!,
//       Colors.yellow[100]!,
//       Colors.purple[100]!,
//     ];
//     return colors[math.Random().nextInt(colors.length)];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomAnimationBuilder<double>(
//       duration: const Duration(seconds: 100),
//       tween: Tween<double>(begin: 0.0, end: 1000.0),
//       builder: (context, value, child) {
//         return CustomPaint(
//           painter: StarPainter(
//             stars: stars,
//             animationValue: value,
//           ),
//           size: Size.infinite,
//         );
//       },
//     );
//   }
// }

// class Star {
//   Offset position;
//   final double size;
//   final Offset velocity;
//   final Color color;
  
//   Star({
//     required this.position,
//     required this.size,
//     required this.velocity,
//     required this.color,
//   });

//   void update(double delta) {
//     position += velocity * delta;
//   }
// }

// class StarPainter extends CustomPainter {
//   final List<Star> stars;
//   final double animationValue;
  
//   StarPainter({
//     required this.stars,
//     required this.animationValue,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Update star positions based on animation value
//     for (var star in stars) {
//       star.update(0.1);
      
//       // Wrap stars around the screen
//       if (star.position.dx < 0) star.position = Offset(size.width, star.position.dy);
//       if (star.position.dx > size.width) star.position = Offset(0, star.position.dy);
//       if (star.position.dy < 0) star.position = Offset(star.position.dx, size.height);
//       if (star.position.dy > size.height) star.position = Offset(star.position.dx, 0);
      
//       // Create a shimmering effect
//       final shimmer = (math.sin(animationValue * 0.01 + star.position.dx * 0.01) + 1) / 2;
      
//       // Draw the star
//       final paint = Paint()
//         ..color = star.color.withOpacity(0.4 + shimmer * 0.6)
//         ..style = PaintingStyle.fill;
      
//       // Draw the core of the star
//       canvas.drawCircle(star.position, star.size, paint);
      
//       // Draw the glow around the star
//       final glowPaint = Paint()
//         ..color = star.color.withOpacity(0.1 + shimmer * 0.1)
//         ..style = PaintingStyle.fill
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
//       canvas.drawCircle(star.position, star.size * 2, glowPaint);
      
//       // Draw star rays for larger stars
//       if (star.size > 2.5) {
//         _drawStarRays(canvas, star, shimmer);
//       }
//     }
//   }
  
//   void _drawStarRays(Canvas canvas, Star star, double shimmer) {
//     final rayPaint = Paint()
//       ..color = star.color.withOpacity(0.1 + shimmer * 0.2)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.0;
    
//     final rayLength = star.size * (2 + shimmer * 3);
    
//     for (int i = 0; i < 4; i++) {
//       final angle = i * (math.pi / 2);
//       final startPoint = star.position;
//       final endPoint = Offset(
//         star.position.dx + math.cos(angle) * rayLength,
//         star.position.dy + math.sin(angle) * rayLength,
//       );
      
//       canvas.drawLine(startPoint, endPoint, rayPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // Shooting star animation
// class ShootingStar extends StatelessWidget {
//   const ShootingStar({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return CustomAnimationBuilder<double>(
//       tween: Tween<double>(begin: 0, end: 1),
//       duration: const Duration(seconds: 2),
//       curve: Curves.easeInOut,
//       builder: (context, value, child) {
//         return CustomPaint(
//           painter: ShootingStarPainter(progress: value),
//           size: Size.infinite,
//         );
//       },
//     );
//   }
// }

// class ShootingStarPainter extends CustomPainter {
//   final double progress;
  
//   ShootingStarPainter({required this.progress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final start = Offset(0, size.height * 0.3);
//     final end = Offset(size.width, size.height * 0.7);
    
//     final currentPoint = Offset(
//       start.dx + (end.dx - start.dx) * progress,
//       start.dy + (end.dy - start.dy) * progress,
//     );
    
//     final paint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
    
//     final trailPaint = Paint()
//       ..shader = LinearGradient(
//         colors: [
//           Colors.white.withOpacity(0),
//           Colors.white.withOpacity(0.8),
//         ],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ).createShader(Rect.fromPoints(
//         Offset(currentPoint.dx - 20, currentPoint.dy),
//         currentPoint,
//       ))
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;
    
//     // Draw the trail
//     final pathPoints = <Offset>[];
//     for (var i = 0; i < 20; i++) {
//       final trailProgress = progress - (i * 0.01);
//       if (trailProgress < 0) break;
      
//       pathPoints.add(Offset(
//         start.dx + (end.dx - start.dx) * trailProgress,
//         start.dy + (end.dy - start.dy) * trailProgress,
//       ));
//     }
    
//     if (pathPoints.length > 1) {
//       final path = Path();
//       path.moveTo(pathPoints.first.dx, pathPoints.first.dy);
      
//       for (var i = 1; i < pathPoints.length; i++) {
//         path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
//       }
      
//       canvas.drawPath(path, trailPaint);
//     }
    
//     // Draw the star point
//     canvas.drawCircle(currentPoint, 2, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }




import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_animate/flutter_animate.dart';


class AnimatedStarBackground extends StatefulWidget {
  final bool isDarkMode;
  final Widget child;

  const AnimatedStarBackground({
    super.key,
    required this.isDarkMode,
    required this.child,
  });

  @override
  State<AnimatedStarBackground> createState() => _AnimatedStarBackgroundState();
}

class _AnimatedStarBackgroundState extends State<AnimatedStarBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final int _starCount = 100;
  late double _lightningOpacity = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
        _updateLightning();
        setState(() {});
      })
      ..repeat();

    _generateStars();
  }

  void _generateStars() {
    _stars.clear();
    final math.Random random = math.Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(
        Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 2 + 1,
          opacity: random.nextDouble() * 0.5 + 0.5,
          twinkleSpeed: random.nextDouble() * 0.02 + 0.005,
        ),
      );
    }
  }

  void _updateLightning() {
    final value = _controller.value;
    if ((value * 1000).toInt() % 80 == 0 && math.Random().nextDouble() > 0.9) {
      _lightningOpacity = 1.0;
    } else {
      _lightningOpacity *= 0.9;
    }
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
        // Background Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isDarkMode
                    ? [const Color(0xFF0B0C1A), const Color(0xFF1A1B2F)]
                    : [const Color(0xFFEFEFF5), const Color(0xFFCDD4F0)],
              ),
            ),
          ),
        ),

        // Stars
        Positioned.fill(
          child: CustomPaint(
            painter: StarPainter(
              stars: _stars,
              animation: _controller.value,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        ),

        // Lightning flash overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.white.withOpacity(_lightningOpacity * (widget.isDarkMode ? 0.4 : 0.2)),
            ),
          ),
        ),

        widget.child,
      ],
    ).animate().fadeIn(duration: 1.seconds, curve: Curves.easeIn);
  }
}

class Star {
  double x;
  double y;
  double size;
  double opacity;
  double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
  });

  void twinkle(double animation) {
    opacity = 0.5 + 0.5 * math.sin(animation * 2 * math.pi * twinkleSpeed + x * 10);
  }
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;
  final bool isDarkMode;

  StarPainter({
    required this.stars,
    required this.animation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      star.twinkle(animation);
      paint.color = isDarkMode
          ? Colors.white.withOpacity(star.opacity)
          : Colors.blueGrey.withOpacity(star.opacity * 0.7);

      final position = Offset(
        star.x * size.width,
        star.y * size.height,
      );

      canvas.drawCircle(position, star.size, paint);
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) {
    return true;
  }
}