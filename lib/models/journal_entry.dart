enum Mood {
  amazing,
  good,
  okay,
  bad,
  terrible,
}

class JournalEntry {
  final String id;
  final DateTime date;
  final Mood mood;
  final String? reflection;
  final List<String> gratitude;
  final List<String> accomplishments;
  final List<String> challenges;
  final String? tomorrowGoal;
  final int energyLevel; // 1-5
  final int productivityLevel; // 1-5
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.date,
    required this.mood,
    this.reflection,
    this.gratitude = const [],
    this.accomplishments = const [],
    this.challenges = const [],
    this.tomorrowGoal,
    this.energyLevel = 3,
    this.productivityLevel = 3,
    this.tags = const [],
  });

  String get moodEmoji {
    switch (mood) {
      case Mood.amazing:
        return '🤩';
      case Mood.good:
        return '😊';
      case Mood.okay:
        return '😐';
      case Mood.bad:
        return '😔';
      case Mood.terrible:
        return '😢';
    }
  }

  String get moodText {
    switch (mood) {
      case Mood.amazing:
        return 'Amazing';
      case Mood.good:
        return 'Good';
      case Mood.okay:
        return 'Okay';
      case Mood.bad:
        return 'Bad';
      case Mood.terrible:
        return 'Terrible';
    }
  }

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    Mood? mood,
    String? reflection,
    List<String>? gratitude,
    List<String>? accomplishments,
    List<String>? challenges,
    String? tomorrowGoal,
    int? energyLevel,
    int? productivityLevel,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      reflection: reflection ?? this.reflection,
      gratitude: gratitude ?? this.gratitude,
      accomplishments: accomplishments ?? this.accomplishments,
      challenges: challenges ?? this.challenges,
      tomorrowGoal: tomorrowGoal ?? this.tomorrowGoal,
      energyLevel: energyLevel ?? this.energyLevel,
      productivityLevel: productivityLevel ?? this.productivityLevel,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood.index,
      'reflection': reflection,
      'gratitude': gratitude,
      'accomplishments': accomplishments,
      'challenges': challenges,
      'tomorrowGoal': tomorrowGoal,
      'energyLevel': energyLevel,
      'productivityLevel': productivityLevel,
      'tags': tags,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      mood: Mood.values[json['mood']],
      reflection: json['reflection'],
      gratitude: List<String>.from(json['gratitude'] ?? []),
      accomplishments: List<String>.from(json['accomplishments'] ?? []),
      challenges: List<String>.from(json['challenges'] ?? []),
      tomorrowGoal: json['tomorrowGoal'],
      energyLevel: json['energyLevel'] ?? 3,
      productivityLevel: json['productivityLevel'] ?? 3,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
