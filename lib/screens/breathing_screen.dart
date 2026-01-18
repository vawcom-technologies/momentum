import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/life_provider.dart';

enum BreathingPhase {
  inhale,
  hold,
  exhale,
  rest,
}

class BreathingExercise {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int restSeconds;
  final int cycles;
  final Color color;

  const BreathingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.restSeconds,
    required this.cycles,
    required this.color,
  });

  int get totalCycleSeconds =>
      inhaleSeconds + holdSeconds + exhaleSeconds + restSeconds;
  int get totalMinutes => (totalCycleSeconds * cycles) ~/ 60;
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  Timer? _timer;
  bool _isRunning = false;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _phaseSecondsRemaining = 0;
  int _currentCycle = 0;

  final List<BreathingExercise> _exercises = const [
    BreathingExercise(
      id: 'box',
      name: 'Box Breathing',
      description: 'Navy SEAL technique for calm focus',
      icon: '📦',
      inhaleSeconds: 4,
      holdSeconds: 4,
      exhaleSeconds: 4,
      restSeconds: 4,
      cycles: 4,
      color: Color(0xFF3B82F6),
    ),
    BreathingExercise(
      id: '478',
      name: '4-7-8 Relaxation',
      description: 'Dr. Weil\'s relaxing breath',
      icon: '🌙',
      inhaleSeconds: 4,
      holdSeconds: 7,
      exhaleSeconds: 8,
      restSeconds: 0,
      cycles: 4,
      color: Color(0xFF8B5CF6),
    ),
    BreathingExercise(
      id: 'energize',
      name: 'Energizing Breath',
      description: 'Quick energy boost',
      icon: '⚡',
      inhaleSeconds: 2,
      holdSeconds: 0,
      exhaleSeconds: 2,
      restSeconds: 0,
      cycles: 10,
      color: Color(0xFFF59E0B),
    ),
    BreathingExercise(
      id: 'calm',
      name: 'Deep Calm',
      description: 'Long exhales for deep relaxation',
      icon: '🧘',
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 8,
      restSeconds: 2,
      cycles: 5,
      color: Color(0xFF22C55E),
    ),
  ];

  BreathingExercise _selectedExercise = const BreathingExercise(
    id: 'box',
    name: 'Box Breathing',
    description: 'Navy SEAL technique for calm focus',
    icon: '📦',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    restSeconds: 4,
    cycles: 4,
    color: Color(0xFF3B82F6),
  );

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isRunning = true;
      _currentCycle = 1;
      _currentPhase = BreathingPhase.inhale;
      _phaseSecondsRemaining = _selectedExercise.inhaleSeconds;
    });

    _breathController.duration =
        Duration(seconds: _selectedExercise.inhaleSeconds);
    _breathController.forward();

    HapticFeedback.mediumImpact();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phaseSecondsRemaining > 1) {
        setState(() {
          _phaseSecondsRemaining--;
        });
      } else {
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    HapticFeedback.lightImpact();

    switch (_currentPhase) {
      case BreathingPhase.inhale:
        if (_selectedExercise.holdSeconds > 0) {
          setState(() {
            _currentPhase = BreathingPhase.hold;
            _phaseSecondsRemaining = _selectedExercise.holdSeconds;
          });
          _breathController.stop();
        } else {
          _goToExhale();
        }
        break;
      case BreathingPhase.hold:
        _goToExhale();
        break;
      case BreathingPhase.exhale:
        if (_selectedExercise.restSeconds > 0) {
          setState(() {
            _currentPhase = BreathingPhase.rest;
            _phaseSecondsRemaining = _selectedExercise.restSeconds;
          });
        } else {
          _nextCycle();
        }
        break;
      case BreathingPhase.rest:
        _nextCycle();
        break;
    }
  }

  void _goToExhale() {
    setState(() {
      _currentPhase = BreathingPhase.exhale;
      _phaseSecondsRemaining = _selectedExercise.exhaleSeconds;
    });
    _breathController.duration =
        Duration(seconds: _selectedExercise.exhaleSeconds);
    _breathController.reverse();
  }

  void _nextCycle() {
    if (_currentCycle >= _selectedExercise.cycles) {
      _completeExercise();
    } else {
      setState(() {
        _currentCycle++;
        _currentPhase = BreathingPhase.inhale;
        _phaseSecondsRemaining = _selectedExercise.inhaleSeconds;
      });
      _breathController.duration =
          Duration(seconds: _selectedExercise.inhaleSeconds);
      _breathController.forward();
    }
  }

  void _completeExercise() {
    _timer?.cancel();
    _breathController.stop();
    
    final provider = Provider.of<LifeProvider>(context, listen: false);
    provider.completeMeditation(_selectedExercise.totalMinutes);

    setState(() {
      _isRunning = false;
    });

    HapticFeedback.heavyImpact();
    _showCompletionDialog();
  }

  void _stopExercise() {
    _timer?.cancel();
    _breathController.stop();
    setState(() {
      _isRunning = false;
      _currentCycle = 0;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🧘', style: TextStyle(fontSize: 64))
                  .animate()
                  .scale(curve: Curves.elasticOut),
              const SizedBox(height: 16),
              const Text(
                'Well Done!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedExercise.totalMinutes} minutes of mindfulness',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(
                'You feel calmer and more focused',
                style: TextStyle(
                  color: _selectedExercise.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedExercise.color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPhaseText() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Breathe In';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Breathe Out';
      case BreathingPhase.rest:
        return 'Rest';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '🌬️ Breathing',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
      body: SafeArea(
        child: _isRunning ? _buildExerciseView() : _buildSelectionView(),
      ),
    );
  }

  Widget _buildSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose an exercise',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 8),
          Text(
            'Take a moment to calm your mind',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ..._exercises.asMap().entries.map((entry) {
            final exercise = entry.value;
            final isSelected = exercise.id == _selectedExercise.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedExercise = exercise);
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1a1a2e),
                        exercise.color.withOpacity(isSelected ? 0.3 : 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? exercise.color
                          : exercise.color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: exercise.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            exercise.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildExerciseChip(
                                  '${exercise.cycles} cycles',
                                  exercise.color,
                                ),
                                const SizedBox(width: 8),
                                _buildExerciseChip(
                                  '~${exercise.totalMinutes} min',
                                  exercise.color,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: exercise.color,
                        ),
                    ],
                  ),
                ),
              ),
            ).animate(delay: Duration(milliseconds: 100 * entry.key)).fadeIn().slideX(begin: 0.1, end: 0);
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedExercise.color,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Breathing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildExerciseChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExerciseView() {
    return Column(
      children: [
        const Spacer(),
        // Cycle indicator
        Text(
          'Cycle $_currentCycle of ${_selectedExercise.cycles}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 32),
        // Breathing circle
        AnimatedBuilder(
          animation: _breathAnimation,
          builder: (context, child) {
            return Container(
              width: 250 * _breathAnimation.value,
              height: 250 * _breathAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _selectedExercise.color.withOpacity(0.3),
                    _selectedExercise.color.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: _selectedExercise.color,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _selectedExercise.color.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_phaseSecondsRemaining',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getPhaseText(),
                      style: TextStyle(
                        fontSize: 20,
                        color: _selectedExercise.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const Spacer(),
        // Stop button
        GestureDetector(
          onTap: _stopExercise,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Stop',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
