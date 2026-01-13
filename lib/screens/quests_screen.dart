import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/quest.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;
        if (gameState == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final dailyQuests = gameState.dailyQuests
            .where((q) => q.type != QuestType.side)
            .toList();
        final sideQuests = gameState.dailyQuests
            .where((q) => q.type == QuestType.side)
            .toList();
        final completedDaily = dailyQuests
            .where((q) => q.status == QuestStatus.completed)
            .length;
        final totalDaily = dailyQuests.length;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Daily Quests',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete tasks to earn XP and level up',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Daily Progress Card
                _buildDailyProgressCard(completedDaily, totalDaily),
                const SizedBox(height: 32),

                // Daily Quests Section
                Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: Colors.grey[800]),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Quests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...dailyQuests.map((quest) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildQuestCard(context, quest, provider),
                    )),

                // Side Quests Section
                if (sideQuests.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 20, color: Colors.grey[800]),
                      const SizedBox(width: 8),
                      Text(
                        'Side Quests (Optional)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...sideQuests.map((quest) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQuestCard(context, quest, provider),
                      )),
                ],
                const SizedBox(height: 80), // Bottom padding for nav bar
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyProgressCard(int completed, int total) {
    final remaining = total - completed;

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
                'Daily Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$completed/$total',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              total > 0 ? total : 1,
              (i) => Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: i < completed
                        ? null
                        : Colors.grey[300],
                    gradient: i < completed
                        ? const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completed == total
                ? '🎉 All daily quests complete!'
                : '$remaining quest${remaining != 1 ? 's' : ''} remaining',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context, Quest quest, GameProvider provider) {
    final isCompleted = quest.status == QuestStatus.completed;

    Color borderColor;
    Color bgColor;
    if (isCompleted) {
      borderColor = Colors.purple;
      bgColor = Colors.purple.withOpacity(0.05);
    } else {
      switch (quest.type) {
        case QuestType.focus:
          borderColor = const Color(0xFF3B82F6);
          bgColor = const Color(0xFF3B82F6).withOpacity(0.1);
          break;
        case QuestType.health:
          borderColor = const Color(0xFF22C55E);
          bgColor = const Color(0xFF22C55E).withOpacity(0.1);
          break;
        case QuestType.discipline:
          borderColor = const Color(0xFFEF4444);
          bgColor = const Color(0xFFEF4444).withOpacity(0.1);
          break;
        case QuestType.side:
          borderColor = const Color(0xFF8B5CF6);
          bgColor = const Color(0xFF8B5CF6).withOpacity(0.1);
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          provider.completeQuest(quest.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.purple : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getQuestIcon(quest.type),
                size: 22,
                color: isCompleted ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          quest.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey[500] : Colors.black87,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.check_circle, size: 20, color: Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: quest.type == QuestType.side
                          ? const Color(0xFF8B5CF6).withOpacity(0.2)
                          : Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${quest.xpReward} XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: quest.type == QuestType.side
                            ? const Color(0xFF8B5CF6)
                            : Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getQuestIcon(QuestType type) {
    switch (type) {
      case QuestType.focus:
        return Icons.my_location;
      case QuestType.health:
        return Icons.fitness_center;
      case QuestType.discipline:
        return Icons.local_fire_department;
      case QuestType.side:
        return Icons.palette;
    }
  }
}
