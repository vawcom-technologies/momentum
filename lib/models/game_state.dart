import 'user_stats.dart';
import 'quest.dart';
import 'achievement.dart';
import 'power_up.dart';
import 'boss_battle.dart';

enum PlayerLevel {
  npcMode, // 0-9
  grindingEra, // 10-24
  mainCharacter, // 25-49
  finalBoss, // 50+
}

class GameState {
  final UserStats stats;
  final int xp;
  final int level;
  final List<Quest> dailyQuests;
  final List<Achievement> achievements;
  final int totalScreenTimeMinutes;
  final int stepsToday;
  final DateTime lastUpdated;
  
  // New gamification features
  final int currentStreak;
  final int longestStreak;
  final int combo;
  final int maxCombo;
  final DateTime? lastQuestCompletedAt;
  final double xpMultiplier;
  final List<PowerUp> powerUps;
  final List<PowerUp> activePowerUps;
  final BossBattle? currentBoss;
  final List<BossBattle> defeatedBosses;
  final DateTime? lastSpinDate;
  final int totalQuestsCompleted;
  final int lootBoxesEarned;
  final String avatarId;
  final Map<String, int> dailyXpHistory;

  GameState({
    required this.stats,
    this.xp = 0,
    this.level = 0,
    required this.dailyQuests,
    required this.achievements,
    this.totalScreenTimeMinutes = 0,
    this.stepsToday = 0,
    required this.lastUpdated,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.lastQuestCompletedAt,
    this.xpMultiplier = 1.0,
    this.powerUps = const [],
    this.activePowerUps = const [],
    this.currentBoss,
    this.defeatedBosses = const [],
    this.lastSpinDate,
    this.totalQuestsCompleted = 0,
    this.lootBoxesEarned = 0,
    this.avatarId = 'default',
    this.dailyXpHistory = const {},
  });

  PlayerLevel get playerLevel {
    if (level < 10) return PlayerLevel.npcMode;
    if (level < 25) return PlayerLevel.grindingEra;
    if (level < 50) return PlayerLevel.mainCharacter;
    return PlayerLevel.finalBoss;
  }

  int get xpToNextLevel {
    return (level + 1) * 100;
  }

  double get levelProgress => xp / xpToNextLevel;
  
  bool get canSpinToday {
    if (lastSpinDate == null) return true;
    final now = DateTime.now();
    return now.day != lastSpinDate!.day || 
           now.month != lastSpinDate!.month || 
           now.year != lastSpinDate!.year;
  }
  
  bool get isComboActive {
    if (lastQuestCompletedAt == null) return false;
    return DateTime.now().difference(lastQuestCompletedAt!).inMinutes < 30;
  }
  
  double get effectiveXpMultiplier {
    double multiplier = xpMultiplier;
    
    // Combo bonus
    if (combo > 0) {
      multiplier += (combo * 0.1).clamp(0, 1.0); // Max +100% from combo
    }
    
    // Active power-ups
    for (var powerUp in activePowerUps) {
      if (!powerUp.isExpired && powerUp.type == PowerUpType.doubleXP) {
        multiplier *= 2;
      }
    }
    
    return multiplier;
  }
  
  String get streakEmoji {
    if (currentStreak >= 30) return '🌟';
    if (currentStreak >= 14) return '💎';
    if (currentStreak >= 7) return '🔥';
    if (currentStreak >= 3) return '✨';
    return '⭐';
  }
  
  String get comboText {
    if (combo >= 10) return 'ULTRA COMBO!';
    if (combo >= 5) return 'SUPER COMBO!';
    if (combo >= 3) return 'COMBO x$combo';
    return '';
  }

  GameState copyWith({
    UserStats? stats,
    int? xp,
    int? level,
    List<Quest>? dailyQuests,
    List<Achievement>? achievements,
    int? totalScreenTimeMinutes,
    int? stepsToday,
    DateTime? lastUpdated,
    int? currentStreak,
    int? longestStreak,
    int? combo,
    int? maxCombo,
    DateTime? lastQuestCompletedAt,
    double? xpMultiplier,
    List<PowerUp>? powerUps,
    List<PowerUp>? activePowerUps,
    BossBattle? currentBoss,
    List<BossBattle>? defeatedBosses,
    DateTime? lastSpinDate,
    int? totalQuestsCompleted,
    int? lootBoxesEarned,
    String? avatarId,
    Map<String, int>? dailyXpHistory,
  }) {
    return GameState(
      stats: stats ?? this.stats,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      dailyQuests: dailyQuests ?? this.dailyQuests,
      achievements: achievements ?? this.achievements,
      totalScreenTimeMinutes: totalScreenTimeMinutes ?? this.totalScreenTimeMinutes,
      stepsToday: stepsToday ?? this.stepsToday,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      lastQuestCompletedAt: lastQuestCompletedAt ?? this.lastQuestCompletedAt,
      xpMultiplier: xpMultiplier ?? this.xpMultiplier,
      powerUps: powerUps ?? this.powerUps,
      activePowerUps: activePowerUps ?? this.activePowerUps,
      currentBoss: currentBoss ?? this.currentBoss,
      defeatedBosses: defeatedBosses ?? this.defeatedBosses,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
      totalQuestsCompleted: totalQuestsCompleted ?? this.totalQuestsCompleted,
      lootBoxesEarned: lootBoxesEarned ?? this.lootBoxesEarned,
      avatarId: avatarId ?? this.avatarId,
      dailyXpHistory: dailyXpHistory ?? this.dailyXpHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'xp': xp,
      'level': level,
      'dailyQuests': dailyQuests.map((q) => q.toJson()).toList(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'totalScreenTimeMinutes': totalScreenTimeMinutes,
      'stepsToday': stepsToday,
      'lastUpdated': lastUpdated.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'combo': combo,
      'maxCombo': maxCombo,
      'lastQuestCompletedAt': lastQuestCompletedAt?.toIso8601String(),
      'xpMultiplier': xpMultiplier,
      'powerUps': powerUps.map((p) => p.toJson()).toList(),
      'activePowerUps': activePowerUps.map((p) => p.toJson()).toList(),
      'currentBoss': currentBoss?.toJson(),
      'defeatedBosses': defeatedBosses.map((b) => b.toJson()).toList(),
      'lastSpinDate': lastSpinDate?.toIso8601String(),
      'totalQuestsCompleted': totalQuestsCompleted,
      'lootBoxesEarned': lootBoxesEarned,
      'avatarId': avatarId,
      'dailyXpHistory': dailyXpHistory,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      stats: UserStats.fromJson(json['stats']),
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 0,
      dailyQuests: (json['dailyQuests'] as List?)
              ?.map((q) => Quest.fromJson(q))
              .toList() ??
          [],
      achievements: (json['achievements'] as List?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
      totalScreenTimeMinutes: json['totalScreenTimeMinutes'] ?? 0,
      stepsToday: json['stepsToday'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      combo: json['combo'] ?? 0,
      maxCombo: json['maxCombo'] ?? 0,
      lastQuestCompletedAt: json['lastQuestCompletedAt'] != null
          ? DateTime.parse(json['lastQuestCompletedAt'])
          : null,
      xpMultiplier: (json['xpMultiplier'] ?? 1.0).toDouble(),
      powerUps: (json['powerUps'] as List?)
              ?.map((p) => PowerUp.fromJson(p))
              .toList() ??
          [],
      activePowerUps: (json['activePowerUps'] as List?)
              ?.map((p) => PowerUp.fromJson(p))
              .toList() ??
          [],
      currentBoss: json['currentBoss'] != null
          ? BossBattle.fromJson(json['currentBoss'])
          : null,
      defeatedBosses: (json['defeatedBosses'] as List?)
              ?.map((b) => BossBattle.fromJson(b))
              .toList() ??
          [],
      lastSpinDate: json['lastSpinDate'] != null
          ? DateTime.parse(json['lastSpinDate'])
          : null,
      totalQuestsCompleted: json['totalQuestsCompleted'] ?? 0,
      lootBoxesEarned: json['lootBoxesEarned'] ?? 0,
      avatarId: json['avatarId'] ?? 'default',
      dailyXpHistory: Map<String, int>.from(json['dailyXpHistory'] ?? {}),
    );
  }
}
