import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/life_data.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/music_session.dart';
import '../services/music_service.dart';

class LifeProvider with ChangeNotifier {
  LifeData _lifeData = LifeData();
  bool _isLoading = true;

  LifeData get lifeData => _lifeData;
  bool get isLoading => _isLoading;

  // Getters for quick access
  List<Habit> get habits => _lifeData.habits;
  List<JournalEntry> get journalEntries => _lifeData.journalEntries;
  List<Goal> get goals => _lifeData.goals;
  List<QuickNote> get notes => _lifeData.notes;

  WaterIntake get todayWater {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _lifeData.waterIntake[today] ?? WaterIntake(date: today);
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString('life_data');

    if (dataJson != null) {
      _lifeData = LifeData.fromJson(json.decode(dataJson));
    } else {
      // Initialize with default habits
      _lifeData = LifeData(
        habits: Habit.defaultHabits(),
      );
      await _save();
    }

    // Initialize music service and setup automatic tracking
    _musicService.initialize();
    _setupAutoMusicTracking();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('life_data', json.encode(_lifeData.toJson()));
  }

  // ============ HABITS ============
  
  Future<void> addHabit(Habit habit) async {
    final newHabits = List<Habit>.from(_lifeData.habits)..add(habit);
    _lifeData = _lifeData.copyWith(habits: newHabits);
    await _save();
    notifyListeners();
  }

  Future<void> completeHabit(String habitId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final habits = _lifeData.habits.map((h) {
      if (h.id == habitId) {
        final newCompletions = Map<String, int>.from(h.completions);
        newCompletions[today] = (newCompletions[today] ?? 0) + 1;
        
        // Update streak
        int newStreak = h.currentStreak;
        if (newCompletions[today] == h.targetCount) {
          newStreak++;
        }
        final newLongest = newStreak > h.longestStreak ? newStreak : h.longestStreak;
        
        return h.copyWith(
          completions: newCompletions,
          currentStreak: newStreak,
          longestStreak: newLongest,
        );
      }
      return h;
    }).toList();

    _lifeData = _lifeData.copyWith(habits: habits);
    await _save();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Future<void> deleteHabit(String habitId) async {
    final habits = _lifeData.habits.where((h) => h.id != habitId).toList();
    _lifeData = _lifeData.copyWith(habits: habits);
    await _save();
    notifyListeners();
  }

  // ============ WATER TRACKING ============

  Future<void> addWater() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final currentWater = _lifeData.waterIntake[today] ?? WaterIntake(date: today);
    
    final newTimestamps = List<DateTime>.from(currentWater.timestamps)
      ..add(DateTime.now());
    
    final updatedWater = currentWater.copyWith(
      glasses: currentWater.glasses + 1,
      timestamps: newTimestamps,
    );
    
    final newWaterIntake = Map<String, WaterIntake>.from(_lifeData.waterIntake);
    newWaterIntake[today] = updatedWater;
    
    _lifeData = _lifeData.copyWith(waterIntake: newWaterIntake);
    await _save();
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  Future<void> removeWater() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final currentWater = _lifeData.waterIntake[today];
    if (currentWater == null || currentWater.glasses <= 0) return;
    
    final newTimestamps = List<DateTime>.from(currentWater.timestamps);
    if (newTimestamps.isNotEmpty) newTimestamps.removeLast();
    
    final updatedWater = currentWater.copyWith(
      glasses: currentWater.glasses - 1,
      timestamps: newTimestamps,
    );
    
    final newWaterIntake = Map<String, WaterIntake>.from(_lifeData.waterIntake);
    newWaterIntake[today] = updatedWater;
    
    _lifeData = _lifeData.copyWith(waterIntake: newWaterIntake);
    await _save();
    notifyListeners();
  }

  // ============ JOURNAL ============

  Future<void> addJournalEntry(JournalEntry entry) async {
    final entries = List<JournalEntry>.from(_lifeData.journalEntries)..add(entry);
    _lifeData = _lifeData.copyWith(journalEntries: entries);
    await _save();
    notifyListeners();
  }

  JournalEntry? getTodayJournal() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      return _lifeData.journalEntries.firstWhere(
        (e) => e.date.toIso8601String().split('T')[0] == today,
      );
    } catch (e) {
      return null;
    }
  }

  // ============ FOCUS SESSIONS ============

  Future<void> completeFocusSession(int minutes) async {
    _lifeData = _lifeData.copyWith(
      totalFocusMinutes: _lifeData.totalFocusMinutes + minutes,
    );
    await _save();
    notifyListeners();
  }

  // ============ GOALS ============

  Future<void> addGoal(Goal goal) async {
    final goals = List<Goal>.from(_lifeData.goals)..add(goal);
    _lifeData = _lifeData.copyWith(goals: goals);
    await _save();
    notifyListeners();
  }

  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    final goals = _lifeData.goals.map((g) {
      if (g.id == goalId) {
        final milestones = g.milestones.map((m) {
          if (m.id == milestoneId) {
            return m.copyWith(
              isCompleted: !m.isCompleted,
              completedAt: !m.isCompleted ? DateTime.now() : null,
            );
          }
          return m;
        }).toList();
        
        // Check if all milestones completed
        final allCompleted = milestones.every((m) => m.isCompleted);
        
        return g.copyWith(
          milestones: milestones,
          isCompleted: allCompleted,
          completedAt: allCompleted ? DateTime.now() : null,
        );
      }
      return g;
    }).toList();

    _lifeData = _lifeData.copyWith(goals: goals);
    await _save();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Future<void> deleteGoal(String goalId) async {
    final goals = _lifeData.goals.where((g) => g.id != goalId).toList();
    _lifeData = _lifeData.copyWith(goals: goals);
    await _save();
    notifyListeners();
  }

  // ============ NOTES ============

  Future<void> addNote(QuickNote note) async {
    final notes = List<QuickNote>.from(_lifeData.notes)..insert(0, note);
    _lifeData = _lifeData.copyWith(notes: notes);
    await _save();
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    final notes = _lifeData.notes.where((n) => n.id != noteId).toList();
    _lifeData = _lifeData.copyWith(notes: notes);
    await _save();
    notifyListeners();
  }

  // ============ SLEEP ============

  Future<void> addSleepEntry(SleepEntry entry) async {
    final entries = List<SleepEntry>.from(_lifeData.sleepEntries)..add(entry);
    _lifeData = _lifeData.copyWith(sleepEntries: entries);
    await _save();
    notifyListeners();
  }

  SleepEntry? getLastSleepEntry() {
    if (_lifeData.sleepEntries.isEmpty) return null;
    return _lifeData.sleepEntries.last;
  }

  double getAverageSleepHours(int days) {
    if (_lifeData.sleepEntries.isEmpty) return 0;
    final recent = _lifeData.sleepEntries.take(days).toList();
    final total = recent.fold<double>(0, (sum, e) => sum + e.hoursSlept);
    return total / recent.length;
  }

  // ============ MEDITATION ============

  Future<void> completeMeditation(int minutes) async {
    _lifeData = _lifeData.copyWith(
      totalMeditationMinutes: _lifeData.totalMeditationMinutes + minutes,
    );
    await _save();
    notifyListeners();
  }

  // ============ MUSIC TRACKING ============

  final MusicService _musicService = MusicService();
  MusicSession? _lastAutoSession;
  Timer? _autoTrackingTimer;

  void _setupAutoMusicTracking() {
    _autoTrackingTimer?.cancel();
    // Check for completed sessions periodically (when audio stops)
    _autoTrackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentSession = _musicService.currentSession;
      
      // If session ended but not saved yet
      if (_lastAutoSession != null && 
          _lastAutoSession!.endedAt != null &&
          currentSession == null) {
        // Session was completed, save it
        addMusicSession(_lastAutoSession!);
        _lastAutoSession = null;
      }
      
      // Track current session
      if (currentSession != null && currentSession != _lastAutoSession) {
        _lastAutoSession = currentSession;
      }
    });
  }


  Future<void> addMusicSession(MusicSession session) async {
    final sessions = List<MusicSession>.from(_lifeData.musicSessions)..add(session);
    final totalMinutes = MusicService.getTotalMusicMinutes(sessions);
    
    _lifeData = _lifeData.copyWith(
      musicSessions: sessions,
      totalMusicMinutes: totalMinutes,
    );
    await _save();
    notifyListeners();
  }

  int getTodayMusicMinutes() {
    final today = DateTime.now();
    return MusicService.getDailyMusicMinutes(_lifeData.musicSessions, today);
  }

  int getWeeklyMusicMinutes() {
    return MusicService.getWeeklyMusicMinutes(_lifeData.musicSessions);
  }

  int getTotalMusicMinutes() {
    return _lifeData.totalMusicMinutes;
  }

  List<MusicSession> getMusicSessionsByDateRange(DateTime startDate, DateTime endDate) {
    return MusicService.getSessionsByDateRange(
      _lifeData.musicSessions,
      startDate,
      endDate,
    );
  }

  List<double> getDailyMusicDataForLastDays(int days) {
    return MusicService.getDailyMusicDataForLastDays(_lifeData.musicSessions, days);
  }

  MusicSession? getCurrentMusicSession() {
    return _musicService.currentSession;
  }

  bool get isMusicTracking => _musicService.isTracking;
}
