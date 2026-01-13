import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/quest.dart';
import '../models/boss_battle.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import '../widgets/spin_wheel.dart';

export '../models/quest.dart' show QuestStatus, QuestType;

class GameProvider with ChangeNotifier {
  final GameService _gameService = GameService();
  final StorageService _storageService = StorageService();

  GameState? _gameState;
  bool _isLoading = true;
  bool _onboardingCompleted = false;
  bool _showLevelUpOverlay = false;
  int _newLevel = 0;
  bool _showComboAnimation = false;
  bool _showAchievementUnlock = false;
  String _unlockedAchievementId = '';

  GameState? get gameState => _gameState;
  bool get isLoading => _isLoading;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get showLevelUpOverlay => _showLevelUpOverlay;
  int get newLevel => _newLevel;
  bool get showComboAnimation => _showComboAnimation;
  bool get showAchievementUnlock => _showAchievementUnlock;
  String get unlockedAchievementId => _unlockedAchievementId;

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
        
        // Check if all quests were completed yesterday for streak
        final allQuestsCompleted = _gameState!.dailyQuests
            .where((q) => q.type != QuestType.side)
            .every((q) => q.status == QuestStatus.completed);
        
        _gameState = _gameService.updateStreak(_gameState!, allQuestsCompleted);
        
        // New day - reset quests and apply decay
        _gameState = _gameService.applyStatDecay(_gameState!);
        _gameState = _gameService.cleanExpiredPowerUps(_gameState!);
        
        // Generate new boss if needed
        BossBattle? newBoss = _gameState!.currentBoss;
        if (newBoss == null || newBoss.isExpired) {
          newBoss = BossBattle.weeklyBoss();
        }
        
        _gameState = _gameState!.copyWith(
          dailyQuests: _gameService.generateDailyQuests(),
          stepsToday: 0,
          totalScreenTimeMinutes: 0,
          lastUpdated: today,
          combo: 0, // Reset combo on new day
          currentBoss: newBoss,
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
    
    final previousLevel = _gameState!.level;
    final previousCombo = _gameState!.combo;
    
    _gameState = _gameService.completeQuest(_gameState!, questId);
    
    // Check for achievements
    final previousAchievements = _gameState!.achievements.where((a) => a.unlocked).length;
    _gameState = _gameService.checkAchievements(_gameState!);
    final newAchievements = _gameState!.achievements.where((a) => a.unlocked).length;
    
    // Check for level up
    if (_gameState!.level > previousLevel) {
      _newLevel = _gameState!.level;
      _showLevelUpOverlay = true;
      HapticFeedback.heavyImpact();
    }
    
    // Check for combo
    if (_gameState!.combo > previousCombo && _gameState!.combo >= 3) {
      _showComboAnimation = true;
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(seconds: 2), () {
        _showComboAnimation = false;
        notifyListeners();
      });
    }
    
    // Check for new achievement
    if (newAchievements > previousAchievements) {
      final unlockedAchievement = _gameState!.achievements
          .firstWhere((a) => a.unlocked && a.unlockedAt != null &&
              DateTime.now().difference(a.unlockedAt!).inSeconds < 5);
      _unlockedAchievementId = unlockedAchievement.id;
      _showAchievementUnlock = true;
      HapticFeedback.heavyImpact();
    }
    
    // Check boss battle completion
    if (_gameState!.currentBoss?.isCompleted == true) {
      _gameState = _gameService.completeBossBattle(_gameState!);
    }
    
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    notifyListeners();
  }

  void dismissLevelUpOverlay() {
    _showLevelUpOverlay = false;
    notifyListeners();
  }

  void dismissAchievementUnlock() {
    _showAchievementUnlock = false;
    _unlockedAchievementId = '';
    notifyListeners();
  }

  Future<void> processDailySpin(SpinReward reward) async {
    if (_gameState == null) return;
    
    _gameState = _gameService.processSpin(
      _gameState!,
      reward.xp,
      isMultiplier: reward.isMultiplier,
      multiplier: reward.multiplier,
      isPowerUp: reward.isPowerUp,
    );
    
    _gameState = _gameService.checkAchievements(_gameState!);
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    notifyListeners();
  }

  Future<void> activatePowerUp(String powerUpId) async {
    if (_gameState == null) return;
    
    _gameState = _gameService.activatePowerUp(_gameState!, powerUpId);
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Future<void> startBossBattle() async {
    if (_gameState == null || _gameState!.currentBoss == null) return;
    
    _gameState = _gameService.startBossBattle(
      _gameState!, 
      _gameState!.currentBoss!,
    );
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    HapticFeedback.heavyImpact();
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
    
    final previousLevel = _gameState!.level;
    
    _gameState = _gameService.addXp(_gameState!, xp);
    _gameState = _gameService.updateStats(
      _gameState!,
      disciplineDelta: disciplineDelta,
      focusDelta: focusDelta,
      healthDelta: healthDelta,
      moneyDelta: moneyDelta,
    );
    _gameState = _gameService.checkAchievements(_gameState!);
    
    if (_gameState!.level > previousLevel) {
      _newLevel = _gameState!.level;
      _showLevelUpOverlay = true;
      HapticFeedback.heavyImpact();
    }
    
    _gameState = _gameState!.copyWith(lastUpdated: DateTime.now());
    
    await _storageService.saveGameState(_gameState!);
    notifyListeners();
  }

  Future<void> resetGame() async {
    _gameState = _gameService.createInitialState();
    await _storageService.saveGameState(_gameState!);
    notifyListeners();
  }
}
