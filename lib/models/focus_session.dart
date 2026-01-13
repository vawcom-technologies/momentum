enum FocusSessionType {
  pomodoro,
  custom,
  deepWork,
}

enum FocusSessionStatus {
  notStarted,
  running,
  paused,
  completed,
  cancelled,
}

class FocusSession {
  final String id;
  final FocusSessionType type;
  final FocusSessionStatus status;
  final int durationMinutes;
  final int breakMinutes;
  final int completedPomodoros;
  final int targetPomodoros;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? taskName;
  final int totalFocusMinutes;
  final List<String> distractions;

  FocusSession({
    required this.id,
    this.type = FocusSessionType.pomodoro,
    this.status = FocusSessionStatus.notStarted,
    this.durationMinutes = 25,
    this.breakMinutes = 5,
    this.completedPomodoros = 0,
    this.targetPomodoros = 4,
    this.startedAt,
    this.completedAt,
    this.taskName,
    this.totalFocusMinutes = 0,
    this.distractions = const [],
  });

  int get remainingPomodoros => targetPomodoros - completedPomodoros;
  
  double get progress => completedPomodoros / targetPomodoros;

  FocusSession copyWith({
    String? id,
    FocusSessionType? type,
    FocusSessionStatus? status,
    int? durationMinutes,
    int? breakMinutes,
    int? completedPomodoros,
    int? targetPomodoros,
    DateTime? startedAt,
    DateTime? completedAt,
    String? taskName,
    int? totalFocusMinutes,
    List<String>? distractions,
  }) {
    return FocusSession(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      targetPomodoros: targetPomodoros ?? this.targetPomodoros,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      taskName: taskName ?? this.taskName,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      distractions: distractions ?? this.distractions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'status': status.index,
      'durationMinutes': durationMinutes,
      'breakMinutes': breakMinutes,
      'completedPomodoros': completedPomodoros,
      'targetPomodoros': targetPomodoros,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'taskName': taskName,
      'totalFocusMinutes': totalFocusMinutes,
      'distractions': distractions,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'],
      type: FocusSessionType.values[json['type']],
      status: FocusSessionStatus.values[json['status']],
      durationMinutes: json['durationMinutes'] ?? 25,
      breakMinutes: json['breakMinutes'] ?? 5,
      completedPomodoros: json['completedPomodoros'] ?? 0,
      targetPomodoros: json['targetPomodoros'] ?? 4,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      taskName: json['taskName'],
      totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
      distractions: List<String>.from(json['distractions'] ?? []),
    );
  }
}
