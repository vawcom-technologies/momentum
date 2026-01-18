import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class ActivityMonitorService {
  static final ActivityMonitorService _instance = ActivityMonitorService._internal();
  factory ActivityMonitorService() => _instance;
  ActivityMonitorService._internal();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _inactivityTimer;
  Timer? _checkTimer;

  // Movement tracking
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  DateTime _lastMovementTime = DateTime.now();
  DateTime _lastNudgeTime = DateTime.now().subtract(const Duration(hours: 1));

  // Settings
  int _inactivityThresholdMinutes = 30; // Nudge after 30 min of inactivity
  int _nudgeCooldownMinutes = 15; // Don't nudge more than once per 15 min
  double _movementThreshold = 0.5; // Minimum movement to count as activity
  bool _isEnabled = true;
  bool _isMonitoring = false;

  // Preferences keys
  static const String _enabledKey = 'activity_monitor_enabled';
  static const String _thresholdKey = 'inactivity_threshold_minutes';
  static const String _cooldownKey = 'nudge_cooldown_minutes';

  Future<void> initialize() async {
    await _loadSettings();
    if (_isEnabled) {
      startMonitoring();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_enabledKey) ?? true;
    _inactivityThresholdMinutes = prefs.getInt(_thresholdKey) ?? 30;
    _nudgeCooldownMinutes = prefs.getInt(_cooldownKey) ?? 15;
  }

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    // Listen to accelerometer
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 500),
    ).listen(_onAccelerometerEvent);

    // Check for inactivity every minute
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkInactivity();
    });

    debugPrint('Activity monitoring started');
  }

  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _checkTimer?.cancel();
    _checkTimer = null;
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _isMonitoring = false;
    debugPrint('Activity monitoring stopped');
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Calculate movement delta
    final deltaX = (event.x - _lastX).abs();
    final deltaY = (event.y - _lastY).abs();
    final deltaZ = (event.z - _lastZ).abs();

    final totalMovement = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);

    // Update last values
    _lastX = event.x;
    _lastY = event.y;
    _lastZ = event.z;

    // If significant movement detected, update last movement time
    if (totalMovement > _movementThreshold) {
      _lastMovementTime = DateTime.now();
    }
  }

  void _checkInactivity() {
    if (!_isEnabled) return;

    // Check if we're in quiet hours
    final now = DateTime.now();
    final hour = now.hour;
    
    // Don't check between 10 PM and 8 AM (sleeping hours)
    if (hour >= 22 || hour < 8) return;

    final inactivityDuration = now.difference(_lastMovementTime);
    final timeSinceLastNudge = now.difference(_lastNudgeTime);

    // Check if inactive for too long and cooldown has passed
    if (inactivityDuration.inMinutes >= _inactivityThresholdMinutes &&
        timeSinceLastNudge.inMinutes >= _nudgeCooldownMinutes) {
      _sendInactivityNudge();
      _lastNudgeTime = now;
    }
  }

  Future<void> _sendInactivityNudge() async {
    final notificationService = NotificationService();
    await notificationService.showInactivityReminder();
    debugPrint('Inactivity nudge sent');
  }

  // ============ SETTINGS ============

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    if (enabled) {
      startMonitoring();
    } else {
      stopMonitoring();
    }
  }

  Future<void> setInactivityThreshold(int minutes) async {
    _inactivityThresholdMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_thresholdKey, minutes);
  }

  Future<void> setNudgeCooldown(int minutes) async {
    _nudgeCooldownMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cooldownKey, minutes);
  }

  // ============ STATUS ============

  bool get isEnabled => _isEnabled;
  bool get isMonitoring => _isMonitoring;
  
  Duration get inactivityDuration => DateTime.now().difference(_lastMovementTime);
  
  Map<String, dynamic> getStatus() {
    return {
      'isEnabled': _isEnabled,
      'isMonitoring': _isMonitoring,
      'inactivityMinutes': inactivityDuration.inMinutes,
      'thresholdMinutes': _inactivityThresholdMinutes,
      'cooldownMinutes': _nudgeCooldownMinutes,
      'lastMovement': _lastMovementTime.toIso8601String(),
      'lastNudge': _lastNudgeTime.toIso8601String(),
    };
  }

  void dispose() {
    stopMonitoring();
  }
}
