import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class StorageService {
  static const String _gameStateKey = 'game_state';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<void> saveGameState(GameState gameState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gameStateKey, jsonEncode(gameState.toJson()));
  }

  Future<GameState?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_gameStateKey);
    if (data == null) return null;
    try {
      return GameState.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }
}