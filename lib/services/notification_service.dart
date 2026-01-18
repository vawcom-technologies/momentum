import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int waterReminderId = 1000;
  static const int gymReminderId = 2000;
  static const int inactivityReminderId = 3000;
  static const int focusReminderId = 4000;

  // Preferences keys
  static const String _waterReminderEnabled = 'water_reminder_enabled';
  static const String _waterReminderInterval = 'water_reminder_interval';
  static const String _gymReminderEnabled = 'gym_reminder_enabled';
  static const String _gymReminderTime = 'gym_reminder_time';
  static const String _inactivityReminderEnabled = 'inactivity_reminder_enabled';
  static const String _focusReminderEnabled = 'focus_reminder_enabled';
  static const String _quietHoursStart = 'quiet_hours_start';
  static const String _quietHoursEnd = 'quiet_hours_end';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;

    // Request permissions
    await requestPermissions();

    // Load and apply saved preferences
    await _loadAndApplyPreferences();
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
    final payload = response.payload;
    if (payload != null) {
      // Handle different notification types
      debugPrint('Notification tapped with payload: $payload');
    }
  }

  Future<void> _loadAndApplyPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Water reminders
    final waterEnabled = prefs.getBool(_waterReminderEnabled) ?? true;
    final waterInterval = prefs.getInt(_waterReminderInterval) ?? 90; // minutes
    if (waterEnabled) {
      await scheduleWaterReminders(intervalMinutes: waterInterval);
    }

    // Gym reminders
    final gymEnabled = prefs.getBool(_gymReminderEnabled) ?? false;
    final gymTime = prefs.getString(_gymReminderTime);
    if (gymEnabled && gymTime != null) {
      final parts = gymTime.split(':');
      await scheduleGymReminder(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  // ============ WATER REMINDERS ============

  Future<void> scheduleWaterReminders({int intervalMinutes = 90}) async {
    // Cancel existing water reminders
    await cancelWaterReminders();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_waterReminderEnabled, true);
    await prefs.setInt(_waterReminderInterval, intervalMinutes);

    // Get quiet hours
    final quietStart = prefs.getInt(_quietHoursStart) ?? 22; // 10 PM
    final quietEnd = prefs.getInt(_quietHoursEnd) ?? 8; // 8 AM

    // Schedule recurring notifications during waking hours
    final now = DateTime.now();
    
    // Schedule for next 7 days
    for (int day = 0; day < 7; day++) {
      final baseDate = now.add(Duration(days: day));
      
      // Create reminders from quietEnd to quietStart
      int currentHour = day == 0 ? now.hour : quietEnd;
      if (currentHour < quietEnd) currentHour = quietEnd;

      while (currentHour < quietStart) {
        // Add some variation to minutes
        final minutes = (currentHour * 17) % 60; // Pseudo-random but consistent
        
        final scheduledTime = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          currentHour,
          minutes,
        );

        // Only schedule if it's in the future
        if (scheduledTime.isAfter(now)) {
          final uniqueId = waterReminderId + (day * 100) + currentHour;
          await _scheduleNotification(
            id: uniqueId,
            title: '💧 Hydration Check',
            body: _getWaterReminderMessage(),
            scheduledTime: scheduledTime,
            payload: 'water_reminder',
          );
        }

        currentHour += (intervalMinutes / 60).ceil();
      }
    }
  }

  String _getWaterReminderMessage() {
    final messages = [
      'Time to drink some water! Stay hydrated 💪',
      'Have you had water recently? Your body needs it!',
      'Quick reminder: Grab a glass of water 🥤',
      'Hydration check! Drink up for better focus.',
      'Water break! Your brain is 75% water 🧠',
      'Stay on track - drink some water now!',
      'Thirsty? Even if not, drink some water!',
    ];
    return messages[DateTime.now().minute % messages.length];
  }

  Future<void> cancelWaterReminders() async {
    // Cancel a range of water reminder IDs
    for (int i = 0; i < 1000; i++) {
      await _notifications.cancel(waterReminderId + i);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_waterReminderEnabled, false);
  }

  // ============ GYM REMINDERS ============

  Future<void> scheduleGymReminder({
    required int hour,
    required int minute,
    List<int>? daysOfWeek, // 1=Mon, 7=Sun
  }) async {
    await cancelGymReminders();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gymReminderEnabled, true);
    await prefs.setString(_gymReminderTime, '$hour:$minute');

    final days = daysOfWeek ?? [1, 2, 3, 4, 5]; // Default: weekdays

    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
      final scheduledDate = DateTime.now().add(Duration(days: dayOffset));
      final weekday = scheduledDate.weekday;

      if (days.contains(weekday)) {
        final scheduledTime = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          hour,
          minute,
        );

        if (scheduledTime.isAfter(DateTime.now())) {
          final uniqueId = gymReminderId + dayOffset;
          await _scheduleNotification(
            id: uniqueId,
            title: '🏋️ Gym Time!',
            body: _getGymReminderMessage(),
            scheduledTime: scheduledTime,
            payload: 'gym_reminder',
          );
        }
      }
    }
  }

  String _getGymReminderMessage() {
    final messages = [
      'Time to hit the gym! Your future self will thank you.',
      'Workout time! Let\'s get those gains 💪',
      'Ready to crush it at the gym?',
      'Your gym session awaits! No excuses!',
      'Time to move! Every workout counts.',
      'Gym o\'clock! Show up and level up!',
    ];
    return messages[DateTime.now().minute % messages.length];
  }

  Future<void> cancelGymReminders() async {
    for (int i = 0; i < 100; i++) {
      await _notifications.cancel(gymReminderId + i);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gymReminderEnabled, false);
  }

  // ============ INACTIVITY REMINDERS ============

  Future<void> showInactivityReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_inactivityReminderEnabled) ?? true;
    if (!enabled) return;

    // Check quiet hours
    final quietStart = prefs.getInt(_quietHoursStart) ?? 22;
    final quietEnd = prefs.getInt(_quietHoursEnd) ?? 8;
    final currentHour = DateTime.now().hour;

    if (currentHour >= quietStart || currentHour < quietEnd) return;

    await _showNotification(
      id: inactivityReminderId,
      title: '🛋️ Hey, you awake?',
      body: _getInactivityMessage(),
      payload: 'inactivity_reminder',
    );
  }

  String _getInactivityMessage() {
    final messages = [
      'Looks like you\'ve been still for a while. Time to move!',
      'Still in bed? Your goals aren\'t going to achieve themselves!',
      'Detected inactivity. Get up and do something productive!',
      'Screen time without movement? Take a walk or stretch!',
      'Your body needs movement. Stand up and stretch!',
      'Are you scrolling in bed? Time to get moving!',
      'Inactivity detected. Remember your goals!',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  Future<void> setInactivityRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_inactivityReminderEnabled, enabled);
  }

  // ============ FOCUS REMINDERS ============

  Future<void> scheduleFocusReminder({
    required int hour,
    required int minute,
    required String taskName,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      id: focusReminderId,
      title: '🎯 Focus Time',
      body: 'Time for: $taskName. Let\'s do this!',
      scheduledTime: scheduledTime,
      payload: 'focus_reminder',
    );
  }

  // ============ QUICK NUDGES ============

  Future<void> showQuickNudge(String title, String message) async {
    await _showNotification(
      id: DateTime.now().millisecond,
      title: title,
      body: message,
      payload: 'quick_nudge',
    );
  }

  Future<void> showProductivityNudge() async {
    final messages = [
      ('📱 Phone Check', 'You\'ve been on your phone for a while. Take a break!'),
      ('🎯 Stay Focused', 'Are you working on your goals right now?'),
      ('⏰ Time Check', 'Make sure you\'re spending time on what matters!'),
      ('💪 Get Moving', 'Stand up, stretch, and refocus!'),
    ];
    final selected = messages[DateTime.now().second % messages.length];
    await showQuickNudge(selected.$1, selected.$2);
  }

  // ============ SETTINGS ============

  Future<void> setQuietHours(int startHour, int endHour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_quietHoursStart, startHour);
    await prefs.setInt(_quietHoursEnd, endHour);
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'waterReminderEnabled': prefs.getBool(_waterReminderEnabled) ?? true,
      'waterReminderInterval': prefs.getInt(_waterReminderInterval) ?? 90,
      'gymReminderEnabled': prefs.getBool(_gymReminderEnabled) ?? false,
      'gymReminderTime': prefs.getString(_gymReminderTime),
      'inactivityReminderEnabled': prefs.getBool(_inactivityReminderEnabled) ?? true,
      'focusReminderEnabled': prefs.getBool(_focusReminderEnabled) ?? true,
      'quietHoursStart': prefs.getInt(_quietHoursStart) ?? 22,
      'quietHoursEnd': prefs.getInt(_quietHoursEnd) ?? 8,
    };
  }

  // ============ CORE NOTIFICATION METHODS ============

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'momentum_channel',
      'Momentum Notifications',
      channelDescription: 'Notifications for productivity and health reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'momentum_scheduled_channel',
      'Scheduled Reminders',
      channelDescription: 'Scheduled notifications for reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
