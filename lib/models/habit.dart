import 'package:flutter/material.dart';

enum HabitFrequency {
  daily,
  weekdays,
  weekends,
  custom,
}

enum HabitCategory {
  health,
  productivity,
  mindfulness,
  fitness,
  learning,
  social,
  finance,
  creativity,
}

class Habit {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final HabitCategory category;
  final HabitFrequency frequency;
  final List<int> customDays; // 1-7 for Mon-Sun
  final int targetCount; // times per day
  final Map<String, int> completions; // date -> count
  final DateTime createdAt;
  final String? reminder; // time string like "08:00"
  final int currentStreak;
  final int longestStreak;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
    this.frequency = HabitFrequency.daily,
    this.customDays = const [],
    this.targetCount = 1,
    this.completions = const {},
    required this.createdAt,
    this.reminder,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  bool isCompletedToday() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return (completions[today] ?? 0) >= targetCount;
  }

  int getTodayCount() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return completions[today] ?? 0;
  }

  double getTodayProgress() {
    return (getTodayCount() / targetCount).clamp(0.0, 1.0);
  }

  bool isDueToday() {
    final weekday = DateTime.now().weekday;
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return weekday >= 1 && weekday <= 5;
      case HabitFrequency.weekends:
        return weekday == 6 || weekday == 7;
      case HabitFrequency.custom:
        return customDays.contains(weekday);
    }
  }

  int getWeekCompletions() {
    final now = DateTime.now();
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      if ((completions[dateStr] ?? 0) >= targetCount) {
        count++;
      }
    }
    return count;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    HabitCategory? category,
    HabitFrequency? frequency,
    List<int>? customDays,
    int? targetCount,
    Map<String, int>? completions,
    DateTime? createdAt,
    String? reminder,
    int? currentStreak,
    int? longestStreak,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      targetCount: targetCount ?? this.targetCount,
      completions: completions ?? this.completions,
      createdAt: createdAt ?? this.createdAt,
      reminder: reminder ?? this.reminder,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'category': category.index,
      'frequency': frequency.index,
      'customDays': customDays,
      'targetCount': targetCount,
      'completions': completions,
      'createdAt': createdAt.toIso8601String(),
      'reminder': reminder,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: Color(json['color']),
      category: HabitCategory.values[json['category']],
      frequency: HabitFrequency.values[json['frequency']],
      customDays: List<int>.from(json['customDays'] ?? []),
      targetCount: json['targetCount'] ?? 1,
      completions: Map<String, int>.from(json['completions'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      reminder: json['reminder'],
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }

  static List<Habit> defaultHabits() {
    final now = DateTime.now();
    return [
      Habit(
        id: 'habit_water',
        name: 'Drink Water',
        icon: '💧',
        color: const Color(0xFF3B82F6),
        category: HabitCategory.health,
        targetCount: 8,
        createdAt: now,
      ),
      Habit(
        id: 'habit_exercise',
        name: 'Exercise',
        icon: '🏃',
        color: const Color(0xFF22C55E),
        category: HabitCategory.fitness,
        createdAt: now,
      ),
      Habit(
        id: 'habit_read',
        name: 'Read',
        icon: '📚',
        color: const Color(0xFF8B5CF6),
        category: HabitCategory.learning,
        createdAt: now,
      ),
      Habit(
        id: 'habit_meditate',
        name: 'Meditate',
        icon: '🧘',
        color: const Color(0xFFF59E0B),
        category: HabitCategory.mindfulness,
        createdAt: now,
      ),
    ];
  }
}
