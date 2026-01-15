import 'dart:async';
import 'package:flutter/services.dart';
import '../models/music_session.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  MusicSession? _currentSession;
  EventChannel? _eventChannel;
  StreamSubscription<dynamic>? _eventSubscription;
  DateTime? _startTime;
  Duration _totalDuration = Duration.zero;

  MusicSession? get currentSession => _currentSession;

  bool get isTracking => _currentSession != null;
  
  Duration get totalDuration => _totalDuration;

  // Initialize platform channel listener
  void initialize() {
    _eventChannel = const EventChannel('com.momentum.audio/listening');
    _startListening();
  }

  // Start listening to native audio events
  void _startListening() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventChannel?.receiveBroadcastStream().listen(
      (event) {
        if (event == 'START') {
          _handleAudioStart();
        } else if (event == 'STOP') {
          _handleAudioStop();
        }
      },
      onError: (error) {
        print('Audio listening error: $error');
      },
    );
  }

  // Handle audio start event from native
  void _handleAudioStart() {
    if (_startTime == null) {
      _startTime = DateTime.now();
      
      // Create new session if none exists
      if (_currentSession == null) {
        _currentSession = MusicSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          startedAt: _startTime!,
          source: MusicSource.other,
        );
      }
    }
  }

  // Handle audio stop event from native
  void _handleAudioStop() {
    if (_startTime != null) {
      final endTime = DateTime.now();
      final sessionDuration = endTime.difference(_startTime!);
      _totalDuration += sessionDuration;
      
      // Update current session
      if (_currentSession != null) {
        _currentSession = _currentSession!.copyWith(
          endedAt: endTime,
          durationMinutes: sessionDuration.inMinutes,
        );
      }
      
      _startTime = null;
    }
  }

  // Get completed session (called when audio stops)
  MusicSession? getCompletedSession() {
    if (_currentSession == null || _currentSession!.endedAt == null) {
      return null;
    }
    final session = _currentSession;
    _currentSession = null;
    return session;
  }

  // Get current session duration in minutes
  int getCurrentSessionDuration() {
    if (_currentSession == null) return 0;
    return DateTime.now().difference(_currentSession!.startedAt).inMinutes;
  }

  // Calculate daily music minutes from a list of sessions
  static int getDailyMusicMinutes(List<MusicSession> sessions, DateTime date) {
    final dateKey = date.toIso8601String().split('T')[0];
    return sessions
        .where((s) => s.dateKey == dateKey)
        .fold<int>(0, (sum, session) => sum + session.calculatedDurationMinutes);
  }

  // Calculate weekly music minutes (last 7 days)
  static int getWeeklyMusicMinutes(List<MusicSession> sessions) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return sessions
        .where((s) => s.startedAt.isAfter(weekAgo) && s.startedAt.isBefore(now) || s.startedAt.isAtSameMomentAs(now))
        .fold<int>(0, (sum, session) => sum + session.calculatedDurationMinutes);
  }

  // Calculate total music minutes from all sessions
  static int getTotalMusicMinutes(List<MusicSession> sessions) {
    return sessions.fold<int>(0, (sum, session) => sum + session.calculatedDurationMinutes);
  }

  // Get sessions for a date range (for charts)
  static List<MusicSession> getSessionsByDateRange(
    List<MusicSession> sessions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return sessions.where((s) {
      return s.startedAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
          s.startedAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get daily music data for the last N days (for charts)
  static List<double> getDailyMusicDataForLastDays(
    List<MusicSession> sessions,
    int days,
  ) {
    final now = DateTime.now();
    final data = <double>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final minutes = getDailyMusicMinutes(sessions, date);
      data.add(minutes / 60.0); // Convert to hours
    }

    return data;
  }

  // Cleanup
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _currentSession = null;
    _startTime = null;
  }
}
