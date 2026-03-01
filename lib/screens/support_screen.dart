import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ai_support_chat_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // AI Support Chat Card (Primary)
          _buildCard(
            context,
            icon: Icons.smart_toy,
            iconColor: const Color(0xFF6C63FF),
            title: 'Chat with AI Support',
            subtitle: 'Get instant answers 24/7',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AISupportChatScreen()),
            ),
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          // Contact Human Support Card
          _buildCard(
            context,
            icon: Icons.mail_outline,
            iconColor: const Color(0xFF9C27B0),
            title: 'Email Support',
            subtitle: 'Contact our human team',
            onTap: () => _contactSupport(context),
          ),
          const SizedBox(height: 16),

          // FAQs Section
          _buildSectionHeader('Frequently Asked Questions'),
          const SizedBox(height: 12),

          _buildFAQItem(
            context,
            question: 'How do I activate Sleep Lock?',
            answer:
                'Tap "Activate Sleep Lock" on the home screen, choose your duration (3hr, 4hr, 6hr, or 8hr), and optionally toggle sounds on or off. Your phone will lock at the scheduled time.',
          ),

          _buildFAQItem(
            context,
            question: 'Sleep Lock isn\'t activating. What should I do?',
            answer:
                'Make sure you\'ve granted all necessary permissions including notifications. Check that battery optimization is disabled for SleepLock in your device settings.',
          ),

          _buildFAQItem(
            context,
            question: 'How do I unlock instantly?',
            answer:
                'During Sleep Lock, tap the "Unlock Now for \$1" button. This one-time payment removes the lock immediately while supporting app development.',
          ),

          _buildFAQItem(
            context,
            question: 'Can I access premium features?',
            answer:
                'Yes! Premium unlocks all stories, sounds, advanced AI coaching, and removes ads. Tap "Upgrade to Premium" on the home screen.',
          ),

          _buildFAQItem(
            context,
            question: 'How do I cancel my subscription?',
            answer:
                'Go to your device\'s app store (Google Play or Apple App Store) → Subscriptions → SleepLock → Cancel Subscription.',
          ),

          _buildFAQItem(
            context,
            question: 'The alarm isn\'t playing. Help!',
            answer:
                'Ensure your device volume is up and "Do Not Disturb" is off. Check that SleepLock has permission to play audio in the background.',
          ),

          _buildFAQItem(
            context,
            question: 'How do I reset onboarding?',
            answer:
                'Use the "Reset Onboarding" button on the home screen (in debug mode) or sign out and create a new account.',
          ),

          const SizedBox(height: 24),

          // Troubleshooting Section
          _buildSectionHeader('Troubleshooting Tips'),
          const SizedBox(height: 12),

          _buildTroubleshootingCard(
            context,
            title: 'Notifications Not Working',
            steps: [
              'Go to device Settings → Apps → SleepLock',
              'Enable all notification permissions',
              'Disable battery optimization for SleepLock',
              'Restart the app',
            ],
          ),

          _buildTroubleshootingCard(
            context,
            title: 'Audio Not Playing',
            steps: [
              'Check device volume level',
              'Turn off "Do Not Disturb" mode',
              'Grant audio permissions to SleepLock',
              'Try a different story or sound',
            ],
          ),

          _buildTroubleshootingCard(
            context,
            title: 'App Crashing',
            steps: [
              'Clear app cache in device settings',
              'Ensure you have the latest app version',
              'Restart your device',
              'Reinstall the app if issue persists',
            ],
          ),

          const SizedBox(height: 24),

          // App Info Card
          _buildCard(
            context,
            icon: Icons.info_outline,
            iconColor: const Color(0xFF9C27B0),
            title: 'App Information',
            subtitle: 'Version 1.0.0 | Build 1',
            onTap: () => _showAppInfo(context),
          ),

          const SizedBox(height: 16),

          // Report a Bug
          _buildCard(
            context,
            icon: Icons.bug_report_outlined,
            iconColor: const Color(0xFFFF6B6B),
            title: 'Report a Bug',
            subtitle: 'Help us improve SleepLock',
            onTap: () => _reportBug(context),
          ),

          const SizedBox(height: 24),

          // Legal & Account Section
          _buildSectionHeader('Legal & Account'),
          const SizedBox(height: 12),

          _buildCard(
            context,
            icon: Icons.restore,
            iconColor: const Color(0xFF4CAF50),
            title: 'Restore Purchases',
            subtitle: 'Recover your premium subscription',
            onTap: () => _restorePurchases(context),
          ),
          const SizedBox(height: 12),

          _buildCard(
            context,
            icon: Icons.privacy_tip_outlined,
            iconColor: const Color(0xFF2196F3),
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _buildCard(
            context,
            icon: Icons.description_outlined,
            iconColor: const Color(0xFFFF9800),
            title: 'Terms of Service',
            subtitle: 'Our terms and conditions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  'Still need help?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email us at support@sleeploock.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        ),
                      ),
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restorePurchases(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      ),
    );

    try {
      final customerInfo = await Purchases.restorePurchases();
      if (!context.mounted) return;

      Navigator.pop(context); // Close loading dialog

      final hasActiveEntitlement = customerInfo.entitlements.active.isNotEmpty;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2D2640),
          title: Row(
            children: [
              Icon(
                hasActiveEntitlement ? Icons.check_circle : Icons.info_outline,
                color: hasActiveEntitlement
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
              ),
              const SizedBox(width: 12),
              Text(
                hasActiveEntitlement ? 'Success!' : 'No Purchases Found',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            hasActiveEntitlement
                ? 'Your premium subscription has been restored successfully!'
                : 'No active purchases found. If you believe this is an error, contact support@sleeploock.com',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF6C63FF)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2D2640),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFFF6B6B)),
              SizedBox(width: 12),
              Text('Restore Failed', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Failed to restore purchases. Please check your internet connection and try again.',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF6C63FF)),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF5B4BDB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  const Color(0xFF2D2640).withOpacity(0.8),
                  const Color(0xFF1E1B2E).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFF6C63FF).withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withOpacity(0.2)
                        : iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary ? Colors.white : iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'INSTANT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            isPrimary ? 0.9 : 0.6,
                          ),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(isPrimary ? 0.9 : 0.3),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2640).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: const Color(0xFF6C63FF),
        collapsedIconColor: Colors.white.withOpacity(0.5),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingCard(
    BuildContext context, {
    required String title,
    required List<String> steps,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2640).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build_circle_outlined,
                color: const Color(0xFF6C63FF),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) async {
    final email = 'support@sleeploock.com';
    final subject = 'SleepLock Support Request';
    final body = 'Please describe your issue:\n\n';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject, 'body': body},
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showEmailCopyDialog(context, email);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showEmailCopyDialog(context, email);
      }
    }
  }

  void _reportBug(BuildContext context) async {
    final email = 'bugs@sleeploock.com';
    final subject = 'Bug Report - SleepLock';
    final body =
        'Bug Description:\n\n'
        'Steps to Reproduce:\n1. \n\n'
        'Expected Behavior:\n\n'
        'Actual Behavior:\n\n'
        'Device Info:\n'
        '- Device Model: \n'
        '- OS Version: \n'
        '- App Version: 1.0.0\n';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject, 'body': body},
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showEmailCopyDialog(context, email);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showEmailCopyDialog(context, email);
      }
    }
  }

  void _showEmailCopyDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2640),
        title: const Text('Email Us', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Copy our email address:',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFF6C63FF)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: email));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard'),
                          backgroundColor: Color(0xFF6C63FF),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2640),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bedtime,
                color: Color(0xFF6C63FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('SleepLock', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Build', '1'),
            _buildInfoRow('Platform', 'Android/iOS'),
            const SizedBox(height: 16),
            Text(
              'Your nights deserve better. SleepLock helps you break free from digital distractions and reclaim restful sleep.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
