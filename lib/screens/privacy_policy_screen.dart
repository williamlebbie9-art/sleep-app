import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2640),
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Last Updated', 'March 28, 2026'),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'SleepLock ("we", "our", or "us") is designed to help you build healthier sleep habits. This Privacy Policy explains what information we collect, why we collect it, where it is stored, who can access it, and what controls you have. By using SleepLock, you agree to this policy.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information We Collect',
              'Depending on the features you use, we may collect:\n\n'
                  '• Account data: Email, display name, sign-in provider, profile photo URL, and user ID\n'
                  '• Sleep progress data: Sleep streak values, milestones, ranks, badges, and sleep lock usage\n'
                  '• App preference data: Last selected story, sounds, bedtime settings, and reminder preferences\n'
                  '• Photo data (optional): Night check-in photos and imported monthly memory photos\n'
                  '• AI chat content: Messages you send to AI Sleep Coach and short recent chat context\n'
                  '• Referral and creator data: Referral codes, referral attribution, and payout tracking information\n'
                  '• Technical data: App version and basic diagnostic/error details used for reliability',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. How We Use Your Information',
              'We use collected data to:\n\n'
                  '• Run core app features (sleep lock, stories, sounds, reminders, streaks)\n'
                  '• Personalize your in-app experience and progress tracking\n'
                  '• Generate monthly sleep memories from your sleep-related photos\n'
                  '• Provide AI Sleep Coach responses to sleep-related questions\n'
                  '• Enable leaderboard and community ranking features\n'
                  '• Process subscriptions and creator/referral program operations\n'
                  '• Prevent abuse, investigate issues, and improve app performance',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. Where Data Is Stored',
              'SleepLock uses both local device storage and secure cloud services:\n\n'
                  '• On your device (local): Check-in photos, monthly memory copies, selected sounds/stories, and some app settings\n'
                  '• In Firebase (cloud): Account profile fields, streak progress, leaderboard fields, and referral records\n'
                  '• For AI responses: Chat requests are sent to our secure backend and then to our AI provider\n\n'
                  'Local data remains on your device unless you explicitly share it or a feature uploads it.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. Permissions We Request',
              'SleepLock requests permissions only for features you use:\n\n'
                  '• Camera: To take night check-in and profile photos\n'
                  '• Photo library/gallery: To import images for Monthly Sleep Memories\n'
                  '• Notifications: To send bedtime and sleep guidance reminders\n'
                  '• Platform-specific sleep lock permissions (where applicable): To support app-blocking workflows\n\n'
                  'You can revoke permissions anytime in your device settings, though related features may stop working.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '5. AI Sleep Coach Processing',
              'When you chat with AI Sleep Coach:\n\n'
                  '• Your message and a small recent chat context may be sent to our backend\n'
                  '• Our backend forwards that content to an AI provider to generate a reply\n'
                  '• AI feature is configured for sleep-focused guidance and may refuse non-sleep topics\n'
                  '• Do not share highly sensitive personal data in AI chat\n\n'
                  'AI outputs are for wellness guidance and are not medical diagnosis or emergency advice.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '6. Data Sharing and Public Visibility',
              'We do NOT sell your personal data. We share data only when needed:\n\n'
                  '• Service providers: Firebase, RevenueCat, app stores, and AI processing providers\n'
                  '• Leaderboards/community: Public ranking fields such as username, rank, badge, and streak values\n'
                  '• Legal requirements: If required by law, regulation, or valid legal process\n'
                  '• Safety and fraud prevention: To protect users, systems, and legal rights',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '7. Data Retention',
              'We keep information only as long as needed for product operation, legal obligations, and dispute prevention.\n\n'
                  '• Active account data is retained while your account remains active\n'
                  '• Some local photo data remains on your device until you remove it\n'
                  '• If you request account/data deletion, we process that request within a reasonable period, except where retention is legally required',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '8. Your Controls and Rights',
              'Depending on your location, you may have rights to access, correct, delete, or export your personal data, and to object to certain processing.\n\n'
                  'In-app controls include permission settings and feature-level choices. For account-level requests, contact us using the details below.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '9. Children\'s Privacy',
              'SleepLock is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe a child has provided personal data, contact us so we can investigate and remove the data as appropriate.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '10. International Data Transfers',
              'Because our service providers operate globally, your data may be processed in countries outside your own. Where required, we apply safeguards designed to protect personal data under applicable law.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '11. Changes to This Policy',
              'We may update this policy periodically as features or legal requirements change. Material updates may be highlighted in-app. The latest "Last Updated" date shows when this policy was revised.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '12. Contact Us',
              'If you have questions about this privacy policy or our data practices, contact us:\n\n'
                  '• Email: privacy@sleeploock.com\n'
                  '• Support: support@sleeploock.com\n\n'
                  'We aim to respond to all inquiries within 48 hours.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2026 SleepLock. All rights reserved.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.8),
            height: 1.7,
          ),
        ),
      ],
    );
  }
}
