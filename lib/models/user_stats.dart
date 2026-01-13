class UserStats {
  final double discipline;
  final double focus;
  final double health;
  final double money;

  UserStats({
    required this.discipline,
    required this.focus,
    required this.health,
    required this.money,
  });

  UserStats copyWith({
    double? discipline,
    double? focus,
    double? health,
    double? money,
  }) {
    return UserStats(
      discipline: discipline ?? this.discipline,
      focus: focus ?? this.focus,
      health: health ?? this.health,
      money: money ?? this.money,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discipline': discipline,
      'focus': focus,
      'health': health,
      'money': money,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      discipline: (json['discipline'] ?? 50).toDouble(),
      focus: (json['focus'] ?? 50).toDouble(),
      health: (json['health'] ?? 50).toDouble(),
      money: (json['money'] ?? 50).toDouble(),
    );
  }

  double get averageStat => (discipline + focus + health + money) / 4;
}