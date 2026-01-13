enum QuestType {
  focus,
  health,
  discipline,
  side,
}

enum QuestStatus {
  pending,
  completed,
  missed,
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestStatus status;
  final int xpReward;
  final DateTime createdAt;
  final DateTime? completedAt;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = QuestStatus.pending,
    required this.xpReward,
    required this.createdAt,
    this.completedAt,
  });

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    QuestStatus? status,
    int? xpReward,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'xpReward': xpReward,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: QuestType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => QuestType.focus,
      ),
      status: QuestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => QuestStatus.pending,
      ),
      xpReward: json['xpReward'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}