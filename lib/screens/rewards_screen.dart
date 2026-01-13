import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../widgets/spin_wheel.dart';
import '../widgets/power_up_card.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;
        if (gameState == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      '🎁 Rewards Center',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Spin, collect power-ups, and open loot boxes!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[500],
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎰'),
                          const SizedBox(width: 4),
                          const Text('Spin'),
                          if (gameState.canSpinToday)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⚡'),
                          const SizedBox(width: 4),
                          const Text('Power-ups'),
                          if (gameState.powerUps.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${gameState.powerUps.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📦'),
                          const SizedBox(width: 4),
                          const Text('Loot'),
                          if (gameState.lootBoxesEarned > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${gameState.lootBoxesEarned}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSpinTab(provider, gameState),
                    _buildPowerUpsTab(provider, gameState),
                    _buildLootBoxTab(provider, gameState),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpinTab(GameProvider provider, gameState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          DailySpinWheel(
            canSpin: gameState.canSpinToday,
            onRewardClaimed: (reward) {
              provider.processDailySpin(reward);
              HapticFeedback.heavyImpact();
            },
          ),
          const SizedBox(height: 24),
          // Spin history or tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pro Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTipRow('🎯', 'Spin daily for bonus XP and power-ups'),
                _buildTipRow('🍀', 'Lucky Charm power-up improves spin odds'),
                _buildTipRow('👑', 'Jackpot gives 500 XP - super rare!'),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTipRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpsTab(GameProvider provider, gameState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PowerUpInventory(
            powerUps: gameState.powerUps,
            activePowerUps: gameState.activePowerUps,
            onActivate: (id) {
              provider.activatePowerUp(id);
            },
          ),
          const SizedBox(height: 24),
          // Power-up guide
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📖 Power-up Guide',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGuideRow('🔥', 'Double XP', 'All XP gains are doubled'),
                _buildGuideRow('🛡️', 'Decay Shield', 'Prevent stat decay'),
                _buildGuideRow('⚡', 'Combo Boost', 'Faster combo building'),
                _buildGuideRow('🍀', 'Lucky Charm', 'Better spin wheel odds'),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGuideRow(String emoji, String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLootBoxTab(GameProvider provider, gameState) {
    final lootBoxes = gameState.lootBoxesEarned;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Loot boxes available
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                  const Color(0xFF6366F1).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '📦',
                  style: const TextStyle(fontSize: 64),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.1, duration: 1500.ms)
                    .rotate(begin: -0.05, end: 0.05, duration: 1500.ms),
                const SizedBox(height: 16),
                const Text(
                  'Loot Boxes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have $lootBoxes loot box${lootBoxes != 1 ? 'es' : ''} to open!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                if (lootBoxes > 0)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      _openLootBox(context, provider);
                    },
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
                        'OPEN LOOT BOX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(end: 1.05, duration: 1000.ms)
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Complete 10 quests to earn a loot box!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // How to earn
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎁 How to Earn Loot Boxes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildEarnRow(
                    '✅', 'Complete 10 quests', '1 loot box per 10 quests'),
                _buildEarnRow('🏆', 'Defeat a boss', '1 loot box'),
                _buildEarnRow('🔥', '7-day streak', '1 bonus loot box'),
                _buildEarnRow('⭐', 'Level up', 'Chance for loot box'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Possible rewards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎲 Possible Rewards',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRewardChip('⭐ XP', const Color(0xFF3B82F6)),
                    _buildRewardChip('⚡ Power-ups', const Color(0xFFF59E0B)),
                    _buildRewardChip('🎨 Avatars', const Color(0xFF8B5CF6)),
                    _buildRewardChip('📊 Stat boosts', const Color(0xFF22C55E)),
                    _buildRewardChip('💎 Rare items', const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEarnRow(String emoji, String action, String reward) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            reward,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
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

  void _openLootBox(BuildContext context, GameProvider provider) {
    // Show loot box opening animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LootBoxOpenDialog(
        onComplete: () {
          Navigator.of(context).pop();
          // Award random reward
          provider.addActionXp(50, disciplineDelta: 2, focusDelta: 2);
        },
      ),
    );
  }
}

class _LootBoxOpenDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _LootBoxOpenDialog({required this.onComplete});

  @override
  State<_LootBoxOpenDialog> createState() => _LootBoxOpenDialogState();
}

class _LootBoxOpenDialogState extends State<_LootBoxOpenDialog> {
  bool _isOpening = false;
  bool _showReward = false;
  String _reward = '';
  String _rewardEmoji = '';

  final List<Map<String, String>> _possibleRewards = [
    {'emoji': '⭐', 'text': '+50 XP'},
    {'emoji': '🔥', 'text': 'Double XP (1hr)'},
    {'emoji': '💪', 'text': '+5 Stats'},
    {'emoji': '⚡', 'text': 'Combo Boost'},
    {'emoji': '💎', 'text': '+100 XP'},
  ];

  void _openBox() async {
    HapticFeedback.heavyImpact();
    setState(() => _isOpening = true);

    await Future.delayed(const Duration(milliseconds: 2000));

    final reward =
        _possibleRewards[DateTime.now().millisecond % _possibleRewards.length];
    setState(() {
      _showReward = true;
      _rewardEmoji = reward['emoji']!;
      _reward = reward['text']!;
    });

    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_showReward) ...[
              Text(
                _isOpening ? '📦✨' : '📦',
                style: const TextStyle(fontSize: 80),
              )
                  .animate(target: _isOpening ? 1 : 0)
                  .shake(duration: 500.ms)
                  .then()
                  .scale(end: const Offset(1.5, 1.5), duration: 500.ms)
                  .then()
                  .fadeOut(duration: 300.ms),
              const SizedBox(height: 24),
              if (!_isOpening)
                GestureDetector(
                  onTap: _openBox,
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
                    ),
                    child: const Text(
                      'OPEN!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.05, duration: 800.ms),
              if (_isOpening)
                Text(
                  'Opening...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
            ] else ...[
              Text(
                _rewardEmoji,
                style: const TextStyle(fontSize: 80),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                    duration: 800.ms,
                  ),
              const SizedBox(height: 16),
              const Text(
                'You got:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _reward,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .shimmer(duration: 1500.ms, color: const Color(0xFFF59E0B)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: widget.onComplete,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'CLAIM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
