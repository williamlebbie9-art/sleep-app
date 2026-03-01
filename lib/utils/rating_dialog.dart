import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RatingDialog {
  static const String _lastShownKey = 'rating_dialog_last_shown';
  static const String _neverShowKey = 'rating_dialog_never_show';

  /// Check if we should show the rating dialog (once per day)
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user dismissed permanently
    final neverShow = prefs.getBool(_neverShowKey) ?? false;
    if (neverShow) return false;

    // Check last shown date
    final lastShown = prefs.getString(_lastShownKey);
    if (lastShown == null) return true;

    final lastDate = DateTime.tryParse(lastShown);
    if (lastDate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastDate);

    // Show if it's been at least 1 day
    return difference.inDays >= 1;
  }

  /// Mark the dialog as shown today
  static Future<void> markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastShownKey, DateTime.now().toIso8601String());
  }

  /// Mark to never show again
  static Future<void> markNeverShow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_neverShowKey, true);
  }

  /// Show the rating dialog
  static Future<void> show(BuildContext context) async {
    if (!await shouldShow()) return;

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Enjoying SleepLock?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your feedback helps us improve and reach more people who need better sleep! 🌙',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(Icons.star, color: Colors.amber[400], size: 32);
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await markNeverShow();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Don\'t Ask Again',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                await markAsShown();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await markAsShown();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  await _openStoreReview();
                }
              },
              child: const Text(
                'Rate Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Open the app store for review
  static Future<void> _openStoreReview() async {
    // For Android Play Store
    final androidUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.sleeplock.app',
    );

    // For iOS App Store
    final iosUrl = Uri.parse('https://apps.apple.com/app/id<YOUR_APP_ID>');

    // Try to open the appropriate store
    try {
      // You can use platform detection here
      // For now, trying Android first
      if (await canLaunchUrl(androidUrl)) {
        await launchUrl(androidUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(iosUrl)) {
        await launchUrl(iosUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch store: $e');
    }
  }
}
