import 'package:cloud_firestore/cloud_firestore.dart';

class AISupportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get AI support response for user's question
  static Future<String> getResponse(String userMessage) async {
    // Store conversation for analytics
    await _logSupportQuery(userMessage);

    // Match common support questions
    final response = _getAIResponse(userMessage.toLowerCase());
    return response;
  }

  static String _getAIResponse(String message) {
    // Activation & Lock Issues
    if (message.contains('activate') ||
        message.contains('turn on') ||
        message.contains('start') && message.contains('lock')) {
      return "To activate Sleep Lock:\n\n"
          "1. Tap 'Activate Sleep Lock' on the home screen\n"
          "2. Choose your duration (3hr, 4hr, 6hr, or 8hr)\n"
          "3. Toggle sound on/off if desired\n"
          "4. Confirm to start the countdown\n\n"
          "The lock will automatically activate at the scheduled time. "
          "Make sure notifications are enabled!";
    }

    if (message.contains('not working') ||
        message.contains('doesn\'t work') ||
        message.contains('won\'t activate')) {
      return "If Sleep Lock isn't activating, try these steps:\n\n"
          "1. Check notification permissions: Settings → Apps → SleepLock → Notifications\n"
          "2. Disable battery optimization: Settings → Battery → SleepLock → Unrestricted\n"
          "3. Ensure location permissions are granted (required for some Android versions)\n"
          "4. Restart the app and try again\n\n"
          "Still having issues? Email us at support@sleeploock.com";
    }

    // Unlock & Payment
    if (message.contains('unlock') &&
        (message.contains('\$1') || message.contains('dollar'))) {
      return "The \$1 instant unlock feature lets you bypass Sleep Lock immediately:\n\n"
          "• While locked, tap 'Unlock Now for \$1'\n"
          "• Complete the payment via your app store\n"
          "• Lock will be removed instantly\n\n"
          "This is a one-time payment per unlock. Consider upgrading to Premium for unlimited flexibility!";
    }

    if (message.contains('unlock') && message.contains('instant')) {
      return "To unlock immediately:\n\n"
          "Option 1: Wait for the countdown to complete\n"
          "Option 2: Pay \$1 for instant unlock (tap the button on lock screen)\n"
          "Option 3: Wait 10 minutes after timer ends for free unlock\n\n"
          "Premium members can cancel locks anytime without waiting!";
    }

    // Premium & Subscription
    if (message.contains('premium') ||
        message.contains('subscription') ||
        message.contains('upgrade')) {
      return "Premium unlocks these amazing features:\n\n"
          "✨ All sleep stories & sounds\n"
          "🤖 Advanced AI sleep coaching\n"
          "🚫 No ads or interruptions\n"
          "⚡ Instant lock cancellation\n"
          "📊 Detailed sleep analytics\n\n"
          "To upgrade: Tap 'Upgrade to Premium' on the home screen or dashboard.";
    }

    if (message.contains('cancel') && message.contains('subscription')) {
      return "To cancel your Premium subscription:\n\n"
          "**Android:**\n"
          "1. Open Google Play Store\n"
          "2. Tap Menu → Subscriptions\n"
          "3. Select SleepLock → Cancel Subscription\n\n"
          "**iOS:**\n"
          "1. Open Settings → Your Name → Subscriptions\n"
          "2. Select SleepLock\n"
          "3. Tap Cancel Subscription\n\n"
          "You'll retain access until the end of your billing period.";
    }

    // Alarm & Sound Issues
    if (message.contains('alarm') ||
        message.contains('sound') && message.contains('not playing')) {
      return "If sounds or alarms aren't playing:\n\n"
          "1. Check your device volume is turned up\n"
          "2. Disable 'Do Not Disturb' mode\n"
          "3. Grant audio permissions: Settings → Apps → SleepLock → Permissions\n"
          "4. Enable background audio playback\n"
          "5. Try a different story or sound\n\n"
          "For meditation sounds, make sure you toggle 'Play Sound' when activating Sleep Lock.";
    }

    // Notifications
    if (message.contains('notification') || message.contains('reminder')) {
      return "Notification troubleshooting:\n\n"
          "**Enable Notifications:**\n"
          "Settings → Apps → SleepLock → Notifications → Allow all\n\n"
          "**Bedtime Reminders:**\n"
          "Tap 'Bedtime Reminders' on home screen to set custom notifications.\n\n"
          "**Battery Optimization:**\n"
          "Settings → Battery → SleepLock → Unrestricted (prevents notification delays)\n\n"
          "Still not working? Restart your device.";
    }

    // Stories
    if (message.contains('story') || message.contains('stories')) {
      return "Sleep stories help you drift off naturally:\n\n"
          "📖 Browse: Tap 'Browse Stories' on home screen\n"
          "🎧 Listen: Stories auto-play when Sleep Lock activates\n"
          "⭐ Premium: Unlock all stories with Premium subscription\n"
          "🔇 Last Story: We remember your last selection\n\n"
          "Pro tip: Combine stories with gentle sounds for the best experience!";
    }

    // AI Coach
    if (message.contains('ai') &&
        (message.contains('coach') || message.contains('advice'))) {
      return "The AI Sleep Coach provides personalized sleep insights:\n\n"
          "💬 Tap 'AI Sleep Adviser' to chat\n"
          "📊 Get tips based on your sleep patterns\n"
          "🎯 Receive custom recommendations\n"
          "📈 Track your progress over time\n\n"
          "Premium members get unlimited AI conversations and advanced analytics!";
    }

    // Streak & Progress
    if (message.contains('streak') ||
        message.contains('progress') ||
        message.contains('gallery')) {
      return "Track your sleep journey:\n\n"
          "🔥 Streak: Displayed on home screen (consecutive nights)\n"
          "📸 Gallery: Tap 'Streak Gallery' to view sleep photos\n"
          "📊 Stats: Check dashboard for detailed analytics\n\n"
          "Keep your streak alive by activating Sleep Lock each night!";
    }

    // Account & Sign In
    if (message.contains('sign in') ||
        message.contains('login') ||
        message.contains('account') ||
        message.contains('password')) {
      return "Account management:\n\n"
          "**Sign In/Up:** Tap 'Sign In' on home screen\n"
          "**Reset Password:** Use 'Forgot Password' on sign-in screen\n"
          "**Sign Out:** Tap 'Sign Out' button on home screen\n"
          "**Delete Account:** Email us at support@sleeploock.com\n\n"
          "Your data syncs across devices when signed in!";
    }

    // App Crashing
    if (message.contains('crash') ||
        message.contains('freeze') ||
        message.contains('slow') ||
        message.contains('bug')) {
      return "If the app is crashing or freezing:\n\n"
          "1. Clear app cache: Settings → Apps → SleepLock → Clear Cache\n"
          "2. Ensure you have the latest version (check app store)\n"
          "3. Restart your device\n"
          "4. Reinstall the app (your data is saved with your account)\n\n"
          "Still experiencing issues? Report the bug:\n"
          "→ Tap 'Report a Bug' below\n"
          "→ Or email bugs@sleeploock.com";
    }

    // Onboarding Reset
    if (message.contains('reset') || message.contains('onboarding')) {
      return "To reset onboarding and see the welcome screens again:\n\n"
          "1. Tap 'Reset Onboarding' on home screen (debug mode)\n"
          "2. Or sign out → sign in with new account\n\n"
          "This won't affect your streak or premium status!";
    }

    // Permissions
    if (message.contains('permission')) {
      return "SleepLock needs these permissions:\n\n"
          "✅ Notifications: For lock alerts & reminders\n"
          "✅ Storage: To save sleep photos\n"
          "✅ Audio: To play stories & sounds\n"
          "✅ Camera: For streak photo uploads (optional)\n\n"
          "Grant permissions: Settings → Apps → SleepLock → Permissions\n\n"
          "We respect your privacy - permissions are only used for features you activate.";
    }

    // Battery & Performance
    if (message.contains('battery') ||
        message.contains('drain') ||
        message.contains('performance')) {
      return "To optimize battery usage:\n\n"
          "1. Disable battery optimization for SleepLock in device settings\n"
          "2. Close other apps during sleep mode\n"
          "3. Lower screen brightness when viewing stories\n"
          "4. Use airplane mode to save battery overnight\n\n"
          "SleepLock is designed to use minimal battery - typically less than 5% per night.";
    }

    // Refund
    if (message.contains('refund') || message.contains('money back')) {
      return "For refund requests:\n\n"
          "**Premium Subscription:**\n"
          "Contact Google Play or Apple App Store support within 48 hours of purchase.\n\n"
          "**\$1 Instant Unlock:**\n"
          "These are non-refundable as they provide immediate value.\n\n"
          "If you're experiencing technical issues preventing usage, email support@sleeploock.com and we'll help resolve them!";
    }

    // Default response for unmatched queries
    return "I'm here to help! I can assist with:\n\n"
        "• Activating & troubleshooting Sleep Lock\n"
        "• Premium features & subscriptions\n"
        "• Notifications & reminders\n"
        "• Sounds, stories & alarms\n"
        "• Account & sign-in issues\n"
        "• App crashes & bugs\n\n"
        "Try asking your question another way, or:\n"
        "📧 Email support@sleeploock.com\n"
        "🔍 Check FAQs below\n\n"
        "What would you like help with?";
  }

  static Future<void> _logSupportQuery(String query) async {
    try {
      await _firestore.collection('support_logs').add({
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
        'resolved_by': 'ai',
      });
    } catch (e) {
      // Silently fail - logging is not critical
    }
  }

  /// Check if query needs human support escalation
  static bool needsHumanSupport(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('speak to human') ||
        lowerMessage.contains('talk to person') ||
        lowerMessage.contains('real person') ||
        lowerMessage.contains('representative') ||
        lowerMessage.contains('still not working') ||
        lowerMessage.contains('nothing works');
  }
}
