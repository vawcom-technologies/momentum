import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class DailySpinWheel extends StatefulWidget {
  final Function(SpinReward) onRewardClaimed;
  final bool canSpin;

  const DailySpinWheel({
    super.key,
    required this.onRewardClaimed,
    required this.canSpin,
  });

  @override
  State<DailySpinWheel> createState() => _DailySpinWheelState();
}

class _DailySpinWheelState extends State<DailySpinWheel> {
  final StreamController<int> _controller = StreamController<int>();
  bool _isSpinning = false;
  SpinReward? _currentReward;

  final List<SpinReward> rewards = [
    SpinReward(name: '10 XP', xp: 10, icon: '⭐', color: const Color(0xFF3B82F6)),
    SpinReward(name: '25 XP', xp: 25, icon: '✨', color: const Color(0xFF8B5CF6)),
    SpinReward(name: '50 XP', xp: 50, icon: '💫', color: const Color(0xFFF59E0B)),
    SpinReward(name: '2x XP', xp: 0, icon: '🔥', color: const Color(0xFFEF4444), isMultiplier: true, multiplier: 2),
    SpinReward(name: '100 XP', xp: 100, icon: '🌟', color: const Color(0xFF22C55E)),
    SpinReward(name: 'Power Up', xp: 0, icon: '⚡', color: const Color(0xFF6366F1), isPowerUp: true),
    SpinReward(name: '15 XP', xp: 15, icon: '💎', color: const Color(0xFF14B8A6)),
    SpinReward(name: 'JACKPOT', xp: 500, icon: '👑', color: const Color(0xFFF59E0B)),
  ];

  void _spin() {
    if (!widget.canSpin || _isSpinning) return;

    setState(() {
      _isSpinning = true;
      _currentReward = null;
    });

    HapticFeedback.mediumImpact();

    // Weight the results (jackpot is rare)
    final random = Random();
    int selectedIndex;
    final chance = random.nextDouble();
    if (chance < 0.02) {
      selectedIndex = 7; // 2% chance for jackpot
    } else if (chance < 0.10) {
      selectedIndex = 4; // 8% chance for 100 XP
    } else if (chance < 0.20) {
      selectedIndex = 2; // 10% chance for 50 XP
    } else if (chance < 0.35) {
      selectedIndex = 3; // 15% chance for 2x multiplier
    } else if (chance < 0.50) {
      selectedIndex = 5; // 15% chance for power up
    } else {
      selectedIndex = random.nextInt(3); // Rest split between 10, 25, 15 XP
      if (selectedIndex == 2) selectedIndex = 6;
    }

    _controller.add(selectedIndex);

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isSpinning = false;
        _currentReward = rewards[selectedIndex];
      });
      HapticFeedback.heavyImpact();
      widget.onRewardClaimed(rewards[selectedIndex]);
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎰',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Spin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2000.ms, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.canSpin
                ? 'Spin to win bonus rewards!'
                : 'Come back tomorrow for another spin!',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          // Wheel
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Fortune wheel
                FortuneWheel(
                  selected: _controller.stream,
                  animateFirst: false,
                  duration: const Duration(seconds: 5),
                  physics: CircularPanPhysics(
                    duration: const Duration(seconds: 1),
                    curve: Curves.decelerate,
                  ),
                  onFling: widget.canSpin && !_isSpinning ? _spin : null,
                  indicators: [
                    FortuneIndicator(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 40,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: TrianglePainter(),
                        ),
                      ),
                    ),
                  ],
                  items: rewards.map((reward) {
                    return FortuneItem(
                      style: FortuneItemStyle(
                        color: reward.color,
                        borderColor: Colors.white.withOpacity(0.3),
                        borderWidth: 2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(
                          children: [
                            Text(
                              reward.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reward.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Spin button
          GestureDetector(
            onTap: widget.canSpin && !_isSpinning ? _spin : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                gradient: widget.canSpin
                    ? const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      )
                    : LinearGradient(
                        colors: [Colors.grey[600]!, Colors.grey[700]!],
                      ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: widget.canSpin
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Text(
                _isSpinning
                    ? 'SPINNING...'
                    : widget.canSpin
                        ? 'SPIN!'
                        : 'SPIN TOMORROW',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          )
              .animate(
                target: widget.canSpin && !_isSpinning ? 1 : 0,
                onPlay: (c) => c.repeat(reverse: true),
              )
              .scaleXY(end: 1.05, duration: 800.ms),
          // Show reward
          if (_currentReward != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentReward!.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _currentReward!.color,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentReward!.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You won!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _currentReward!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn()
                .scale(begin: const Offset(0.5, 0.5))
                .shake(duration: 500.ms),
          ],
        ],
      ),
    );
  }
}

class SpinReward {
  final String name;
  final int xp;
  final String icon;
  final Color color;
  final bool isMultiplier;
  final int multiplier;
  final bool isPowerUp;

  SpinReward({
    required this.name,
    required this.xp,
    required this.icon,
    required this.color,
    this.isMultiplier = false,
    this.multiplier = 1,
    this.isPowerUp = false,
  });
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
