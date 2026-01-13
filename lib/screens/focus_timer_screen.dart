import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/life_provider.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;

  Timer? _timer;
  int _totalSeconds = 25 * 60; // 25 minutes default
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedPomodoros = 0;

  final List<int> _presets = [15, 25, 45, 60]; // minutes
  int _selectedPreset = 25;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _pulseController.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
    });
    HapticFeedback.lightImpact();
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
      _isBreak = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _pulseController.stop();
    HapticFeedback.heavyImpact();

    if (!_isBreak) {
      // Focus session complete
      setState(() {
        _completedPomodoros++;
        _isRunning = false;
      });

      // Save focus time
      final provider = Provider.of<LifeProvider>(context, listen: false);
      provider.completeFocusSession(_selectedPreset);

      // Show completion and start break
      _showCompletionDialog();
    } else {
      // Break complete
      setState(() {
        _isBreak = false;
        _remainingSeconds = _totalSeconds;
        _isRunning = false;
      });
      _showBreakCompleteDialog();
    }
  }

  void _startBreak() {
    setState(() {
      _isBreak = true;
      _remainingSeconds = 5 * 60; // 5 minute break
      _totalSeconds = 5 * 60;
    });
    Navigator.pop(context);
    _startTimer();
  }

  void _selectPreset(int minutes) {
    if (!_isRunning) {
      setState(() {
        _selectedPreset = minutes;
        _totalSeconds = minutes * 60;
        _remainingSeconds = minutes * 60;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF22C55E).withOpacity(0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 64),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 16),
              const Text(
                'Focus Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+$_selectedPreset minutes of deep work',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pomodoros: $_completedPomodoros 🍅',
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startBreak,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Take Break'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBreakCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('☕', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Break Over!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready for another focus session?',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _totalSeconds = _selectedPreset * 60;
                    _remainingSeconds = _totalSeconds;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Let\'s Go!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isBreak ? '☕ Break Time' : '🎯 Focus Mode',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip('🍅', '$_completedPomodoros', 'Pomodoros'),
                  const SizedBox(width: 16),
                  Consumer<LifeProvider>(
                    builder: (context, provider, _) => _buildStatChip(
                      '⏱️',
                      '${provider.lifeData.totalFocusMinutes}',
                      'Total mins',
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),
              const Spacer(),
              // Timer Circle
              _buildTimerCircle(progress)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const Spacer(),
              // Preset buttons
              if (!_isRunning && !_isBreak)
                _buildPresetSelector()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms),
              const SizedBox(height: 24),
              // Control buttons
              _buildControlButtons()
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle(double progress) {
    final color = _isBreak ? const Color(0xFF3B82F6) : const Color(0xFFEF4444);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _isRunning ? (1 + _pulseController.value * 0.05) : 1.0;
        return Transform.scale(
          scale: pulse,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(_isRunning ? 0.3 : 0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Progress ring
                CustomPaint(
                  size: const Size(280, 280),
                  painter: TimerPainter(
                    progress: progress,
                    color: color,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isBreak ? '☕' : '🎯',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      _isBreak
                          ? 'Relax...'
                          : _isRunning
                              ? 'Stay focused!'
                              : 'Ready to focus?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPresetSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _presets.map((minutes) {
        final isSelected = minutes == _selectedPreset;
        return GestureDetector(
          onTap: () => _selectPreset(minutes),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEF4444)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFEF4444)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              '${minutes}m',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        GestureDetector(
          onTap: _resetTimer,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Play/Pause button
        GestureDetector(
          onTap: _isRunning ? _pauseTimer : _startTimer,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isBreak
                    ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
                    : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isBreak
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFEF4444))
                      .withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Skip button (during break)
        GestureDetector(
          onTap: _isBreak ? _resetTimer : null,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_isBreak ? 0.1 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.skip_next,
              color: _isBreak ? Colors.white : Colors.grey[700],
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  TimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
