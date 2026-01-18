import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/game_state.dart';
import '../services/notification_service.dart';
import '../services/activity_monitor_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification settings
  bool _waterReminders = true;
  int _waterInterval = 90; // minutes
  bool _gymReminders = false;
  TimeOfDay _gymTime = const TimeOfDay(hour: 17, minute: 0);
  bool _inactivityAlerts = true;
  int _inactivityThreshold = 30; // minutes
  int _quietHoursStart = 22;
  int _quietHoursEnd = 8;
  
  // Legacy settings
  String _notificationStyle = 'Motivational';
  double _stepGoal = 10000;
  double _screenTimeLimit = 6;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final settings = await NotificationService().getSettings();
    final activityMonitor = ActivityMonitorService();
    
    setState(() {
      _waterReminders = settings['waterReminderEnabled'] ?? true;
      _waterInterval = settings['waterReminderInterval'] ?? 90;
      _gymReminders = settings['gymReminderEnabled'] ?? false;
      _inactivityAlerts = settings['inactivityReminderEnabled'] ?? true;
      _quietHoursStart = settings['quietHoursStart'] ?? 22;
      _quietHoursEnd = settings['quietHoursEnd'] ?? 8;
      _inactivityThreshold = activityMonitor.getStatus()['thresholdMinutes'] ?? 30;
      
      final gymTimeStr = settings['gymReminderTime'] as String?;
      if (gymTimeStr != null) {
        final parts = gymTimeStr.split(':');
        _gymTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final gameState = provider.gameState;
        if (gameState == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your experience',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 24),

                // Profile Section
                _buildProfileCard(gameState),
                const SizedBox(height: 16),

                // Notifications Section
                _buildNotificationsCard(),
                const SizedBox(height: 16),

                // Notification Style Section
                _buildNotificationStyleCard(),
                const SizedBox(height: 16),

                // Goals Section
                _buildGoalsCard(),
                const SizedBox(height: 16),

                // Appearance Section
                _buildAppearanceCard(),
                const SizedBox(height: 16),

                // Account Section
                _buildAccountCard(),
                const SizedBox(height: 16),

                // About Section
                _buildAboutCard(),

                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(GameState gameState) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final userName = user?.userMetadata?['name'] as String? ?? 
                        user?.email?.split('@').first ?? 
                        'Player';
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${gameState.level} • ${_getLevelTitle(gameState.level)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_outlined, size: 20, color: Colors.grey[800]),
              const SizedBox(width: 8),
              Text(
                'Smart Reminders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Water Reminders
          _buildSwitchTile(
            title: '💧 Water Reminders',
            subtitle: 'Every $_waterInterval min during waking hours',
            value: _waterReminders,
            onChanged: (value) async {
              setState(() => _waterReminders = value);
              if (value) {
                await NotificationService().scheduleWaterReminders(
                  intervalMinutes: _waterInterval,
                );
              } else {
                await NotificationService().cancelWaterReminders();
              }
            },
          ),
          if (_waterReminders) ...[
            const SizedBox(height: 12),
            _buildIntervalSelector(
              label: 'Reminder interval',
              value: _waterInterval,
              options: [60, 90, 120],
              optionLabels: ['1 hour', '1.5 hours', '2 hours'],
              onChanged: (value) async {
                setState(() => _waterInterval = value);
                await NotificationService().scheduleWaterReminders(
                  intervalMinutes: value,
                );
              },
            ),
          ],
          
          const Divider(height: 32),
          
          // Gym Reminders
          _buildSwitchTile(
            title: '🏋️ Gym Reminders',
            subtitle: _gymReminders 
                ? 'Daily at ${_gymTime.format(context)}'
                : 'Get reminded to workout',
            value: _gymReminders,
            onChanged: (value) async {
              setState(() => _gymReminders = value);
              if (value) {
                await NotificationService().scheduleGymReminder(
                  hour: _gymTime.hour,
                  minute: _gymTime.minute,
                );
              } else {
                await NotificationService().cancelGymReminders();
              }
            },
          ),
          if (_gymReminders) ...[
            const SizedBox(height: 12),
            _buildTimeSelector(
              label: 'Workout time',
              time: _gymTime,
              onChanged: (time) async {
                setState(() => _gymTime = time);
                await NotificationService().scheduleGymReminder(
                  hour: time.hour,
                  minute: time.minute,
                );
              },
            ),
          ],
          
          const Divider(height: 32),
          
          // Inactivity Alerts
          _buildSwitchTile(
            title: '🛋️ Inactivity Alerts',
            subtitle: 'Nudge when inactive for $_inactivityThreshold+ min',
            value: _inactivityAlerts,
            onChanged: (value) async {
              setState(() => _inactivityAlerts = value);
              await ActivityMonitorService().setEnabled(value);
              await NotificationService().setInactivityRemindersEnabled(value);
            },
          ),
          if (_inactivityAlerts) ...[
            const SizedBox(height: 12),
            _buildIntervalSelector(
              label: 'Alert after',
              value: _inactivityThreshold,
              options: [15, 30, 45, 60],
              optionLabels: ['15 min', '30 min', '45 min', '1 hour'],
              onChanged: (value) async {
                setState(() => _inactivityThreshold = value);
                await ActivityMonitorService().setInactivityThreshold(value);
              },
            ),
          ],
          
          const Divider(height: 32),
          
          // Quiet Hours
          _buildQuietHoursSelector(),
        ],
      ),
    );
  }

  Widget _buildIntervalSelector({
    required String label,
    required int value,
    required List<int> options,
    required List<String> optionLabels,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: value,
            underline: const SizedBox(),
            isDense: true,
            items: List.generate(options.length, (i) {
              return DropdownMenuItem(
                value: options[i],
                child: Text(optionLabels[i]),
              );
            }),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuietHoursSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bedtime, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              'Quiet Hours',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'No notifications during these hours',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHourSelector(
                label: 'Start',
                hour: _quietHoursStart,
                onChanged: (h) async {
                  setState(() => _quietHoursStart = h);
                  await NotificationService().setQuietHours(_quietHoursStart, _quietHoursEnd);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildHourSelector(
                label: 'End',
                hour: _quietHoursEnd,
                onChanged: (h) async {
                  setState(() => _quietHoursEnd = h);
                  await NotificationService().setQuietHours(_quietHoursStart, _quietHoursEnd);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHourSelector({
    required String label,
    required int hour,
    required ValueChanged<int> onChanged,
  }) {
    String formatHour(int h) {
      if (h == 0) return '12 AM';
      if (h == 12) return '12 PM';
      if (h < 12) return '$h AM';
      return '${h - 12} PM';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: hour,
            isExpanded: true,
            underline: const SizedBox(),
            isDense: true,
            items: List.generate(24, (h) {
              return DropdownMenuItem(
                value: h,
                child: Text(formatHour(h)),
              );
            }),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.purple[700],
        ),
      ],
    );
  }

  Widget _buildNotificationStyleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volume_up_outlined, size: 20, color: Colors.grey[800]),
              const SizedBox(width: 8),
              Text(
                'Notification Style',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStyleOption(
            title: 'Motivational',
            subtitle: 'Encouraging and positive messages',
            isSelected: _notificationStyle == 'Motivational',
            onTap: () => setState(() => _notificationStyle = 'Motivational'),
          ),
          const SizedBox(height: 8),
          _buildStyleOption(
            title: 'Savage',
            subtitle: 'Brutal honesty and tough love',
            isSelected: _notificationStyle == 'Savage',
            onTap: () => setState(() => _notificationStyle = 'Savage'),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, size: 20, color: Colors.grey[800]),
              const SizedBox(width: 8),
              Text(
                'Daily Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step Goal',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                '${_stepGoal.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} steps',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _stepGoal,
            min: 5000,
            max: 20000,
            divisions: 15,
            activeColor: Colors.purple[700],
            onChanged: (value) => setState(() => _stepGoal = value),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Screen Time Limit',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                '${_screenTimeLimit.round()} hours',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _screenTimeLimit,
            min: 2,
            max: 12,
            divisions: 10,
            activeColor: Colors.purple[700],
            onChanged: (value) => setState(() => _screenTimeLimit = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.dark_mode_outlined, size: 20, color: Colors.grey[800]),
                  const SizedBox(width: 8),
              Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle_outlined, size: 20, color: Colors.grey[800]),
              const SizedBox(width: 8),
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      await authProvider.signOut();
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              'Your Life as a Video Game',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level < 5) return 'NPC Mode';
    if (level < 10) return 'Grinding Era';
    if (level < 20) return 'Main Character';
    return 'Final Boss';
  }
}
