enum MusicSource {
  spotify,
  appleMusic,
  youtube,
  other,
}

class MusicSession {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final String? artist;
  final String? album;
  final String? track;
  final MusicSource source;

  MusicSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes = 0,
    this.artist,
    this.album,
    this.track,
    this.source = MusicSource.other,
  });

  int get calculatedDurationMinutes {
    if (endedAt != null) {
      return endedAt!.difference(startedAt).inMinutes;
    }
    return durationMinutes;
  }

  double get durationHours => calculatedDurationMinutes / 60.0;

  String get durationText {
    final hours = calculatedDurationMinutes ~/ 60;
    final minutes = calculatedDurationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  bool get isActive => endedAt == null;

  String get dateKey => startedAt.toIso8601String().split('T')[0];

  MusicSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    String? artist,
    String? album,
    String? track,
    MusicSource? source,
  }) {
    return MusicSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      track: track ?? this.track,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'artist': artist,
      'album': album,
      'track': track,
      'source': source.index,
    };
  }

  factory MusicSession.fromJson(Map<String, dynamic> json) {
    return MusicSession(
      id: json['id'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      durationMinutes: json['durationMinutes'] ?? 0,
      artist: json['artist'],
      album: json['album'],
      track: json['track'],
      source: MusicSource.values[json['source'] ?? 3],
    );
  }
}
