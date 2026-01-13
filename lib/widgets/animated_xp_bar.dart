import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedXPBar extends StatefulWidget {
  final double progress;
  final int currentXP;
  final int maxXP;
  final int level;
  final VoidCallback? onLevelUp;

  const AnimatedXPBar({
    super.key,
    required this.progress,
    required this.currentXP,
    required this.maxXP,
    required this.level,
    this.onLevelUp,
  });

  @override
  State<AnimatedXPBar> createState() => _AnimatedXPBarState();
}

class _AnimatedXPBarState extends State<AnimatedXPBar>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  List<XPParticle> particles = [];
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;
    
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        setState(() {
          for (var particle in particles) {
            particle.update();
          }
          particles.removeWhere((p) => p.opacity <= 0);
        });
      });
  }

  @override
  void didUpdateWidget(AnimatedXPBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress > _previousProgress) {
      _spawnParticles();
      _pulseController.forward(from: 0);
    }
    if (widget.level > oldWidget.level) {
      widget.onLevelUp?.call();
    }
    _previousProgress = widget.progress;
  }

  void _spawnParticles() {
    final random = Random();
    for (int i = 0; i < 8; i++) {
      particles.add(XPParticle(
        x: widget.progress,
        y: 0.5,
        vx: (random.nextDouble() - 0.5) * 0.1,
        vy: -random.nextDouble() * 0.15 - 0.05,
        size: random.nextDouble() * 6 + 4,
        opacity: 1.0,
      ));
    }
    _particleController.forward(from: 0);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildLevelBadge(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Experience',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${widget.currentXP} / ${widget.maxXP} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildPercentage(),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLevelBadge() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.2);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPercentage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up,
            color: Color(0xFF22C55E),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${(widget.progress * 100).round()}%',
            style: const TextStyle(
              color: Color(0xFF22C55E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Progress
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: const [
                          Color(0xFF8B5CF6),
                          Color(0xFF6366F1),
                          Color(0xFF3B82F6),
                        ],
                        stops: [
                          0.0,
                          0.5 + _shimmerController.value * 0.5,
                          1.0,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Particles
          ...particles.map((p) => Positioned(
                left: p.x * MediaQuery.of(context).size.width * 0.85,
                top: 12 + (p.y * 20),
                child: Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(p.opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(p.opacity),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              )),
          // Glow effect at the end
          Positioned(
            left: widget.progress.clamp(0.0, 1.0) * 
                  (MediaQuery.of(context).size.width - 80) - 10,
            top: 0,
            bottom: 0,
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class XPParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  XPParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.01; // gravity
    opacity -= 0.03;
    size *= 0.95;
  }
}
