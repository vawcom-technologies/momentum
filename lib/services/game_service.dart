import '../models/game_state.dart';
import '../models/user_stats.dart';
import '../models/quest.dart';
import '../models/achievement.dart';
import '../models/power_up.dart';
import '../models/boss_battle.dart';

class GameService {
  static const int baseXpPerLevel = 100;
  static const int comboTimeoutMinutes = 30;
  
  // Generate default daily quests
  List<Quest> generateDailyQuests() {
    final now = DateTime.now();
    return [
      Quest(
        id: 'focus_${now.millisecondsSinceEpoch}',
        title: 'Deep Work Session',
        description: 'Complete a focused work session (min 60 min)',
        type: QuestType.focus,
        xpReward: 15,
        createdAt: now,
      ),
      Quest(
        id: 'health_${now.millisecondsSinceEpoch}',
        title: 'Move Your Body',
        description: 'Hit your step goal (10,000 steps)',
        type: QuestType.health,
        xpReward: 15,
        createdAt: now,
      ),
      Quest(
        id: 'discipline_${now.millisecondsSinceEpoch}',
        title: 'Hardest Task First',
        description: 'Complete your hardest task of the day',
        type: QuestType.discipline,
        xpReward: 20,
        createdAt: now,
      ),
      Quest(
        id: 'side_1_${now.millisecondsSinceEpoch}',
        title: 'Stay Hydrated',
        description: 'Drink 8 glasses of water today',
        type: QuestType.side,
        xpReward: 5,
        createdAt: now,
      ),
      Quest(
        id: 'side_2_${now.millisecondsSinceEpoch}',
        title: 'Read a Book',
        description: 'Read for at least 30 minutes',
        type: QuestType.side,
        xpReward: 10,
        createdAt: now,
      ),
    ];
  }

  // Generate default achievements
  List<Achievement> generateAchievements() {
    return [
      Achievement(
        id: 'monk_mode',
        title: 'Monk Mode',
        description: 'Complete 7 days without excessive screen time',
        icon: '🧘',
        xpReward: 100,
      ),
      Achievement(
        id: 'no_excuses',
        title: 'No Excuses',
        description: 'Complete all daily quests for 7 days straight',
        icon: '💪',
        xpReward: 150,
      ),
      Achievement(
        id: 'villain_arc',
        title: 'Villain Arc',
        description: 'Reach level 25 (Main Character)',
        icon: '🔥',
        xpReward: 200,
      ),
      Achievement(
        id: 'first_quest',
        title: 'First Quest',
        description: 'Complete your first quest',
        icon: '⭐',
        xpReward: 25,
      ),
      Achievement(
        id: 'level_10',
        title: 'Grinding Era',
        description: 'Reach level 10',
        icon: '⚔️',
        xpReward: 50,
      ),
      Achievement(
        id: 'level_50',
        title: 'Final Boss',
        description: 'Reach level 50',
        icon: '👑',
        xpReward: 500,
      ),
      Achievement(
        id: 'combo_master',
        title: 'Combo Master',
        description: 'Achieve a 10x combo',
        icon: '⚡',
        xpReward: 100,
      ),
      Achievement(
        id: 'streak_week',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: '🔥',
        xpReward: 75,
      ),
      Achievement(
        id: 'streak_month',
        title: 'Monthly Legend',
        description: 'Maintain a 30-day streak',
        icon: '🌟',
        xpReward: 300,
      ),
      Achievement(
        id: 'boss_slayer',
        title: 'Boss Slayer',
        description: 'Defeat your first boss',
        icon: '🗡️',
        xpReward: 150,
      ),
      Achievement(
        id: 'lucky_spin',
        title: 'Lucky Spin',
        description: 'Win the jackpot on the daily spin',
        icon: '🎰',
        xpReward: 50,
      ),
      Achievement(
        id: 'power_collector',
        title: 'Power Collector',
        description: 'Collect all power-up types',
        icon: '💫',
        xpReward: 100,
      ),
    ];
  }

  // Calculate XP needed for a level
  int xpForLevel(int level) {
    return level * baseXpPerLevel;
  }

  // Add XP and handle leveling
  GameState addXp(GameState state, int xp) {
    // Apply multiplier
    int effectiveXp = (xp * state.effectiveXpMultiplier).round();
    int newXp = state.xp + effectiveXp;
    int newLevel = state.level;

    // Level up if XP threshold is met
    while (newXp >= xpForLevel(newLevel + 1)) {
      newXp -= xpForLevel(newLevel + 1);
      newLevel++;
    }
    
    // Track daily XP
    final today = DateTime.now().toIso8601String().split('T')[0];
    final newDailyXpHistory = Map<String, int>.from(state.dailyXpHistory);
    newDailyXpHistory[today] = (newDailyXpHistory[today] ?? 0) + effectiveXp;

    return state.copyWith(
      xp: newXp, 
      level: newLevel,
      dailyXpHistory: newDailyXpHistory,
    );
  }

  // Update stats based on actions
  GameState updateStats(GameState state, {
    double? disciplineDelta,
    double? focusDelta,
    double? healthDelta,
    double? moneyDelta,
  }) {
    UserStats newStats = state.stats.copyWith(
      discipline: (state.stats.discipline + (disciplineDelta ?? 0))
          .clamp(0.0, 100.0),
      focus: (state.stats.focus + (focusDelta ?? 0)).clamp(0.0, 100.0),
      health: (state.stats.health + (healthDelta ?? 0)).clamp(0.0, 100.0),
      money: (state.stats.money + (moneyDelta ?? 0)).clamp(0.0, 100.0),
    );

    return state.copyWith(stats: newStats);
  }

  // Apply daily stat decay (NPC behavior)
  GameState applyStatDecay(GameState state) {
    // Check if shield power-up is active
    for (var powerUp in state.activePowerUps) {
      if (!powerUp.isExpired && powerUp.type == PowerUpType.shieldDecay) {
        return state; // No decay with shield
      }
    }
    
    const double decayRate = 2.0; // Decay 2 points per day if inactive
    UserStats newStats = state.stats.copyWith(
      discipline: (state.stats.discipline - decayRate).clamp(0.0, 100.0),
      focus: (state.stats.focus - decayRate).clamp(0.0, 100.0),
      health: (state.stats.health - decayRate).clamp(0.0, 100.0),
      money: (state.stats.money - decayRate).clamp(0.0, 100.0),
    );

    return state.copyWith(stats: newStats);
  }

  // Complete a quest with combo system
  GameState completeQuest(GameState state, String questId) {
    // Find the quest
    final questIndex = state.dailyQuests.indexWhere(
      (q) => q.id == questId && q.status == QuestStatus.pending,
    );

    if (questIndex == -1) {
      return state; // Quest not found or already completed
    }

    final quest = state.dailyQuests[questIndex];
    final now = DateTime.now();

    // Update combo
    int newCombo = state.combo;
    if (state.isComboActive) {
      newCombo++;
    } else {
      newCombo = 1;
    }
    int newMaxCombo = newCombo > state.maxCombo ? newCombo : state.maxCombo;

    // Update stats based on quest type
    GameState newState = state.copyWith(
      combo: newCombo,
      maxCombo: newMaxCombo,
      lastQuestCompletedAt: now,
      totalQuestsCompleted: state.totalQuestsCompleted + 1,
    );
    
    switch (quest.type) {
      case QuestType.focus:
        newState = updateStats(newState, focusDelta: 5.0);
        break;
      case QuestType.health:
        newState = updateStats(newState, healthDelta: 5.0);
        break;
      case QuestType.discipline:
        newState = updateStats(newState, disciplineDelta: 5.0);
        break;
      case QuestType.side:
        newState = updateStats(newState, disciplineDelta: 2.0);
        break;
    }

    // Add XP (with combo multiplier applied through effectiveXpMultiplier)
    newState = addXp(newState, quest.xpReward);

    // Update quest status
    final quests = List<Quest>.from(state.dailyQuests);
    quests[questIndex] = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: now,
    );
    
    // Update boss battle progress
    BossBattle? updatedBoss = newState.currentBoss;
    if (updatedBoss != null && updatedBoss.status == BossStatus.inProgress) {
      updatedBoss = updatedBoss.copyWith(
        completedQuests: updatedBoss.completedQuests + 1,
      );
    }
    
    // Check for loot box reward (every 10 quests)
    int lootBoxes = newState.lootBoxesEarned;
    if (newState.totalQuestsCompleted % 10 == 0) {
      lootBoxes++;
    }

    return newState.copyWith(
      dailyQuests: quests,
      currentBoss: updatedBoss,
      lootBoxesEarned: lootBoxes,
    );
  }

  // Update streak
  GameState updateStreak(GameState state, bool completedAllQuests) {
    if (!completedAllQuests) {
      return state.copyWith(currentStreak: 0);
    }
    
    final newStreak = state.currentStreak + 1;
    final newLongestStreak = newStreak > state.longestStreak 
        ? newStreak 
        : state.longestStreak;
    
    return state.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
    );
  }

  // Activate a power-up
  GameState activatePowerUp(GameState state, String powerUpId) {
    final powerUpIndex = state.powerUps.indexWhere((p) => p.id == powerUpId);
    if (powerUpIndex == -1) return state;
    
    final powerUp = state.powerUps[powerUpIndex];
    final activatedPowerUp = powerUp.copyWith(
      isActive: true,
      activatedAt: DateTime.now(),
    );
    
    final newPowerUps = List<PowerUp>.from(state.powerUps);
    newPowerUps.removeAt(powerUpIndex);
    
    final newActivePowerUps = List<PowerUp>.from(state.activePowerUps);
    newActivePowerUps.add(activatedPowerUp);
    
    return state.copyWith(
      powerUps: newPowerUps,
      activePowerUps: newActivePowerUps,
    );
  }

  // Add a power-up to inventory
  GameState addPowerUp(GameState state, PowerUp powerUp) {
    final newPowerUps = List<PowerUp>.from(state.powerUps);
    newPowerUps.add(powerUp);
    return state.copyWith(powerUps: newPowerUps);
  }

  // Clean up expired power-ups
  GameState cleanExpiredPowerUps(GameState state) {
    final activeNotExpired = state.activePowerUps
        .where((p) => !p.isExpired)
        .toList();
    
    return state.copyWith(activePowerUps: activeNotExpired);
  }

  // Start a boss battle
  GameState startBossBattle(GameState state, BossBattle boss) {
    final startedBoss = boss.copyWith(
      status: BossStatus.inProgress,
      startedAt: DateTime.now(),
    );
    return state.copyWith(currentBoss: startedBoss);
  }

  // Complete boss battle
  GameState completeBossBattle(GameState state) {
    if (state.currentBoss == null) return state;
    if (!state.currentBoss!.isCompleted) return state;
    
    final defeatedBoss = state.currentBoss!.copyWith(
      status: BossStatus.defeated,
    );
    
    final newDefeatedBosses = List<BossBattle>.from(state.defeatedBosses);
    newDefeatedBosses.add(defeatedBoss);
    
    // Award rewards
    GameState newState = addXp(state, defeatedBoss.xpReward);
    newState = updateStats(
      newState,
      disciplineDelta: defeatedBoss.bonusStatPoints.toDouble(),
      focusDelta: defeatedBoss.bonusStatPoints.toDouble(),
      healthDelta: defeatedBoss.bonusStatPoints.toDouble(),
    );
    
    return newState.copyWith(
      currentBoss: null,
      defeatedBosses: newDefeatedBosses,
    );
  }

  // Process daily spin
  GameState processSpin(GameState state, int xpReward, {
    bool isMultiplier = false,
    int multiplier = 1,
    bool isPowerUp = false,
  }) {
    GameState newState = state.copyWith(lastSpinDate: DateTime.now());
    
    if (xpReward > 0) {
      newState = addXp(newState, xpReward);
    }
    
    if (isMultiplier) {
      newState = newState.copyWith(
        xpMultiplier: state.xpMultiplier * multiplier,
      );
    }
    
    if (isPowerUp) {
      // Add a random power-up
      final powerUps = PowerUp.defaultPowerUps();
      final randomPowerUp = powerUps[DateTime.now().millisecond % powerUps.length];
      newState = addPowerUp(newState, randomPowerUp.copyWith(
        id: '${randomPowerUp.id}_${DateTime.now().millisecondsSinceEpoch}',
      ));
    }
    
    return newState;
  }

  // Check and unlock achievements
  GameState checkAchievements(GameState state) {
    int totalXpEarned = 0;
    final achievements = state.achievements.map((achievement) {
      if (achievement.unlocked) return achievement;

      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_quest':
          shouldUnlock = state.dailyQuests
              .any((q) => q.status == QuestStatus.completed);
          break;
        case 'level_10':
          shouldUnlock = state.level >= 10;
          break;
        case 'level_50':
          shouldUnlock = state.level >= 50;
          break;
        case 'villain_arc':
          shouldUnlock = state.level >= 25;
          break;
        case 'combo_master':
          shouldUnlock = state.maxCombo >= 10;
          break;
        case 'streak_week':
          shouldUnlock = state.longestStreak >= 7;
          break;
        case 'streak_month':
          shouldUnlock = state.longestStreak >= 30;
          break;
        case 'boss_slayer':
          shouldUnlock = state.defeatedBosses.isNotEmpty;
          break;
      }

      if (shouldUnlock) {
        totalXpEarned += achievement.xpReward;
        return achievement.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now(),
        );
      }

      return achievement;
    }).toList();

    GameState newState = state.copyWith(achievements: achievements);
    if (totalXpEarned > 0) {
      newState = addXp(newState, totalXpEarned);
    }
    return newState;
  }

  // Update screen time and affect focus
  GameState updateScreenTime(GameState state, int minutes) {
    final newState = state.copyWith(totalScreenTimeMinutes: minutes);
    
    // High screen time reduces focus (threshold: 4 hours = 240 minutes)
    if (minutes > 240) {
      final focusPenalty = ((minutes - 240) / 60 * 2).clamp(0.0, 10.0);
      return updateStats(newState, focusDelta: -focusPenalty);
    }
    
    // Low screen time increases focus (below 2 hours = 120 minutes)
    if (minutes < 120) {
      return updateStats(newState, focusDelta: 2.0);
    }
    
    return newState;
  }

  // Update steps and affect health
  GameState updateSteps(GameState state, int steps) {
    final newState = state.copyWith(stepsToday: steps);
    
    // Meeting step goal increases health (10,000 steps)
    if (steps >= 10000) {
      return updateStats(newState, healthDelta: 5.0);
    }
    
    return newState;
  }

  // Create initial game state
  GameState createInitialState() {
    return GameState(
      stats: UserStats(
        discipline: 50.0,
        focus: 50.0,
        health: 50.0,
        money: 50.0,
      ),
      xp: 0,
      level: 1,
      dailyQuests: generateDailyQuests(),
      achievements: generateAchievements(),
      lastUpdated: DateTime.now(),
      currentStreak: 0,
      longestStreak: 0,
      combo: 0,
      maxCombo: 0,
      powerUps: [],
      activePowerUps: [],
      currentBoss: BossBattle.weeklyBoss(),
      defeatedBosses: [],
      totalQuestsCompleted: 0,
      lootBoxesEarned: 0,
      avatarId: 'default',
      dailyXpHistory: {},
    );
  }
}
