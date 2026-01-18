import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;
        if (gameState == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final achievements = _getAchievements(gameState.level);
        final unlockedCount = achievements.where((a) => a['unlocked'] == true).length;
        final totalCount = achievements.length;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock badges by completing challenges',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Overview
                _buildProgressCard(unlockedCount, totalCount),
                const SizedBox(height: 24),

                // Achievements List
                ...achievements.map((achievement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAchievementCard(context, achievement),
                    )),

                const SizedBox(height: 16),

                // Rarity Legend
                _buildRarityLegend(),

                const SizedBox(height: 80), // Bottom padding
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getAchievements(int currentLevel) {
    return [
      {
        'id': '1',
        'title': 'Monk Mode',
        'description': 'Complete all daily quests for 7 days straight',
        'icon': Icons.local_fire_department,
        'unlocked': true,
        'rarity': 'epic',
      },
      {
        'id': '2',
        'title': 'Early Bird',
        'description': 'Complete your first task before 8 AM',
        'icon': Icons.star,
        'unlocked': true,
        'rarity': 'common',
      },
      {
        'id': '3',
        'title': 'No Excuses',
        'description': 'Complete 100 quests',
        'icon': Icons.my_location,
        'unlocked': true,
        'progress': 100,
        'total': 100,
        'rarity': 'rare',
      },
      {
        'id': '4',
        'title': 'Villain Arc',
        'description': 'Reach level 20',
        'icon': Icons.workspace_premium,
        'unlocked': false,
        'progress': currentLevel,
        'total': 20,
        'rarity': 'legendary',
      },
      {
        'id': '5',
        'title': 'Focus Master',
        'description': 'Complete 50 deep work sessions',
        'icon': Icons.bolt,
        'unlocked': false,
        'progress': 32,
        'total': 50,
        'rarity': 'rare',
      },
      {
        'id': '6',
        'title': 'Health Enthusiast',
        'description': 'Hit your step goal 30 days in a row',
        'icon': Icons.emoji_events,
        'unlocked': false,
        'progress': 18,
        'total': 30,
        'rarity': 'epic',
      },
      {
        'id': '7',
        'title': 'Discipline God',
        'description': 'Reach 100 Discipline stat',
        'icon': Icons.military_tech,
        'unlocked': false,
        'progress': 72,
        'total': 100,
        'rarity': 'legendary',
      },
    ];
  }

  Widget _buildProgressCard(int unlocked, int total) {
    final progress = unlocked / total;
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.2),
            const Color(0xFF3B82F6).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Collection Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$unlocked/$total',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% Complete',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] == true;
    final rarity = achievement['rarity'] as String;
    final hasProgress = achievement['progress'] != null && !isUnlocked;

    Color getRarityGradientStart() {
      switch (rarity) {
        case 'common':
          return Colors.grey[500]!;
        case 'rare':
          return const Color(0xFF3B82F6);
        case 'epic':
          return const Color(0xFF8B5CF6);
        case 'legendary':
          return const Color(0xFFEAB308);
        default:
          return Colors.grey[500]!;
      }
    }

    Color getRarityGradientEnd() {
      switch (rarity) {
        case 'common':
          return Colors.grey[600]!;
        case 'rare':
          return const Color(0xFF2563EB);
        case 'epic':
          return const Color(0xFF7C3AED);
        case 'legendary':
          return const Color(0xFFF97316);
        default:
          return Colors.grey[600]!;
      }
    }

    Color getBorderColor() {
      if (!isUnlocked) return Colors.grey[200]!;
      switch (rarity) {
        case 'common':
          return Colors.grey[400]!;
        case 'rare':
          return const Color(0xFF3B82F6).withOpacity(0.5);
        case 'epic':
          return const Color(0xFF8B5CF6).withOpacity(0.5);
        case 'legendary':
          return const Color(0xFFEAB308).withOpacity(0.5);
        default:
          return Colors.grey[200]!;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor(), width: 2),
      ),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.6,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [getRarityGradientStart(), getRarityGradientEnd()],
                      )
                    : null,
                color: isUnlocked ? null : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUnlocked ? achievement['icon'] : Icons.lock,
                size: 24,
                color: isUnlocked ? Colors.white : Colors.grey[400],
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey[500],
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [getRarityGradientStart(), getRarityGradientEnd()],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            rarity[0].toUpperCase() + rarity.substring(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement['description'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),

                  // Progress bar for locked achievements
                  if (hasProgress) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${achievement['progress']}/${achievement['total']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: achievement['progress'] / achievement['total'],
                        minHeight: 8,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[800] 
                            : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          LinearGradient(
                            colors: [getRarityGradientStart(), getRarityGradientEnd()],
                          ).colors.first,
                        ),
                      ),
                    ),
                  ],

                  // Share button for unlocked achievements
                  if (isUnlocked) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Share Achievement →',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRarityLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rarity Levels',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[500]!, Colors.grey[600]!],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Common', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Rare', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Epic', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEAB308), Color(0xFFF97316)],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Legendary', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
