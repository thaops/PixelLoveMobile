import 'dart:math';
import 'package:flutter/material.dart';

class TarotParticles extends StatefulWidget {
  const TarotParticles({super.key});

  @override
  State<TarotParticles> createState() => _TarotParticlesState();
}

class _TarotParticlesState extends State<TarotParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = List.generate(20, (_) => Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double size = Random().nextDouble() * 3 + 1;
  double speed = Random().nextDouble() * 0.02 + 0.01;
  double opacity = Random().nextDouble() * 0.5 + 0.2;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var p in particles) {
      final currentY = (p.y - progress * p.speed) % 1.0;
      final position = Offset(p.x * size.width, currentY * size.height);

      paint.color = Colors.white.withOpacity(
        p.opacity * (1 - (currentY - 0.5).abs() * 2).clamp(0, 1),
      );
      canvas.drawCircle(position, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TarotBackgroundShimmer extends StatefulWidget {
  const TarotBackgroundShimmer({super.key});

  @override
  State<TarotBackgroundShimmer> createState() => _TarotBackgroundShimmerState();
}

class _TarotBackgroundShimmerState extends State<TarotBackgroundShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
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
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.3),
              radius: 1.5,
              colors: [
                Colors.purple.withOpacity(0.1 + 0.1 * _controller.value),
                Colors.indigo.withOpacity(0.05),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TarotBackgroundEffects extends StatelessWidget {
  const TarotBackgroundEffects({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        TarotBackgroundShimmer(),
        TarotParticles(),
      ],
    );
  }
}
