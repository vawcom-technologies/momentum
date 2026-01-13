enum BossDifficulty {
  easy,
  medium,
  hard,
  legendary,
}

enum BossStatus {
  available,
  inProgress,
  defeated,
  failed,
}

class BossBattle {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BossDifficulty difficulty;
  final BossStatus status;
  final int requiredQuests;
  final int completedQuests;
  final int xpReward;
  final int bonusStatPoints;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final List<String> challenges;

  BossBattle({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.difficulty,
    this.status = BossStatus.available,
    required this.requiredQuests,
    this.completedQuests = 0,
    required this.xpReward,
    required this.bonusStatPoints,
    this.startedAt,
    this.expiresAt,
    required this.challenges,
  });

  double get progress => completedQuests / requiredQuests;
  
  bool get isCompleted => completedQuests >= requiredQuests;
  
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  int get remainingHours {
    if (expiresAt == null) return 0;
    return expiresAt!.difference(DateTime.now()).inHours.clamp(0, 999);
  }

  String get difficultyName {
    switch (difficulty) {
      case BossDifficulty.easy:
        return 'Easy';
      case BossDifficulty.medium:
        return 'Medium';
      case BossDifficulty.hard:
        return 'Hard';
      case BossDifficulty.legendary:
        return 'Legendary';
    }
  }

  BossBattle copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    BossDifficulty? difficulty,
    BossStatus? status,
    int? requiredQuests,
    int? completedQuests,
    int? xpReward,
    int? bonusStatPoints,
    DateTime? startedAt,
    DateTime? expiresAt,
    List<String>? challenges,
  }) {
    return BossBattle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      requiredQuests: requiredQuests ?? this.requiredQuests,
      completedQuests: completedQuests ?? this.completedQuests,
      xpReward: xpReward ?? this.xpReward,
      bonusStatPoints: bonusStatPoints ?? this.bonusStatPoints,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      challenges: challenges ?? this.challenges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'difficulty': difficulty.index,
      'status': status.index,
      'requiredQuests': requiredQuests,
      'completedQuests': completedQuests,
      'xpReward': xpReward,
      'bonusStatPoints': bonusStatPoints,
      'startedAt': startedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'challenges': challenges,
    };
  }

  factory BossBattle.fromJson(Map<String, dynamic> json) {
    return BossBattle(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      difficulty: BossDifficulty.values[json['difficulty']],
      status: BossStatus.values[json['status']],
      requiredQuests: json['requiredQuests'],
      completedQuests: json['completedQuests'] ?? 0,
      xpReward: json['xpReward'],
      bonusStatPoints: json['bonusStatPoints'],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      challenges: List<String>.from(json['challenges'] ?? []),
    );
  }

  static BossBattle weeklyBoss() {
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));
    
    return BossBattle(
      id: 'weekly_boss_${now.millisecondsSinceEpoch}',
      name: 'The Procrastinator',
      description: 'Defeat procrastination by completing all daily quests!',
      icon: '👹',
      difficulty: BossDifficulty.hard,
      requiredQuests: 21,
      xpReward: 500,
      bonusStatPoints: 10,
      expiresAt: endOfWeek,
      challenges: [
        'Complete 3 daily quests per day',
        'Maintain a 7-day streak',
        'Earn 500+ XP this week',
      ],
    );
  }
}
