import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FriendlyWager Privacy Policy',
              style: TextStyle(
                color: AppTheme.neonBlue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: January 2026',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'Introduction',
              'FriendlyWager ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. '
              'This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our service.',
            ),

            _buildSection(
              '1. Information We Collect',
              'We collect the following types of information:\n\n'
              'Account Information:\n'
              '• Email address\n'
              '• Username\n'
              '• Date of birth\n'
              '• Password (encrypted)\n\n'
              'Profile Information:\n'
              '• Profile photo\n'
              '• Bio/description\n'
              '• Golf handicap\n\n'
              'Transaction Information:\n'
              '• Purchase history\n'
              '• Bet history\n'
              '• Wallet balance\n'
              '• Redemption requests\n\n'
              'KYC Information (for SC redemptions):\n'
              '• Full name\n'
              '• Government-issued ID\n'
              '• Address\n'
              '• Date of birth verification\n\n'
              'Technical Information:\n'
              '• IP address\n'
              '• Device information\n'
              '• Browser type\n'
              '• Operating system\n'
              '• App version\n\n'
              'Usage Data:\n'
              '• Pages visited\n'
              '• Time spent on platform\n'
              '• Features used\n'
              '• Bet patterns',
            ),

            _buildSection(
              '2. How We Use Your Information',
              'We use your information to:\n'
              '• Provide and maintain our service\n'
              '• Process transactions and bets\n'
              '• Verify your identity (KYC)\n'
              '• Detect and prevent fraud\n'
              '• Send you important updates\n'
              '• Improve our service\n'
              '• Comply with legal obligations\n'
              '• Enforce our Terms of Service\n'
              '• Provide customer support',
            ),

            _buildSection(
              '3. Geographic Restrictions',
              'We collect your IP address and geographic location to ensure compliance with state laws. '
              'Our service is not available in Washington (WA), Idaho (ID), Nevada (NV), and Montana (MT). '
              'All location checks are logged for regulatory compliance.',
            ),

            _buildSection(
              '4. Data Sharing and Disclosure',
              'We may share your information with:\n\n'
              'Service Providers:\n'
              '• Stripe (payment processing)\n'
              '• Didit (KYC verification)\n'
              '• Cloudinary (image hosting)\n'
              '• Firebase (push notifications)\n\n'
              'Legal Requirements:\n'
              'We may disclose your information if required by law, court order, or government request.\n\n'
              'Business Transfers:\n'
              'In case of merger, acquisition, or sale, your information may be transferred to the new owner.\n\n'
              'We DO NOT sell your personal information to third parties.',
            ),

            _buildSection(
              '5. Data Security',
              'We implement security measures to protect your data:\n'
              '• Encryption of passwords and sensitive data\n'
              '• Secure HTTPS connections\n'
              '• Regular security audits\n'
              '• Access controls and authentication\n'
              '• Secure database storage\n\n'
              'However, no method of transmission over the internet is 100% secure.',
            ),

            _buildSection(
              '6. Data Retention',
              'We retain your information:\n'
              '• Account data: Until you delete your account + 30 days\n'
              '• Transaction history: 7 years (regulatory requirement)\n'
              '• KYC documents: 7 years (regulatory requirement)\n'
              '• Geolocation logs: 2 years\n'
              '• Usage analytics: 1 year',
            ),

            _buildSection(
              '7. Your Rights',
              'You have the right to:\n'
              '• Access your personal data\n'
              '• Correct inaccurate data\n'
              '• Delete your account and data\n'
              '• Export your data\n'
              '• Opt-out of marketing communications\n'
              '• Withdraw consent\n\n'
              'To exercise these rights, contact us at privacy@friendlywager.com',
            ),

            _buildSection(
              '8. Cookies and Tracking',
              'We use cookies and similar technologies to:\n'
              '• Maintain your session\n'
              '• Remember your preferences\n'
              '• Analyze usage patterns\n'
              '• Improve our service\n\n'
              'You can disable cookies in your browser settings, but this may affect functionality.',
            ),

            _buildSection(
              '9. Children\'s Privacy',
              'Our service is not intended for anyone under 18 years old. We do not knowingly collect data from minors. '
              'If we discover we have collected data from a minor, we will delete it immediately.',
            ),

            _buildSection(
              '10. California Privacy Rights (CCPA)',
              'California residents have additional rights:\n'
              '• Right to know what personal data is collected\n'
              '• Right to know if personal data is sold or disclosed\n'
              '• Right to opt-out of data sales (we don\'t sell data)\n'
              '• Right to deletion\n'
              '• Right to non-discrimination',
            ),

            _buildSection(
              '11. International Users',
              'Our service is designed for US residents only. If you access from outside the US, your data may be '
              'transferred to and processed in the United States.',
            ),

            _buildSection(
              '12. Third-Party Links',
              'Our service may contain links to third-party websites. We are not responsible for their privacy practices. '
              'Please review their privacy policies.',
            ),

            _buildSection(
              '13. Push Notifications',
              'We send push notifications for:\n'
              '• Bet updates\n'
              '• Friend requests\n'
              '• Messages\n'
              '• Promotional offers\n\n'
              'You can disable notifications in your device settings or app preferences.',
            ),

            _buildSection(
              '14. Changes to Privacy Policy',
              'We may update this Privacy Policy periodically. We will notify you of significant changes via email or app notification. '
              'Continued use after changes constitutes acceptance.',
            ),

            _buildSection(
              '15. Contact Us',
              'For privacy-related questions or requests:\n\n'
              'Email: privacy@friendlywager.com\n'
              'Data Protection Officer: dpo@friendlywager.com\n'
              'Address: FriendlyWager, Inc.',
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSlateGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonGreen.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline, color: AppTheme.neonGreen),
                      const SizedBox(width: 12),
                      Text(
                        'Your Privacy Matters',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We are committed to protecting your privacy and handling your data responsibly. '
                    'If you have any concerns, please don\'t hesitate to contact us.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
