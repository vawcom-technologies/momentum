import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/quest.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  final Map<String, bool> _completingQuests = {};

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

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Quests',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete tasks to earn XP',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0),
                const SizedBox(height: 24),

                // Multiplier banner
                if (gameState.effectiveXpMultiplier > 1)
                  _buildMultiplierBanner(gameState.effectiveXpMultiplier)
                      .animate()
                      .fadeIn(delay: 100.ms),
                if (gameState.effectiveXpMultiplier > 1)
                  const SizedBox(height: 16),

                // Daily Progress Card
                _buildDailyProgressCard(completedDaily, totalDaily, gameState)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),

                // Daily Quests Section
                _buildSectionHeader('⏰', 'Daily Quests', dailyQuests.length)
                    .animate()
                    .fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
                ...dailyQuests.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildQuestCard(
                        context,
                        entry.value,
                        provider,
                        delay: 400 + (entry.key * 100),
                      ),
                    )),

                // Side Quests Section
                if (sideQuests.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('🌟', 'Side Quests (Bonus)', sideQuests.length)
                      .animate()
                      .fadeIn(delay: 700.ms),
                  const SizedBox(height: 16),
                  ...sideQuests.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQuestCard(
                          context,
                          entry.value,
                          provider,
                          delay: 800 + (entry.key * 100),
                        ),
                      )),
                ],
                  const SizedBox(height: 100), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultiplierBanner(double multiplier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'XP BOOST ACTIVE!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'All XP rewards are multiplied by ${multiplier.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${multiplier.toStringAsFixed(1)}x',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2000.ms, color: const Color(0xFFF59E0B));
  }

  Widget _buildSectionHeader(String emoji, String title, int count) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            '$count quests',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyProgressCard(int completed, int total, gameState) {
    final remaining = total - completed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completed/$total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated progress segments
          Row(
            children: List.generate(
              total > 0 ? total : 1,
              (i) => Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (i * 100)),
                  height: 10,
                  margin: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    gradient: i < completed
                        ? const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          )
                        : null,
                    color: i < completed ? null : Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: i < completed
                        ? [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    completed == total
                        ? Icons.check_circle
                        : Icons.access_time,
                    size: 16,
                    color: completed == total
                        ? const Color(0xFF22C55E)
                        : Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    completed == total
                        ? '🎉 All quests complete!'
                        : '$remaining quest${remaining != 1 ? 's' : ''} remaining',
                    style: TextStyle(
                      fontSize: 13,
                      color: completed == total
                          ? const Color(0xFF22C55E)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
              if (gameState.isComboActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'Combo x${gameState.combo}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.05, duration: 800.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(
    BuildContext context,
    Quest quest,
    GameProvider provider, {
    int delay = 0,
  }) {
    final isCompleted = quest.status == QuestStatus.completed;
    final isCompleting = _completingQuests[quest.id] == true;

    Color primaryColor;
    String emoji;
    switch (quest.type) {
      case QuestType.focus:
        primaryColor = const Color(0xFF3B82F6);
        emoji = '🎯';
        break;
      case QuestType.health:
        primaryColor = const Color(0xFF22C55E);
        emoji = '💪';
        break;
      case QuestType.discipline:
        primaryColor = const Color(0xFFEF4444);
        emoji = '🔥';
        break;
      case QuestType.side:
        primaryColor = const Color(0xFF8B5CF6);
        emoji = '🌟';
        break;
    }

    if (isCompleted) {
      primaryColor = const Color(0xFF22C55E);
    }

    return GestureDetector(
      onTap: () async {
        if (!isCompleted && !isCompleting) {
          setState(() => _completingQuests[quest.id] = true);
          HapticFeedback.mediumImpact();

          await Future.delayed(const Duration(milliseconds: 300));
          provider.completeQuest(quest.id);

          setState(() => _completingQuests[quest.id] = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleting
                ? const Color(0xFFF59E0B)
                : isCompleted
                    ? const Color(0xFF22C55E).withOpacity(0.5)
                    : Colors.grey[200]!,
            width: isCompleting ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            if (isCompleting)
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 15,
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                      )
                    : null,
                color: isCompleted ? null : primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).iconTheme.color,
                        size: 28,
                      )
                    : Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Quest details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.grey[500] : Theme.of(context).textTheme.bodyLarge?.color,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRewardChip(
                        '⭐ +${quest.xpReward} XP',
                        primaryColor,
                        isCompleted,
                      ),
                      const SizedBox(width: 8),
                      _buildTypeChip(quest.type, isCompleted),
                    ],
                  ),
                ],
              ),
            ),
            // Complete button or checkmark
            if (!isCompleted)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.5),
                  ),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildRewardChip(String text, Color color, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.grey.withOpacity(0.2)
            : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isCompleted ? Colors.grey[500] : color,
        ),
      ),
    );
  }

  Widget _buildTypeChip(QuestType type, bool isCompleted) {
    String label;
    switch (type) {
      case QuestType.focus:
        label = 'Focus';
        break;
      case QuestType.health:
        label = 'Health';
        break;
      case QuestType.discipline:
        label = 'Discipline';
        break;
      case QuestType.side:
        label = 'Side Quest';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isCompleted ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }
}
