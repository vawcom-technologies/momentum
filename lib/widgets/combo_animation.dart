import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ComboAnimation extends StatelessWidget {
  final int combo;
  final VoidCallback? onComplete;

  const ComboAnimation({
    super.key,
    required this.combo,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    String comboText;
    Color comboColor;
    double fontSize;

    if (combo >= 10) {
      comboText = '🔥 ULTRA COMBO x$combo! 🔥';
      comboColor = const Color(0xFFEF4444);
      fontSize = 32;
    } else if (combo >= 5) {
      comboText = '⚡ SUPER COMBO x$combo! ⚡';
      comboColor = const Color(0xFFF59E0B);
      fontSize = 28;
    } else {
      comboText = '✨ COMBO x$combo ✨';
      comboColor = const Color(0xFF8B5CF6);
      fontSize = 24;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              comboColor.withOpacity(0.9),
              comboColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: comboColor.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Text(
          comboText,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .then()
          .shake(duration: 500.ms)
          .then()
          .fadeOut(delay: 1000.ms, duration: 500.ms),
    );
  }
}

class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    String emoji;
    Color color;

    if (streak >= 30) {
      emoji = '🌟';
      color = const Color(0xFFF59E0B);
    } else if (streak >= 14) {
      emoji = '💎';
      color = const Color(0xFF3B82F6);
    } else if (streak >= 7) {
      emoji = '🔥';
      color = const Color(0xFFEF4444);
    } else if (streak >= 3) {
      emoji = '✨';
      color = const Color(0xFF8B5CF6);
    } else {
      emoji = '⭐';
      color = const Color(0xFF22C55E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '$streak day streak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(end: 1.05, duration: 1500.ms);
  }
}

class XPGainPopup extends StatelessWidget {
  final int xp;
  final double multiplier;

  const XPGainPopup({
    super.key,
    required this.xp,
    this.multiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveXP = (xp * multiplier).round();
    
    return Text(
      '+$effectiveXP XP${multiplier > 1 ? ' (${multiplier}x)' : ''}',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF22C55E),
      ),
    )
        .animate()
        .slideY(begin: 0, end: -1, duration: 1500.ms)
        .fadeOut(delay: 1000.ms, duration: 500.ms);
  }
}
