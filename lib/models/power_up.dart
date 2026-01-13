enum PowerUpType {
  doubleXP,
  shieldDecay,
  comboBoost,
  questRefresh,
  luckBoost,
}

class PowerUp {
  final String id;
  final PowerUpType type;
  final String name;
  final String description;
  final String icon;
  final int durationMinutes;
  final DateTime? activatedAt;
  final bool isActive;

  PowerUp({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.durationMinutes,
    this.activatedAt,
    this.isActive = false,
  });

  bool get isExpired {
    if (!isActive || activatedAt == null) return true;
    return DateTime.now().difference(activatedAt!).inMinutes > durationMinutes;
  }

  int get remainingMinutes {
    if (!isActive || activatedAt == null) return 0;
    final elapsed = DateTime.now().difference(activatedAt!).inMinutes;
    return (durationMinutes - elapsed).clamp(0, durationMinutes);
  }

  PowerUp copyWith({
    String? id,
    PowerUpType? type,
    String? name,
    String? description,
    String? icon,
    int? durationMinutes,
    DateTime? activatedAt,
    bool? isActive,
  }) {
    return PowerUp(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      activatedAt: activatedAt ?? this.activatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'name': name,
      'description': description,
      'icon': icon,
      'durationMinutes': durationMinutes,
      'activatedAt': activatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory PowerUp.fromJson(Map<String, dynamic> json) {
    return PowerUp(
      id: json['id'],
      type: PowerUpType.values[json['type']],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      durationMinutes: json['durationMinutes'],
      activatedAt: json['activatedAt'] != null
          ? DateTime.parse(json['activatedAt'])
          : null,
      isActive: json['isActive'] ?? false,
    );
  }

  static List<PowerUp> defaultPowerUps() {
    return [
      PowerUp(
        id: 'double_xp',
        type: PowerUpType.doubleXP,
        name: 'Double XP',
        description: '2x XP for all quests',
        icon: '🔥',
        durationMinutes: 60,
      ),
      PowerUp(
        id: 'shield',
        type: PowerUpType.shieldDecay,
        name: 'Decay Shield',
        description: 'Prevent stat decay for 24h',
        icon: '🛡️',
        durationMinutes: 1440,
      ),
      PowerUp(
        id: 'combo_boost',
        type: PowerUpType.comboBoost,
        name: 'Combo Boost',
        description: 'Faster combo building',
        icon: '⚡',
        durationMinutes: 30,
      ),
      PowerUp(
        id: 'luck_boost',
        type: PowerUpType.luckBoost,
        name: 'Lucky Charm',
        description: 'Better spin wheel odds',
        icon: '🍀',
        durationMinutes: 120,
      ),
    ];
  }
}
