import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final Color particleColor;
  final int particleCount;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleColor = Colors.purple,
    this.particleCount = 30,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(() => setState(() => _updateParticles()));
  }

  void _initParticles() {
    final random = Random();
    particles = List.generate(
      widget.particleCount,
      (_) => Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 2,
        speedY: random.nextDouble() * 0.002 + 0.001,
        opacity: random.nextDouble() * 0.5 + 0.2,
        twinkleSpeed: random.nextDouble() * 0.02 + 0.01,
      ),
    );
  }

  void _updateParticles() {
    for (var particle in particles) {
      particle.y -= particle.speedY;
      particle.twinklePhase += particle.twinkleSpeed;
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = Random().nextDouble();
      }
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
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: ParticlePainter(
                particles: particles,
                color: widget.particleColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedY;
  double opacity;
  double twinkleSpeed;
  double twinklePhase;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.opacity,
    required this.twinkleSpeed,
    this.twinklePhase = 0,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;

  ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final twinkle = (sin(particle.twinklePhase) + 1) / 2;
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
