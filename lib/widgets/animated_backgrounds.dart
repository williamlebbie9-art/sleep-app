import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated Night Sky Background with twinkling stars
class NightSkyBackground extends StatefulWidget {
  const NightSkyBackground({super.key, this.child});

  final Widget? child;

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            ),
          ),
        ),
        // Animated stars
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: StarsPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        // Content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class StarsPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars = [];

  StarsPainter(this.animationValue) {
    // Generate random stars
    for (int i = 0; i < 80; i++) {
      stars.add(
        Star(
          x: math.Random(i).nextDouble(),
          y: math.Random(i * 2).nextDouble(),
          size: math.Random(i * 3).nextDouble() * 2 + 1,
          twinkleSpeed: math.Random(i * 4).nextDouble() * 2 + 1,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var star in stars) {
      final opacity =
          (math.sin(animationValue * math.pi * 2 * star.twinkleSpeed) + 1) / 2;
      paint.color = Colors.white.withOpacity(opacity * 0.8);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Star {
  final double x, y, size, twinkleSpeed;
  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
  });
}

/// Animated Ocean Waves Background with moonlight
class OceanWavesBackground extends StatefulWidget {
  const OceanWavesBackground({super.key, this.child});

  final Widget? child;

  @override
  State<OceanWavesBackground> createState() => _OceanWavesBackgroundState();
}

class _OceanWavesBackgroundState extends State<OceanWavesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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
        // Ocean gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A2E), Color(0xFF0F3460), Color(0xFF16213E)],
            ),
          ),
        ),
        // Moon glow
        Positioned(
          top: 100,
          right: 60,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Waves
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WavesPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class WavesPainter extends CustomPainter {
  final double animationValue;

  WavesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw multiple wave layers
    _drawWave(
      canvas,
      size,
      paint,
      animationValue,
      0.6,
      const Color(0xFF1E3A5F),
      0.3,
    );
    _drawWave(
      canvas,
      size,
      paint,
      animationValue * 0.8,
      0.7,
      const Color(0xFF2E4A6F),
      0.5,
    );
    _drawWave(
      canvas,
      size,
      paint,
      animationValue * 0.6,
      0.8,
      const Color(0xFF3E5A7F),
      0.7,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double time,
    double heightFactor,
    Color color,
    double opacity,
  ) {
    paint.color = color.withOpacity(opacity);
    final path = Path();
    final waveHeight = size.height * heightFactor;

    path.moveTo(0, waveHeight);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        waveHeight +
            math.sin((i / size.width * 4 * math.pi) + (time * math.pi * 2)) *
                20,
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

/// Animated Floating Clouds Background
class FloatingCloudsBackground extends StatefulWidget {
  const FloatingCloudsBackground({super.key, this.child});

  final Widget? child;

  @override
  State<FloatingCloudsBackground> createState() =>
      _FloatingCloudsBackgroundState();
}

class _FloatingCloudsBackgroundState extends State<FloatingCloudsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
        // Purple sky gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2D1B69), Color(0xFF5B3A9B), Color(0xFF7D4DB7)],
            ),
          ),
        ),
        // Floating clouds
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: CloudsPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        // Light rays
        Positioned.fill(child: CustomPaint(painter: LightRaysPainter())),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class CloudsPainter extends CustomPainter {
  final double animationValue;

  CloudsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // Draw multiple floating clouds
    _drawCloud(canvas, size, paint, animationValue, 0.2, 0.15, 150);
    _drawCloud(canvas, size, paint, animationValue * 0.7, 0.6, 0.35, 180);
    _drawCloud(canvas, size, paint, animationValue * 0.5, 0.15, 0.55, 120);
    _drawCloud(canvas, size, paint, animationValue * 0.9, 0.75, 0.25, 140);
    _drawCloud(canvas, size, paint, animationValue * 0.6, 0.4, 0.65, 160);
  }

  void _drawCloud(
    Canvas canvas,
    Size size,
    Paint paint,
    double time,
    double xPos,
    double yPos,
    double cloudSize,
  ) {
    final x = (xPos + (time * 0.1)) % 1.2 - 0.1;
    paint.color = Colors.white.withOpacity(0.1);

    canvas.drawCircle(
      Offset(x * size.width, yPos * size.height),
      cloudSize * 0.6,
      paint,
    );
    canvas.drawCircle(
      Offset(x * size.width + 40, yPos * size.height - 15),
      cloudSize * 0.5,
      paint,
    );
    canvas.drawCircle(
      Offset(x * size.width + 70, yPos * size.height),
      cloudSize * 0.7,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LightRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [Colors.white.withOpacity(0.05), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height / 2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final startX = size.width * (0.2 + i * 0.2);
      path.moveTo(startX, 0);
      path.lineTo(startX - 30, size.height * 0.4);
      path.lineTo(startX + 80, size.height * 0.4);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated Aurora Lights Background
class AuroraLightsBackground extends StatefulWidget {
  const AuroraLightsBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AuroraLightsBackground> createState() => _AuroraLightsBackgroundState();
}

class _AuroraLightsBackgroundState extends State<AuroraLightsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
        // Dark night sky
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF2C2E4A)],
            ),
          ),
        ),
        // Aurora lights
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: AuroraPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        // Mountain silhouette
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomPaint(
            painter: MountainPainter(),
            size: Size(MediaQuery.of(context).size.width, 200),
          ),
        ),
        // Stars
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: StarsPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class AuroraPainter extends CustomPainter {
  final double animationValue;

  AuroraPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Green aurora wave
    _drawAuroraWave(
      canvas,
      size,
      paint,
      animationValue,
      0.2,
      const Color(0xFF00FF87),
      0.15,
    );

    // Purple aurora wave
    _drawAuroraWave(
      canvas,
      size,
      paint,
      animationValue * 0.8,
      0.3,
      const Color(0xFF9D4EDD),
      0.18,
    );

    // Blue aurora wave
    _drawAuroraWave(
      canvas,
      size,
      paint,
      animationValue * 1.2,
      0.25,
      const Color(0xFF7B2CBF),
      0.12,
    );
  }

  void _drawAuroraWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double time,
    double baseHeight,
    Color color,
    double opacity,
  ) {
    paint.color = color.withOpacity(opacity);
    final path = Path();

    path.moveTo(0, size.height * baseHeight);

    for (double i = 0; i <= size.width; i += 5) {
      final y =
          size.height * baseHeight +
          math.sin((i / size.width * 3 * math.pi) + (time * math.pi * 2)) * 60 +
          math.sin((i / size.width * 5 * math.pi) - (time * math.pi)) * 40;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height * (baseHeight + 0.3));
    path.lineTo(0, size.height * (baseHeight + 0.3));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D0F1F)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.6);
    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
