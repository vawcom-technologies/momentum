import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/combo_animation.dart';
import 'quests_screen.dart';
import 'stats_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'life_hub_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navController;

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;
        if (gameState == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildDashboard(gameState, provider),
                  const QuestsScreen(),
                  const LifeHubScreen(),
                  const StatsScreen(),
                  const AchievementsScreen(),
                  const SettingsScreen(),
                ],
              ),
              bottomNavigationBar: _buildBottomNav(),
            ),
            // Level Up Overlay
            if (provider.showLevelUpOverlay)
              LevelUpOverlay(
                newLevel: provider.newLevel,
                title: _getLevelTitle(provider.newLevel),
                onDismiss: provider.dismissLevelUpOverlay,
              ),
            // Combo Animation
            if (provider.showComboAnimation && gameState.combo >= 3)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                right: 0,
                child: ComboAnimation(combo: gameState.combo),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDashboard(GameState gameState, GameProvider provider) {
    final completedQuests = gameState.dailyQuests
        .where((q) => q.status == QuestStatus.completed)
        .length;
    final totalQuests = gameState.dailyQuests.length;
    final xpEarnedToday = gameState.dailyXpHistory[
            DateTime.now().toIso8601String().split('T')[0]] ??
        0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header with streak
            _buildHeader(gameState)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.2, end: 0),
            const SizedBox(height: 24),

            // XP Progress Card
            _buildXPCard(gameState),
            const SizedBox(height: 20),

            // Streak & Combo Row
            _buildStreakComboRow(gameState)
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 24),

            // Core Stats Section
            _buildCoreStatsHeader()
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms),
            const SizedBox(height: 16),
            _buildStatsGrid(gameState)
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Today's Progress Card
            _buildTodayProgressCard(gameState, completedQuests, totalQuests, xpEarnedToday)
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildXPCard(GameState gameState) {
    final progress = gameState.levelProgress;
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                'Experience',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${gameState.xp} / ${gameState.xpToNextLevel} XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
                color: Colors.grey[200],
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
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '$percentage% to next level',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GameState gameState) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 16, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  'Level ${gameState.level}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Life RPG',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getLevelTitle(gameState.level),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakComboRow(GameState gameState) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: gameState.streakEmoji,
            title: 'Streak',
            value: '${gameState.currentStreak} days',
            color: const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: '⚡',
            title: 'Combo',
            value: gameState.isComboActive ? '${gameState.combo}x' : 'None',
            color: const Color(0xFFF59E0B),
            isActive: gameState.isComboActive,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: '🎯',
            title: 'Multiplier',
            value: '${gameState.effectiveXpMultiplier.toStringAsFixed(1)}x',
            color: const Color(0xFF22C55E),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCoreStatsHeader() {
    return Row(
      children: [
        Icon(Icons.bolt, size: 20, color: Colors.grey[800]),
        const SizedBox(width: 8),
        Text(
          'Core Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(GameState gameState) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
            'Discipline', gameState.stats.discipline.toInt(), const Color(0xFFEF4444)),
        _buildStatCard(
            'Focus', gameState.stats.focus.toInt(), const Color(0xFF3B82F6)),
        _buildStatCard(
            'Health', gameState.stats.health.toInt(), const Color(0xFF22C55E)),
        _buildStatCard(
            'Money', gameState.stats.money.toInt(), const Color(0xFFEAB308)),
      ],
    );
  }

  Widget _buildStatCard(String name, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgressCard(GameState gameState, int completed, int total, int xpEarned) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressRow('Quests Completed', '$completed/$total', const Color(0xFF22C55E)),
          const SizedBox(height: 12),
          _buildProgressRow('XP Earned Today', '+$xpEarned XP', const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          _buildProgressRow('Current Streak', '${gameState.currentStreak} days 🔥', const Color(0xFFF97316)),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }


  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.my_location, 'Quests', 1),
              _buildNavItem(Icons.spa, 'Life', 2),
              _buildNavItem(Icons.trending_up, 'Stats', 3),
              _buildNavItem(Icons.emoji_events, 'Badges', 4),
              _buildNavItem(Icons.settings, 'Settings', 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.purple[700] : Colors.grey[500],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.purple[700] : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level < 5) return 'NPC Mode';
    if (level < 10) return 'Grinding Era';
    if (level < 20) return 'Main Character';
    return 'Final Boss';
  }
}
