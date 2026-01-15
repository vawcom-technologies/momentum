import 'habit.dart';
import 'journal_entry.dart';
import 'focus_session.dart';
import 'music_session.dart';

class SleepEntry {
  final String id;
  final DateTime date;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int quality; // 1-5
  final List<String> factors; // caffeine, exercise, screen time, etc.
  final String? notes;

  SleepEntry({
    required this.id,
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    this.quality = 3,
    this.factors = const [],
    this.notes,
  });

  Duration get duration => wakeTime.difference(bedTime);
  
  double get hoursSlept => duration.inMinutes / 60;
  
  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  int get sleepScore {
    // Score based on duration and quality
    double durationScore = 0;
    if (hoursSlept >= 7 && hoursSlept <= 9) {
      durationScore = 100;
    } else if (hoursSlept >= 6 && hoursSlept < 7) {
      durationScore = 70;
    } else if (hoursSlept > 9 && hoursSlept <= 10) {
      durationScore = 80;
    } else {
      durationScore = 50;
    }
    
    return ((durationScore * 0.6) + (quality * 20 * 0.4)).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality,
      'factors': factors,
      'notes': notes,
    };
  }

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      bedTime: DateTime.parse(json['bedTime']),
      wakeTime: DateTime.parse(json['wakeTime']),
      quality: json['quality'] ?? 3,
      factors: List<String>.from(json['factors'] ?? []),
      notes: json['notes'],
    );
  }
}

class WaterIntake {
  final String date;
  final int glasses;
  final int target;
  final List<DateTime> timestamps;

  WaterIntake({
    required this.date,
    this.glasses = 0,
    this.target = 8,
    this.timestamps = const [],
  });

  double get progress => (glasses / target).clamp(0.0, 1.0);
  
  bool get isComplete => glasses >= target;

  WaterIntake copyWith({
    String? date,
    int? glasses,
    int? target,
    List<DateTime>? timestamps,
  }) {
    return WaterIntake(
      date: date ?? this.date,
      glasses: glasses ?? this.glasses,
      target: target ?? this.target,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'glasses': glasses,
      'target': target,
      'timestamps': timestamps.map((t) => t.toIso8601String()).toList(),
    };
  }

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      date: json['date'],
      glasses: json['glasses'] ?? 0,
      target: json['target'] ?? 8,
      timestamps: (json['timestamps'] as List?)
              ?.map((t) => DateTime.parse(t))
              .toList() ??
          [],
    );
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime createdAt;
  final DateTime? targetDate;
  final List<Milestone> milestones;
  final bool isCompleted;
  final DateTime? completedAt;
  final String category;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.createdAt,
    this.targetDate,
    this.milestones = const [],
    this.isCompleted = false,
    this.completedAt,
    this.category = 'General',
  });

  double get progress {
    if (milestones.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = milestones.where((m) => m.isCompleted).length;
    return completed / milestones.length;
  }

  int get daysRemaining {
    if (targetDate == null) return -1;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    DateTime? createdAt,
    DateTime? targetDate,
    List<Milestone>? milestones,
    bool? isCompleted,
    DateTime? completedAt,
    String? category,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      milestones: milestones ?? this.milestones,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'category': category,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      milestones: (json['milestones'] as List?)
              ?.map((m) => Milestone.fromJson(m))
              .toList() ??
          [],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      category: json['category'] ?? 'General',
    );
  }
}

class Milestone {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;

  Milestone({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  Milestone copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }
}

class QuickNote {
  final String id;
  final String content;
  final DateTime createdAt;
  final String? category;
  final bool isPinned;
  final String color;

  QuickNote({
    required this.id,
    required this.content,
    required this.createdAt,
    this.category,
    this.isPinned = false,
    this.color = '#8B5CF6',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'isPinned': isPinned,
      'color': color,
    };
  }

  factory QuickNote.fromJson(Map<String, dynamic> json) {
    return QuickNote(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'],
      isPinned: json['isPinned'] ?? false,
      color: json['color'] ?? '#8B5CF6',
    );
  }
}

class LifeData {
  final List<Habit> habits;
  final List<JournalEntry> journalEntries;
  final List<FocusSession> focusSessions;
  final List<SleepEntry> sleepEntries;
  final Map<String, WaterIntake> waterIntake;
  final List<Goal> goals;
  final List<QuickNote> notes;
  final int totalFocusMinutes;
  final int totalMeditationMinutes;
  final List<MusicSession> musicSessions;
  final int totalMusicMinutes;

  LifeData({
    this.habits = const [],
    this.journalEntries = const [],
    this.focusSessions = const [],
    this.sleepEntries = const [],
    this.waterIntake = const {},
    this.goals = const [],
    this.notes = const [],
    this.totalFocusMinutes = 0,
    this.totalMeditationMinutes = 0,
    this.musicSessions = const [],
    this.totalMusicMinutes = 0,
  });

  LifeData copyWith({
    List<Habit>? habits,
    List<JournalEntry>? journalEntries,
    List<FocusSession>? focusSessions,
    List<SleepEntry>? sleepEntries,
    Map<String, WaterIntake>? waterIntake,
    List<Goal>? goals,
    List<QuickNote>? notes,
    int? totalFocusMinutes,
    int? totalMeditationMinutes,
    List<MusicSession>? musicSessions,
    int? totalMusicMinutes,
  }) {
    return LifeData(
      habits: habits ?? this.habits,
      journalEntries: journalEntries ?? this.journalEntries,
      focusSessions: focusSessions ?? this.focusSessions,
      sleepEntries: sleepEntries ?? this.sleepEntries,
      waterIntake: waterIntake ?? this.waterIntake,
      goals: goals ?? this.goals,
      notes: notes ?? this.notes,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      totalMeditationMinutes: totalMeditationMinutes ?? this.totalMeditationMinutes,
      musicSessions: musicSessions ?? this.musicSessions,
      totalMusicMinutes: totalMusicMinutes ?? this.totalMusicMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habits': habits.map((h) => h.toJson()).toList(),
      'journalEntries': journalEntries.map((j) => j.toJson()).toList(),
      'focusSessions': focusSessions.map((f) => f.toJson()).toList(),
      'sleepEntries': sleepEntries.map((s) => s.toJson()).toList(),
      'waterIntake': waterIntake.map((k, v) => MapEntry(k, v.toJson())),
      'goals': goals.map((g) => g.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'totalFocusMinutes': totalFocusMinutes,
      'totalMeditationMinutes': totalMeditationMinutes,
      'musicSessions': musicSessions.map((m) => m.toJson()).toList(),
      'totalMusicMinutes': totalMusicMinutes,
    };
  }

  factory LifeData.fromJson(Map<String, dynamic> json) {
    return LifeData(
      habits: (json['habits'] as List?)?.map((h) => Habit.fromJson(h)).toList() ?? [],
      journalEntries: (json['journalEntries'] as List?)?.map((j) => JournalEntry.fromJson(j)).toList() ?? [],
      focusSessions: (json['focusSessions'] as List?)?.map((f) => FocusSession.fromJson(f)).toList() ?? [],
      sleepEntries: (json['sleepEntries'] as List?)?.map((s) => SleepEntry.fromJson(s)).toList() ?? [],
      waterIntake: (json['waterIntake'] as Map?)?.map((k, v) => MapEntry(k as String, WaterIntake.fromJson(v))) ?? {},
      goals: (json['goals'] as List?)?.map((g) => Goal.fromJson(g)).toList() ?? [],
      notes: (json['notes'] as List?)?.map((n) => QuickNote.fromJson(n)).toList() ?? [],
      totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
      totalMeditationMinutes: json['totalMeditationMinutes'] ?? 0,
      musicSessions: (json['musicSessions'] as List?)?.map((m) => MusicSession.fromJson(m)).toList() ?? [],
      totalMusicMinutes: json['totalMusicMinutes'] ?? 0,
    );
  }
}
