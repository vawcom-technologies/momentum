import 'user_stats.dart';
import 'quest.dart';
import 'achievement.dart';

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

  GameState({
    required this.stats,
    this.xp = 0,
    this.level = 0,
    required this.dailyQuests,
    required this.achievements,
    this.totalScreenTimeMinutes = 0,
    this.stepsToday = 0,
    required this.lastUpdated,
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

  GameState copyWith({
    UserStats? stats,
    int? xp,
    int? level,
    List<Quest>? dailyQuests,
    List<Achievement>? achievements,
    int? totalScreenTimeMinutes,
    int? stepsToday,
    DateTime? lastUpdated,
  }) {
    return GameState(
      stats: stats ?? this.stats,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      dailyQuests: dailyQuests ?? this.dailyQuests,
      achievements: achievements ?? this.achievements,
      totalScreenTimeMinutes:
          totalScreenTimeMinutes ?? this.totalScreenTimeMinutes,
      stepsToday: stepsToday ?? this.stepsToday,
      lastUpdated: lastUpdated ?? this.lastUpdated,
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
    );
  }
}