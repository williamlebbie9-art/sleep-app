import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class SleepAIService {
  static Future<void> analyzeSleepPatterns() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt('streak') ?? 0;
    final aiEnabled = prefs.getBool('ai_recommendations_enabled') ?? false;

    if (!aiEnabled) return;

    // Get historical sleep data
    final sleepTimes = _getSleepHistory(prefs);

    if (sleepTimes.isEmpty) {
      // No data yet, suggest based on best practices
      await _scheduleDefaultRecommendation();
      return;
    }

    // Analyze patterns
    final avgBedtime = _calculateAverageBedtime(sleepTimes);
    final consistency = _calculateConsistency(sleepTimes);
    final recommendation = _generateRecommendation(
      avgBedtime,
      consistency,
      streak,
    );

    // Schedule AI notification
    await NotificationService().scheduleAIRecommendation(
      avgBedtime.hour,
      avgBedtime.minute,
      recommendation,
    );
  }

  static List<DateTime> _getSleepHistory(SharedPreferences prefs) {
    final sleepTimes = <DateTime>[];
    for (var i = 0; i < 7; i++) {
      final key = 'sleep_time_$i';
      final millis = prefs.getInt(key);
      if (millis != null) {
        sleepTimes.add(DateTime.fromMillisecondsSinceEpoch(millis));
      }
    }
    return sleepTimes;
  }

  static DateTime _calculateAverageBedtime(List<DateTime> times) {
    if (times.isEmpty) {
      return DateTime.now().copyWith(hour: 22, minute: 0);
    }

    var totalMinutes = 0;
    for (var time in times) {
      totalMinutes += time.hour * 60 + time.minute;
    }
    final avgMinutes = totalMinutes ~/ times.length;
    final hour = avgMinutes ~/ 60;
    final minute = avgMinutes % 60;

    return DateTime.now().copyWith(hour: hour, minute: minute);
  }

  static double _calculateConsistency(List<DateTime> times) {
    if (times.length < 2) return 1.0;

    final differences = <int>[];
    for (var i = 1; i < times.length; i++) {
      final diff =
          (times[i].hour * 60 + times[i].minute) -
          (times[i - 1].hour * 60 + times[i - 1].minute);
      differences.add(diff.abs());
    }

    final avgDiff = differences.reduce((a, b) => a + b) / differences.length;
    // Higher consistency = lower difference (scale 0-1)
    return (120 - avgDiff.clamp(0, 120)) / 120;
  }

  static String _generateRecommendation(
    DateTime avgBedtime,
    double consistency,
    int streak,
  ) {
    if (consistency > 0.8 && streak > 5) {
      return 'You\'re on a ${streak}-night streak! Time to lock in another great night.';
    } else if (consistency > 0.6) {
      return 'You usually sleep around ${_formatTime(avgBedtime)}. Ready to activate Sleep Lock?';
    } else {
      return 'Building consistency helps sleep quality. Activate Sleep Lock now?';
    }
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  static Future<void> _scheduleDefaultRecommendation() async {
    await NotificationService().scheduleAIRecommendation(
      22,
      0,
      'Most people sleep better when they go to bed around 10 PM. Ready to start?',
    );
  }

  static Future<void> recordSleepTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();

    // Shift existing times down
    for (var i = 6; i >= 1; i--) {
      final oldKey = 'sleep_time_${i - 1}';
      final newKey = 'sleep_time_$i';
      final value = prefs.getInt(oldKey);
      if (value != null) {
        await prefs.setInt(newKey, value);
      }
    }

    // Save new time at position 0
    await prefs.setInt('sleep_time_0', time.millisecondsSinceEpoch);

    // Re-analyze patterns with new data
    await analyzeSleepPatterns();
  }

  static Future<void> enableAI(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_recommendations_enabled', enabled);

    if (enabled) {
      await analyzeSleepPatterns();
    }
  }
}
