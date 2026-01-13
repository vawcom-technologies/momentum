import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';

class GameProvider with ChangeNotifier {
  final GameService _gameService = GameService();
  final StorageService _storageService = StorageService();

  GameState? _gameState;
  bool _isLoading = true;
  bool _onboardingCompleted = false;

  GameState? get gameState => _gameState;
  bool get isLoading => _isLoading;
  bool get onboardingCompleted => _onboardingCompleted;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _onboardingCompleted = await _storageService.isOnboardingCompleted();
    
    _gameState = await _storageService.loadGameState();
    
    if (_gameState == null) {
      _gameState = _gameService.createInitialState();
      await _storageService.saveGameState(_gameState!);
    } else {
      // Check if daily quests need to be reset
      final today = DateTime.now();
      final lastUpdated = _gameState!.lastUpdated;
      
      if (today.day != lastUpdated.day ||
          today.month != lastUpdated.month ||
          today.year != lastUpdated.year) {
        // New day - reset quests and apply decay
        _gameState = _gameService.applyStatDecay(_gameState!);
        _gameState = _gameState!.copyWith(
          dailyQuests: _gameService.generateDailyQuests(),
          stepsToday: 0,
          totalScreenTimeMinutes: 0,
          lastUpdated: today,
        );
        await _storageService.saveGameState(_gameState!);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    await _storageService.setOnboardingCompleted(true);
    notifyListeners();
  }

  Future<void> completeQuest(String questId) async {
    if (_gameState == null) return;
    
    _gameState = _gameService.completeQuest(_gameState!, questId);
    _gameState = _gameService.checkAchievements(_gameState!);
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    notifyListeners();
  }

  Future<void> updateScreenTime(int minutes) async {
    if (_gameState == null) return;
    
    _gameState = _gameService.updateScreenTime(_gameState!, minutes);
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    notifyListeners();
  }

  Future<void> updateSteps(int steps) async {
    if (_gameState == null) return;
    
    _gameState = _gameService.updateSteps(_gameState!, steps);
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    notifyListeners();
  }

  Future<void> addActionXp(int xp, {
    double? disciplineDelta,
    double? focusDelta,
    double? healthDelta,
    double? moneyDelta,
  }) async {
    if (_gameState == null) return;
    
    _gameState = _gameService.addXp(_gameState!, xp);
    _gameState = _gameService.updateStats(
      _gameState!,
      disciplineDelta: disciplineDelta,
      focusDelta: focusDelta,
      healthDelta: healthDelta,
      moneyDelta: moneyDelta,
    );
    _gameState = _gameService.checkAchievements(_gameState!);
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    notifyListeners();
  }
}