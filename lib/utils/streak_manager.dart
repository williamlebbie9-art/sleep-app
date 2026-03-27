import 'package:shared_preferences/shared_preferences.dart';

import '../services/streak_progress_service.dart';

class StreakManager {
  static const _streakKey = 'sleep_streak';
  static const _legacyStreakKey = 'streak';
  static const _lastDateKey = 'last_lock_date';
  static const _recoveryDeadlineKey = 'streak_recovery_deadline';
  static const _recoveryBaseStreakKey = 'streak_recovery_base_streak';

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static int _readStreak(SharedPreferences prefs) {
    return prefs.getInt(_streakKey) ?? prefs.getInt(_legacyStreakKey) ?? 0;
  }

  static Future<void> _writeStreak(SharedPreferences prefs, int value) async {
    await prefs.setInt(_streakKey, value);
    await prefs.setInt(_legacyStreakKey, value);
  }

  static Future<void> _clearRecoveryState(SharedPreferences prefs) async {
    await prefs.remove(_recoveryDeadlineKey);
    await prefs.remove(_recoveryBaseStreakKey);
  }

  static Future<void> _applyRecoveryExpiryIfNeeded(
    SharedPreferences prefs,
  ) async {
    final lastDateString = prefs.getString(_lastDateKey);
    if (lastDateString == null) {
      await _clearRecoveryState(prefs);
      return;
    }

    final now = DateTime.now();
    final today = _dateOnly(now);
    final lastDate = _dateOnly(DateTime.parse(lastDateString));
    final diff = today.difference(lastDate).inDays;

    if (diff <= 1) {
      await _clearRecoveryState(prefs);
      return;
    }

    if (diff > 2) {
      await _writeStreak(prefs, 0);
      await _clearRecoveryState(prefs);
      return;
    }

    final existingDeadlineMs = prefs.getInt(_recoveryDeadlineKey);
    if (existingDeadlineMs == null) {
      final currentStreak = _readStreak(prefs);
      final deadline = now.add(const Duration(hours: 12));
      await prefs.setInt(_recoveryDeadlineKey, deadline.millisecondsSinceEpoch);
      await prefs.setInt(_recoveryBaseStreakKey, currentStreak);
      return;
    }

    final deadline = DateTime.fromMillisecondsSinceEpoch(existingDeadlineMs);
    if (now.isAfter(deadline)) {
      await _writeStreak(prefs, 0);
      await _clearRecoveryState(prefs);
    }
  }

  static Future<int> recordSleepLockActivation() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await _applyRecoveryExpiryIfNeeded(prefs);

    int streak = _readStreak(prefs);
    final recoveryDeadlineMs = prefs.getInt(_recoveryDeadlineKey);

    if (recoveryDeadlineMs != null) {
      final deadline = DateTime.fromMillisecondsSinceEpoch(recoveryDeadlineMs);
      if (!now.isAfter(deadline)) {
        final baseStreak = prefs.getInt(_recoveryBaseStreakKey) ?? streak;
        streak = baseStreak + 1;
        await _writeStreak(prefs, streak);
        await prefs.setString(_lastDateKey, now.toIso8601String());
        await _clearRecoveryState(prefs);
        await StreakProgressService.syncCurrentUserProgress(streak: streak);
        return streak;
      }
      await _writeStreak(prefs, 0);
      await _clearRecoveryState(prefs);
      await StreakProgressService.syncCurrentUserProgress(streak: 0);
      streak = 0;
    }

    final lastDateString = prefs.getString(_lastDateKey);
    if (lastDateString == null) {
      streak = 1;
    } else {
      final today = _dateOnly(now);
      final lastDate = _dateOnly(DateTime.parse(lastDateString));
      final diff = today.difference(lastDate).inDays;

      if (diff == 0) {
        await StreakProgressService.syncCurrentUserProgress(streak: streak);
        return streak;
      }
      if (diff == 1) {
        streak += 1;
      } else {
        streak = 1;
      }
    }

    await _writeStreak(prefs, streak);
    await prefs.setString(_lastDateKey, now.toIso8601String());
    await StreakProgressService.syncCurrentUserProgress(streak: streak);
    return streak;
  }

  static Future<Duration?> getRecoveryTimeRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    await _applyRecoveryExpiryIfNeeded(prefs);
    final deadlineMs = prefs.getInt(_recoveryDeadlineKey);
    if (deadlineMs == null) {
      return null;
    }
    final diff = DateTime.fromMillisecondsSinceEpoch(
      deadlineMs,
    ).difference(DateTime.now());
    if (diff.isNegative) {
      await _writeStreak(prefs, 0);
      await _clearRecoveryState(prefs);
      await StreakProgressService.syncCurrentUserProgress(streak: 0);
      return null;
    }
    return diff;
  }

  /// Call when a lock successfully completes
  static Future<int> completeNight() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastDateString = prefs.getString(_lastDateKey);

    int streak = _readStreak(prefs);

    if (lastDateString != null) {
      final lastDate = _dateOnly(DateTime.parse(lastDateString));
      final diff = _dateOnly(today).difference(lastDate).inDays;

      if (diff == 1) {
        streak += 1; // continue streak
      } else if (diff > 1) {
        streak = 1; // reset streak
      }
    } else {
      streak = 1; // first night
    }

    await _writeStreak(prefs, streak);
    await prefs.setString(_lastDateKey, today.toIso8601String());
    await _clearRecoveryState(prefs);
    await StreakProgressService.syncCurrentUserProgress(streak: streak);

    return streak;
  }

  /// Call when user emergency unlocks
  static Future<void> breakStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await _writeStreak(prefs, 0);
    await _clearRecoveryState(prefs);
    await StreakProgressService.syncCurrentUserProgress(streak: 0);
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await _applyRecoveryExpiryIfNeeded(prefs);
    return _readStreak(prefs);
  }
}
