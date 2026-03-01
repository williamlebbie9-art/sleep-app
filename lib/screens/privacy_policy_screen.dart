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
            _buildSection('Last Updated', 'February 15, 2026'),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'SleepLock ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our mobile application.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information We Collect',
              'We collect the following types of information:\n\n'
                  '• Account Information: Email address, name, and authentication credentials\n'
                  '• Usage Data: Sleep lock activation times, duration preferences, streak data\n'
                  '• Device Information: Device model, operating system, app version\n'
                  '• Stories & Sounds: Your preferences and listening history\n'
                  '• AI Interactions: Conversations with our AI Sleep Coach and Support Bot\n'
                  '• Photos: Sleep streak photos you upload (optional)\n'
                  '• Payment Information: Processed securely through Apple App Store or Google Play',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. How We Use Your Information',
              'We use your data to:\n\n'
                  '• Provide and improve the SleepLock service\n'
                  '• Personalize your sleep experience\n'
                  '• Send bedtime reminders and notifications\n'
                  '• Process payments and manage subscriptions\n'
                  '• Provide AI-powered sleep coaching and support\n'
                  '• Track your sleep streaks and progress\n'
                  '• Analyze usage patterns to improve features\n'
                  '• Communicate updates and support responses',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. Data Storage and Security',
              'Your data is stored securely using:\n\n'
                  '• Firebase Cloud Firestore: Encrypted data storage\n'
                  '• Secure authentication via Firebase Auth\n'
                  '• Industry-standard encryption protocols\n'
                  '• Regular security audits and updates\n\n'
                  'We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, or destruction.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. Third-Party Services',
              'We use the following third-party services:\n\n'
                  '• Firebase (Google): Authentication, database, analytics\n'
                  '• RevenueCat: Subscription and payment management\n'
                  '• Apple App Store / Google Play: Payment processing\n\n'
                  'These services have their own privacy policies and data handling practices. We recommend reviewing their policies.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '5. Data Sharing',
              'We do NOT sell your personal data. We may share data only in these circumstances:\n\n'
                  '• With service providers who help operate our app\n'
                  '• When required by law or legal process\n'
                  '• To protect our rights or safety\n'
                  '• With your explicit consent',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '6. Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate data\n'
                  '• Delete your account and data\n'
                  '• Export your data\n'
                  '• Opt-out of marketing communications\n'
                  '• Withdraw consent at any time\n\n'
                  'To exercise these rights, contact us at privacy@sleeploock.com',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '7. Children\'s Privacy',
              'SleepLock is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected data from a child, please contact us immediately.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '8. Cookies and Tracking',
              'We use minimal tracking technologies to:\n\n'
                  '• Remember your preferences\n'
                  '• Maintain your login session\n'
                  '• Analyze app performance\n'
                  '• Improve user experience\n\n'
                  'You can manage tracking preferences in your device settings.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '9. Data Retention',
              'We retain your data for as long as your account is active or as needed to provide services. When you delete your account, we will delete your personal data within 30 days, except where required by law.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '10. International Data Transfers',
              'Your data may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data in compliance with applicable data protection laws.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '11. Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of significant changes via email or app notification. Continued use of SleepLock after changes constitutes acceptance of the updated policy.',
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
