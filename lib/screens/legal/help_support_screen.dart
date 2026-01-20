import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedIndex;

  final List<_FAQ> _faqs = [
    _FAQ(
      question: 'What is FriendlyWager?',
      answer: 'FriendlyWager is a sweepstakes-based social betting platform where you can create and join golf bets with friends. '
          'We use a dual-coin system: Gold Coins (GC) for social play and Sweeps Coins (SC) which can be redeemed for prizes.',
    ),
    _FAQ(
      question: 'What are Gold Coins (GC)?',
      answer: 'Gold Coins are virtual currency used for social entertainment and gameplay. They have no cash value and cannot be redeemed for money or prizes. '
          'You purchase GC to participate in bets and challenges on the platform.',
    ),
    _FAQ(
      question: 'What are Sweeps Coins (SC)?',
      answer: 'Sweeps Coins are promotional items given FREE as bonuses when you purchase Gold Coins. SC can be redeemed for gift cards once you meet the playthrough requirements (1x). '
          'Minimum redemption is 50 SC (\$50 value). SC have no cash value but represent sweepstakes entries.',
    ),
    _FAQ(
      question: 'How do I get Sweeps Coins?',
      answer: 'You can get SC in several ways:\n'
          '• FREE bonus with every GC purchase\n'
          '• AMOE (Alternative Method of Entry) - request free SC without purchase\n'
          '• Referral bonuses\n'
          '• Promotional campaigns\n'
          '• Winning bets with SC',
    ),
    _FAQ(
      question: 'What is the playthrough requirement?',
      answer: 'Playthrough is a 1x requirement meaning you must wager your bonus SC once before it becomes redeemable. '
          'For example, if you receive 10 SC as a bonus, you must wager those 10 SC in bets before you can redeem them for prizes. '
          'This ensures fair play and prevents abuse.',
    ),
    _FAQ(
      question: 'How do I redeem Sweeps Coins?',
      answer: '1. Have at least 50 redeemable SC (after playthrough)\n'
          '2. Complete KYC verification (one-time)\n'
          '3. Go to Wallet > Redeem\n'
          '4. Choose gift card type and amount\n'
          '5. Submit redemption request\n'
          '6. Receive gift card via email within 3-5 business days',
    ),
    _FAQ(
      question: 'What is KYC verification?',
      answer: 'KYC (Know Your Customer) is identity verification required before you can redeem Sweeps Coins. You\'ll need to provide:\n'
          '• Full name\n'
          '• Date of birth\n'
          '• Address\n'
          '• Government-issued ID photo\n\n'
          'We use Didit for secure verification. This is a one-time process required by law to prevent fraud.',
    ),
    _FAQ(
      question: 'What is AMOE?',
      answer: 'AMOE (Alternative Method of Entry) allows you to receive free Sweeps Coins without making a purchase. '
          'Simply go to Wallet > Free SC (AMOE) and submit a request with your name and mailing address. '
          'This ensures our sweepstakes model complies with US law.',
    ),
    _FAQ(
      question: 'Where is FriendlyWager available?',
      answer: 'FriendlyWager is available to users 18+ in most US states. We are NOT available in:\n'
          '• Washington (WA)\n'
          '• Idaho (ID)\n'
          '• Nevada (NV)\n'
          '• Montana (MT)\n\n'
          'Service is not available outside the United States.',
    ),
    _FAQ(
      question: 'How does betting work?',
      answer: '1. Create or join a bet with GC or SC\n'
          '2. Complete your golf round\n'
          '3. Submit your score\n'
          '4. Judges verify results\n'
          '5. Winners receive payouts (minus 5% platform fee)\n\n'
          'Bets can be stroke play, match play, skins, or custom formats.',
    ),
    _FAQ(
      question: 'What is the platform fee?',
      answer: 'FriendlyWager charges a 5% fee on bet winnings to maintain and improve the platform. '
          'For example, if you win 100 GC, you receive 95 GC after the fee. This helps us provide a quality service.',
    ),
    _FAQ(
      question: 'Can I get a refund?',
      answer: 'Gold Coin purchases are final and non-refundable as they are virtual items for entertainment. '
          'However, if a bet is cancelled or voided due to technical issues, all participants receive their wagers back.',
    ),
    _FAQ(
      question: 'How do I add friends?',
      answer: 'You can add friends by:\n'
          '• Searching for their username\n'
          '• Scanning their QR code\n'
          '• Sharing your profile link\n'
          '• Finding them in suggested users',
    ),
    _FAQ(
      question: 'What if I forget my password?',
      answer: 'On the login screen, tap "Forgot Password" and enter your email. '
          'We\'ll send you a password reset link. Follow the instructions to create a new password.',
    ),
    _FAQ(
      question: 'How do I delete my account?',
      answer: 'Go to Settings > Danger Zone > Delete Account. You\'ll need to enter your password to confirm. '
          'Warning: This action is permanent and all your Gold Coins will be forfeited. Redeemable Sweeps Coins must be redeemed within 30 days.',
    ),
    _FAQ(
      question: 'Is my data secure?',
      answer: 'Yes! We use industry-standard security measures:\n'
          '• Encrypted data transmission (HTTPS)\n'
          '• Encrypted password storage\n'
          '• Secure payment processing via Stripe\n'
          '• Regular security audits\n'
          '• Compliance with data protection laws',
    ),
  ];

  Future<void> _contactSupport() async {
    final email = Uri.parse('mailto:support@friendlywager.com?subject=Support Request');
    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email app. Please email: support@friendlywager.com'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Contact Support Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.neonBlue.withAlpha(51), AppTheme.neonGreen.withAlpha(51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neonBlue.withAlpha(77)),
            ),
            child: Column(
              children: [
                Icon(Icons.support_agent, size: 48, color: AppTheme.neonBlue),
                const SizedBox(height: 16),
                Text(
                  'Need Help?',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our support team is here to help you',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _contactSupport,
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'support@friendlywager.com',
                  style: TextStyle(
                    color: AppTheme.neonBlue,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // FAQs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: AppTheme.hotPink, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    color: AppTheme.hotPink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final isExpanded = _expandedIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSlateGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isExpanded
                          ? AppTheme.neonBlue.withAlpha(77)
                          : AppTheme.textMuted.withAlpha(26),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      title: Text(
                        faq.question,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      trailing: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.neonBlue,
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedIndex = expanded ? index : null;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq.answer,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;

  _FAQ({required this.question, required this.answer});
}
