import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/boss_battle.dart';

class BossBattleCard extends StatelessWidget {
  final BossBattle boss;
  final VoidCallback? onStart;
  final VoidCallback? onTap;

  const BossBattleCard({
    super.key,
    required this.boss,
    this.onStart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = boss.status == BossStatus.inProgress;
    final isAvailable = boss.status == BossStatus.available;
    
    Color primaryColor;
    switch (boss.difficulty) {
      case BossDifficulty.easy:
        primaryColor = const Color(0xFF22C55E);
        break;
      case BossDifficulty.medium:
        primaryColor = const Color(0xFFF59E0B);
        break;
      case BossDifficulty.hard:
        primaryColor = const Color(0xFFEF4444);
        break;
      case BossDifficulty.legendary:
        primaryColor = const Color(0xFF8B5CF6);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              primaryColor.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Boss icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      boss.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shake(duration: 2000.ms, hz: 1),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            boss.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildDifficultyBadge(primaryColor),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        boss.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            if (isActive) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    '${boss.completedQuests}/${boss.requiredQuests}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: boss.progress,
                  minHeight: 12,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${boss.remainingHours}h remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
            // Rewards
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRewardChip('⭐ ${boss.xpReward} XP', primaryColor),
                const SizedBox(width: 8),
                _buildRewardChip('📊 +${boss.bonusStatPoints} Stats', primaryColor),
              ],
            ),
            // Start button
            if (isAvailable) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '⚔️ START BATTLE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.02, duration: 1000.ms),
            ],
            // Challenges
            if (boss.challenges.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Challenges:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...boss.challenges.map((challenge) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: primaryColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          challenge,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDifficultyBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        boss.difficultyName.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRewardChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
