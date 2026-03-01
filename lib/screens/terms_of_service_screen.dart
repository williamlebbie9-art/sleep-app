import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2640),
        elevation: 0,
        title: const Text(
          'Terms of Service',
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
              'Agreement to Terms',
              'By downloading, installing, or using SleepLock, you agree to be bound by these Terms of Service. If you do not agree to these terms, do not use the app.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. License and Usage',
              'We grant you a limited, non-exclusive, non-transferable, revocable license to use SleepLock for personal, non-commercial purposes. You agree to:\n\n'
                  '• Use the app only for its intended purpose\n'
                  '• Not reverse engineer, decompile, or disassemble the app\n'
                  '• Not use the app for illegal activities\n'
                  '• Comply with all applicable laws and regulations\n'
                  '• Not attempt to bypass or circumvent app features',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. Account Responsibilities',
              'You are responsible for:\n\n'
                  '• Maintaining the security of your account credentials\n'
                  '• All activities that occur under your account\n'
                  '• Notifying us immediately of unauthorized access\n'
                  '• Providing accurate account information\n'
                  '• Keeping your account information up to date',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. Subscription Terms',
              'SleepLock offers premium subscriptions:\n\n'
                  '• Subscriptions auto-renew unless cancelled\n'
                  '• Cancel anytime via App Store or Google Play settings\n'
                  '• No refunds for partial subscription periods\n'
                  '• Prices subject to change with notice\n'
                  '• Free trial converts to paid unless cancelled before trial ends\n'
                  '• Access continues until end of billing period after cancellation',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. Instant Unlock Purchases',
              'The \$1 instant unlock feature:\n\n'
                  '• Is a one-time, non-refundable purchase\n'
                  '• Immediately removes the active sleep lock\n'
                  '• Does not affect future locks\n'
                  '• Is processed through your app store account\n'
                  '• Cannot be reversed once completed',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '5. Sleep Lock Feature',
              'The sleep lock functionality:\n\n'
                  '• Is designed to help you develop better sleep habits\n'
                  '• Can be bypassed via \$1 instant unlock or 10-minute wait\n'
                  '• Requires proper device permissions to function\n'
                  '• May not work if permissions are revoked\n'
                  '• Is not a replacement for medical sleep treatment\n\n'
                  'We are not responsible if the lock fails due to device limitations or user actions.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '6. AI Services',
              'Our AI Sleep Coach and Support Bot:\n\n'
                  '• Provide automated suggestions and support\n'
                  '• Are not a substitute for professional medical advice\n'
                  '• May not be 100% accurate\n'
                  '• Should not be relied upon for medical decisions\n'
                  '• Log conversations for quality and improvement purposes\n\n'
                  'Always consult healthcare professionals for sleep disorders.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '7. Content and Intellectual Property',
              'All content in SleepLock is owned by us or our licensors:\n\n'
                  '• Sleep stories, sounds, and audio files\n'
                  '• App design, code, and functionality\n'
                  '• Trademarks, logos, and branding\n'
                  '• AI-generated responses and insights\n\n'
                  'You may not copy, distribute, or create derivative works without permission.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '8. User-Generated Content',
              'Content you upload (photos, check-ins):\n\n'
                  '• Remains your property\n'
                  '• You grant us license to store and display\n'
                  '• Must not violate any laws or rights\n'
                  '• Must not contain inappropriate content\n'
                  '• Can be deleted by you at any time\n\n'
                  'We reserve the right to remove content that violates these terms.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '9. Privacy and Data',
              'Your use of SleepLock is subject to our Privacy Policy. By using the app, you consent to our data collection and use practices as described in the Privacy Policy.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '10. Disclaimers',
              'SleepLock is provided "as is" without warranties:\n\n'
                  '• We do not guarantee uninterrupted service\n'
                  '• Features may change or be discontinued\n'
                  '• We are not liable for data loss\n'
                  '• Third-party services may have their own terms\n'
                  '• The app is not medical device or treatment\n\n'
                  'USE AT YOUR OWN RISK.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '11. Limitation of Liability',
              'To the maximum extent permitted by law:\n\n'
                  '• We are not liable for indirect, incidental, or consequential damages\n'
                  '• Our total liability is limited to amount paid in past 12 months\n'
                  '• We are not responsible for third-party actions\n'
                  '• We are not liable for device damage or data loss\n'
                  '• Some jurisdictions do not allow liability limitations',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '12. Medical Disclaimer',
              'IMPORTANT: SleepLock is a habit-building tool, not medical treatment:\n\n'
                  '• Not intended to diagnose, treat, or cure sleep disorders\n'
                  '• Not a substitute for professional medical advice\n'
                  '• Consult a doctor for persistent sleep problems\n'
                  '• We make no medical claims or guarantees\n'
                  '• Individual results may vary',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '13. Termination',
              'We may terminate or suspend your access:\n\n'
                  '• For violation of these terms\n'
                  '• For fraudulent activity\n'
                  '• For abusive behavior\n'
                  '• At our discretion with or without notice\n\n'
                  'You may terminate by deleting your account. Paid subscriptions continue until period end.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '14. Changes to Terms',
              'We reserve the right to modify these terms at any time. Material changes will be notified via:\n\n'
                  '• In-app notification\n'
                  '• Email to registered address\n'
                  '• Notice on our website\n\n'
                  'Continued use after changes constitutes acceptance.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '15. Governing Law',
              'These terms are governed by the laws of [Your Jurisdiction]. Any disputes will be resolved in the courts of [Your Jurisdiction].',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '16. Contact Information',
              'For questions about these terms:\n\n'
                  '• Email: legal@sleeploock.com\n'
                  '• Support: support@sleeploock.com\n\n'
                  'We will respond to inquiries within 5 business days.',
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
