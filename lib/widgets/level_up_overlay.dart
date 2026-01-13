import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final String title;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.title,
    required this.onDismiss,
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _confettiController.play();
    _scaleController.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarburstPainter(
                    rotation: _rotateController.value * 2 * pi,
                    color: const Color(0xFF8B5CF6),
                  ),
                );
              },
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Confetti
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFF8B5CF6),
                    Color(0xFF6366F1),
                    Color(0xFF3B82F6),
                    Color(0xFF22C55E),
                    Color(0xFFF59E0B),
                    Color(0xFFEF4444),
                  ],
                ),
                // Level up text
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _scaleController,
                    curve: Curves.elasticOut,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '⚡ LEVEL UP! ⚡',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(
                            duration: 1500.ms,
                            color: const Color(0xFFF59E0B),
                          ),
                      const SizedBox(height: 24),
                      _buildLevelBadge(),
                      const SizedBox(height: 16),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[200],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You are becoming unstoppable!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Continue button
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms)
                    .slideY(begin: 0.5, end: 0)
                    .then()
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.05, duration: 1000.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${widget.newLevel}',
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(end: 1.1, duration: 800.ms)
        .then()
        .rotate(duration: 2000.ms, begin: -0.02, end: 0.02);
  }
}

class StarburstPainter extends CustomPainter {
  final double rotation;
  final Color color;

  StarburstPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi + rotation;
      final opacity = 0.1 + (i % 3) * 0.1;
      paint.color = color.withOpacity(opacity);

      final startRadius = 50.0;
      final endRadius = size.width * 0.7;

      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * startRadius,
          center.dy + sin(angle) * startRadius,
        ),
        Offset(
          center.dx + cos(angle) * endRadius,
          center.dy + sin(angle) * endRadius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
