import '../models/game_state.dart';
import '../models/user_stats.dart';
import '../models/quest.dart';
import '../models/achievement.dart';

class GameService {
  static const int baseXpPerLevel = 100;
  
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
    ];
  }

  // Calculate XP needed for a level
  int xpForLevel(int level) {
    return level * baseXpPerLevel;
  }

  // Add XP and handle leveling
  GameState addXp(GameState state, int xp) {
    int newXp = state.xp + xp;
    int newLevel = state.level;

    // Level up if XP threshold is met
    while (newXp >= xpForLevel(newLevel + 1)) {
      newXp -= xpForLevel(newLevel + 1);
      newLevel++;
    }

    return state.copyWith(xp: newXp, level: newLevel);
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
    const double decayRate = 2.0; // Decay 2 points per day if inactive
    UserStats newStats = state.stats.copyWith(
      discipline: (state.stats.discipline - decayRate).clamp(0.0, 100.0),
      focus: (state.stats.focus - decayRate).clamp(0.0, 100.0),
      health: (state.stats.health - decayRate).clamp(0.0, 100.0),
      money: (state.stats.money - decayRate).clamp(0.0, 100.0),
    );

    return state.copyWith(stats: newStats);
  }

  // Complete a quest
  GameState completeQuest(GameState state, String questId) {
    // Find the quest
    final questIndex = state.dailyQuests.indexWhere(
      (q) => q.id == questId && q.status == QuestStatus.pending,
    );

    if (questIndex == -1) {
      return state; // Quest not found or already completed
    }

    final quest = state.dailyQuests[questIndex];

    // Update stats based on quest type
    GameState newState = state;
    switch (quest.type) {
      case QuestType.focus:
        newState = updateStats(state, focusDelta: 5.0);
        break;
      case QuestType.health:
        newState = updateStats(state, healthDelta: 5.0);
        break;
      case QuestType.discipline:
        newState = updateStats(state, disciplineDelta: 5.0);
        break;
      case QuestType.side:
        newState = updateStats(state, disciplineDelta: 2.0);
        break;
    }

    // Add XP
    newState = addXp(newState, quest.xpReward);

    // Update quest status
    final quests = List<Quest>.from(state.dailyQuests);
    quests[questIndex] = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
    );

    return newState.copyWith(dailyQuests: quests);
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
        // Add more achievement logic here
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
      level: 0,
      dailyQuests: generateDailyQuests(),
      achievements: generateAchievements(),
      lastUpdated: DateTime.now(),
    );
  }
}