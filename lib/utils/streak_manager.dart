import 'package:shared_preferences/shared_preferences.dart';

class StreakManager {
  static const _streakKey = 'sleep_streak';
  static const _lastDateKey = 'last_lock_date';

  /// Call when a lock successfully completes
  static Future<int> completeNight() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastDateString = prefs.getString(_lastDateKey);

    int streak = prefs.getInt(_streakKey) ?? 0;

    if (lastDateString != null) {
      final lastDate = DateTime.parse(lastDateString);
      final diff = today.difference(lastDate).inDays;

      if (diff == 1) {
        streak += 1; // continue streak
      } else if (diff > 1) {
        streak = 1; // reset streak
      }
    } else {
      streak = 1; // first night
    }

    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastDateKey, today.toIso8601String());

    return streak;
  }

  /// Call when user emergency unlocks
  static Future<void> breakStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, 0);
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }
}
