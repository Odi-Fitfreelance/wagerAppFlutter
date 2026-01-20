import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FriendlyWager Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing and using FriendlyWager, you accept and agree to be bound by these Terms of Service. '
              'If you do not agree to these terms, please do not use our service.',
            ),

            _buildSection(
              '2. Sweepstakes Model',
              'FriendlyWager operates as a sweepstakes platform:\n\n'
              '• Gold Coins (GC) are purchased for entertainment and social play only\n'
              '• Sweeps Coins (SC) are awarded FREE as promotional bonuses\n'
              '• SC can be redeemed for prizes but have no cash value\n'
              '• No purchase necessary to participate - see AMOE (Alternative Method of Entry)',
            ),

            _buildSection(
              '3. Eligibility',
              '• You must be 18 years or older to use FriendlyWager\n'
              '• You must be a legal resident of the United States\n'
              '• Service is not available in: Washington (WA), Idaho (ID), Nevada (NV), and Montana (MT)\n'
              '• One account per person\n'
              '• KYC verification required for SC redemptions',
            ),

            _buildSection(
              '4. Account Registration',
              'You agree to:\n'
              '• Provide accurate and complete information\n'
              '• Maintain the security of your account credentials\n'
              '• Notify us immediately of any unauthorized access\n'
              '• Accept responsibility for all activities under your account',
            ),

            _buildSection(
              '5. Gold Coins (GC)',
              '• GC are virtual items for entertainment purposes only\n'
              '• GC have no monetary value and cannot be redeemed for cash\n'
              '• GC purchases are final and non-refundable\n'
              '• GC cannot be transferred between accounts',
            ),

            _buildSection(
              '6. Sweeps Coins (SC)',
              '• SC are promotional items given FREE with GC purchases\n'
              '• SC can be redeemed for gift cards (minimum 50 SC)\n'
              '• 1x playthrough requirement before SC becomes redeemable\n'
              '• SC expire after 60 days of inactivity\n'
              '• SC redemptions require KYC verification',
            ),

            _buildSection(
              '7. Betting and Wagering',
              '• All bets are for entertainment purposes\n'
              '• Bet results are final once determined\n'
              '• FriendlyWager reserves the right to void bets in case of technical errors\n'
              '• Collusion, cheating, or fraudulent activity will result in account termination',
            ),

            _buildSection(
              '8. Platform Fees',
              'FriendlyWager charges a 5% platform fee on all bet winnings to maintain and improve our service.',
            ),

            _buildSection(
              '9. Prohibited Activities',
              'You may not:\n'
              '• Create multiple accounts\n'
              '• Use VPNs or proxies to circumvent geographic restrictions\n'
              '• Engage in money laundering or fraudulent activities\n'
              '• Use bots or automated systems\n'
              '• Manipulate or exploit bugs in the platform\n'
              '• Harass or abuse other users',
            ),

            _buildSection(
              '10. Intellectual Property',
              'All content, features, and functionality are owned by FriendlyWager and protected by copyright, '
              'trademark, and other intellectual property laws.',
            ),

            _buildSection(
              '11. Limitation of Liability',
              'FriendlyWager is provided "as is" without warranties of any kind. We are not liable for:\n'
              '• Loss of GC or SC due to technical issues\n'
              '• Errors in bet calculations\n'
              '• Service interruptions\n'
              '• Third-party actions',
            ),

            _buildSection(
              '12. Dispute Resolution',
              'Any disputes arising from these Terms will be resolved through binding arbitration in accordance '
              'with the rules of the American Arbitration Association.',
            ),

            _buildSection(
              '13. Changes to Terms',
              'We reserve the right to modify these Terms at any time. Continued use of the service after '
              'changes constitutes acceptance of the modified Terms.',
            ),

            _buildSection(
              '14. Termination',
              'We may terminate or suspend your account at any time for violation of these Terms. Upon termination:\n'
              '• You will lose access to your account\n'
              '• Unused GC will be forfeited\n'
              '• SC may be redeemed within 30 days if eligible',
            ),

            _buildSection(
              '15. Contact Us',
              'For questions about these Terms, contact us at:\n'
              'Email: support@friendlywager.com\n'
              'Address: FriendlyWager, Inc.',
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSlateGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonBlue.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.neonBlue),
                      const SizedBox(width: 12),
                      Text(
                        'Important Notice',
                        style: TextStyle(
                          color: AppTheme.neonBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By using FriendlyWager, you acknowledge that you have read, understood, and agree '
                    'to be bound by these Terms of Service and our Privacy Policy.',
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
