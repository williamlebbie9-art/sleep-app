import 'package:shared_preferences/shared_preferences.dart';

class AIChatUsageManager {
  static const String _chatCountKey = 'ai_chat_month_count';
  static const String _chatMonthKey = 'ai_chat_month_reference';
  static const int maxFreeChats = 12;

  AIChatUsageManager._();
  static final AIChatUsageManager instance = AIChatUsageManager._();

  /// Returns the current month-year string used for tracking (e.g. "2026-06")
  String _getCurrentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Gets the number of AI chats used this month.
  Future<int> getChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMonth = prefs.getString(_chatMonthKey);
    final currentMonth = _getCurrentMonthKey();

    // Reset if month changed
    if (storedMonth != currentMonth) {
      await prefs.setString(_chatMonthKey, currentMonth);
      await prefs.setInt(_chatCountKey, 0);
      return 0;
    }

    return prefs.getInt(_chatCountKey) ?? 0;
  }

  /// Increments the chat count by 1.
  Future<void> incrementChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getChatCount();
    await prefs.setInt(_chatCountKey, currentCount + 1);
  }

  /// Returns true if the user can send a chat message (under the limit).
  Future<bool> canSendChat() async {
    final count = await getChatCount();
    return count < maxFreeChats;
  }

  /// Returns the number of remaining free chats this month.
  Future<int> getRemainingChats() async {
    final count = await getChatCount();
    return maxFreeChats - count;
  }
}
