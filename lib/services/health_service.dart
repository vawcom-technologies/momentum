import 'package:health/health.dart';

class HealthService {
  static Health health = Health();
  static bool _permissionsGranted = false;

  // Request permissions for step tracking
  static Future<bool> requestPermissions() async {
    try {
      final types = [HealthDataType.STEPS];
      _permissionsGranted = await health.requestAuthorization(types);
      return _permissionsGranted;
    } catch (e) {
      print('Error requesting health permissions: $e');
      return false;
    }
  }

  // Check if permissions are granted
  static Future<bool> hasPermissions() async {
    try {
      final types = [HealthDataType.STEPS];
      final result = await health.hasPermissions(types, permissions: [
        HealthDataAccess.READ,
      ]);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get today's step count
  static Future<int> getTodaySteps() async {
    try {
      // Request permissions if not granted
      if (!_permissionsGranted) {
        final hasPerms = await hasPermissions();
        if (!hasPerms) {
          _permissionsGranted = await requestPermissions();
          if (!_permissionsGranted) {
            return 0;
          }
        } else {
          _permissionsGranted = true;
        }
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      // Configure health service
      await health.configure();

      // Get steps data for today
      final steps = await health.getHealthDataFromTypes(
        startTime: today,
        endTime: tomorrow,
        types: [HealthDataType.STEPS],
      );

      // Sum all step values for today
      int totalSteps = 0;
      for (var data in steps) {
        if (data.value is NumericHealthValue) {
          totalSteps += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }

      return totalSteps;
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }

  // Get steps for a specific date range
  static Future<int> getStepsForDateRange(DateTime start, DateTime end) async {
    try {
      if (!_permissionsGranted) {
        final hasPerms = await hasPermissions();
        if (!hasPerms) {
          return 0;
        }
        _permissionsGranted = true;
      }

      // Configure health service
      await health.configure();

      final steps = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.STEPS],
      );

      int totalSteps = 0;
      for (var data in steps) {
        if (data.value is NumericHealthValue) {
          totalSteps += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }

      return totalSteps;
    } catch (e) {
      print('Error getting steps for date range: $e');
      return 0;
    }
  }

  // Get steps for the last N days (for charts)
  static Future<List<int>> getStepsForLastDays(int days) async {
    final now = DateTime.now();
    final data = <int>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final steps = await getStepsForDateRange(dayStart, dayEnd);
      data.add(steps);
    }

    return data;
  }
}
