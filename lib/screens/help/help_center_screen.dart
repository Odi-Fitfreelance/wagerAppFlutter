import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_theme.dart';

class FAQItem {
  final String id;
  final String category;
  final String question;
  final String answer;

  FAQItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });
}

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<String> _expandedItems = {};

  static const List<String> categories = [
    'All',
    'Getting Started',
    'Creating & Joining Bets',
    'Playing & Scoring',
    'Points & Wallet',
    'Social Features',
    'Account & Settings',
    'Troubleshooting',
    'Rules & Compliance',
    'General',
  ];

  static final List<FAQItem> faqData = [
    // Getting Started
    FAQItem(
      id: '1',
      category: 'Getting Started',
      question: 'How do I create an account?',
      answer: 'Tap "Register" on the login screen, enter your email, username, and password. You must be 18 or older to create an account. After registration, verify your email address to activate your account.',
    ),
    FAQItem(
      id: '2',
      category: 'Getting Started',
      question: 'What is Betcha?',
      answer: 'Betcha is a social betting platform where you can create and join friendly wagers with people you know. We use a virtual points system for tracking bets.',
    ),
    FAQItem(
      id: '3',
      category: 'Getting Started',
      question: 'Do I need to be a golfer to use this app?',
      answer: 'Yes, Betcha is designed for golfers who want to add friendly competition to their rounds. You\'ll need to track your scores and participate in golf games.',
    ),
    FAQItem(
      id: '4',
      category: 'Getting Started',
      question: 'Is there an age requirement?',
      answer: 'Yes, you must be at least 18 years old to use Betcha. We may require age verification at any time.',
    ),

    // Creating & Joining Bets
    FAQItem(
      id: '5',
      category: 'Creating & Joining Bets',
      question: 'How do I create a bet?',
      answer: 'From the Bets screen, tap "Create New Bet". Choose your bet type, set the stakes, and invite players. Once all details are set, create the bet and share with your friends.',
    ),
    FAQItem(
      id: '6',
      category: 'Creating & Joining Bets',
      question: 'How do I join an existing bet?',
      answer: 'Tap "Join Existing Bet" from the Bets screen. Enter the bet code shared by the creator, review the bet details, and confirm your participation. Make sure you have enough points in your balance to cover the stake.',
    ),
    FAQItem(
      id: '7',
      category: 'Creating & Joining Bets',
      question: 'What bet types are available?',
      answer: 'We offer several golf betting formats:\n\n• Nassau - Three separate bets (front 9, back 9, overall)\n• Skins - Win holes outright\n• Match Play - Head-to-head competition\n• Stroke Play - Lowest total score wins\n• Stableford - Points-based scoring\n• Best Ball - Team format using best score per hole\n• Wolf - Rotating team game\n\nCustom rules can also be created!',
    ),
    FAQItem(
      id: '8',
      category: 'Creating & Joining Bets',
      question: 'Can I create custom bet rules?',
      answer: 'Yes! When creating a bet, you can use our Custom Rules Builder to set specific conditions, handicap adjustments, press options, and more. This allows you to recreate any betting format you play in real life.',
    ),
    FAQItem(
      id: '9',
      category: 'Creating & Joining Bets',
      question: 'What is a lobby code?',
      answer: 'A lobby code is a unique identifier for your bet. Share this code with friends so they can find and join your bet. The code expires once the bet starts or after 24 hours.',
    ),
    FAQItem(
      id: '10',
      category: 'Creating & Joining Bets',
      question: 'Can I cancel a bet after creating it?',
      answer: 'Yes, you can cancel a bet before it starts as long as no one else has joined. Once other players join, all participants must agree to cancel. Active bets cannot be cancelled.',
    ),

    // Playing & Scoring
    FAQItem(
      id: '11',
      category: 'Playing & Scoring',
      question: 'How do I enter scores during a round?',
      answer: 'Open your active bet from the Bets screen and tap the bet card. Enter each player\'s score for each hole. Scores update in real-time for all participants. The app automatically calculates bet outcomes based on the scores entered.',
    ),
    FAQItem(
      id: '12',
      category: 'Playing & Scoring',
      question: 'What if someone enters the wrong score?',
      answer: 'Scores can be edited during the round. All players in the bet can see score changes. If there\'s a dispute, players can flag scores for review. The bet won\'t finalize until all players confirm the final scores.',
    ),
    FAQItem(
      id: '13',
      category: 'Playing & Scoring',
      question: 'How does handicap work?',
      answer: 'If enabled in bet settings, the app applies USGA handicap adjustments automatically. Players can set their handicap in their profile. The app calculates hole-by-hole strokes based on the course difficulty.',
    ),
    FAQItem(
      id: '14',
      category: 'Playing & Scoring',
      question: 'Can I track scores offline?',
      answer: 'Currently, an internet connection is required to enter and sync scores in real-time. Offline mode is planned for a future update.',
    ),
    FAQItem(
      id: '15',
      category: 'Playing & Scoring',
      question: 'What happens if we don\'t finish 18 holes?',
      answer: 'You can finalize the bet with the holes completed. For Nassau bets, front and back 9 bets are calculated separately. The app will prorate or adjust results based on the bet type and holes played.',
    ),

    // Points & Wallet
    FAQItem(
      id: '16',
      category: 'Points & Wallet',
      question: 'What are Points?',
      answer: 'Points are the virtual currency used in Betcha for tracking bets. They have NO cash value and cannot be exchanged for real money. Points are only used for social competition and bragging rights.',
    ),
    FAQItem(
      id: '17',
      category: 'Points & Wallet',
      question: 'How do I get Points?',
      answer: 'New accounts start with 1,000 Points. You earn Points by winning bets. You can also purchase Point packages in the Store to maintain your balance. Remember, Points have no monetary value.',
    ),
    FAQItem(
      id: '18',
      category: 'Points & Wallet',
      question: 'Can I transfer Points to another user?',
      answer: 'No, Points cannot be transferred between users. Each player must maintain their own Point balance through wins and optional purchases.',
    ),
    FAQItem(
      id: '19',
      category: 'Points & Wallet',
      question: 'What happens if I run out of Points?',
      answer: 'You won\'t be able to join new bets until you add more Points to your account. You can purchase Point packages from the Store. Your existing active bets will continue normally.',
    ),
    FAQItem(
      id: '20',
      category: 'Points & Wallet',
      question: 'Can I cash out my Points?',
      answer: 'No. Points have zero cash value and cannot be exchanged for money. Betcha does not process any real money transactions. Any real-world settlements between players happen privately outside the app.',
    ),
    FAQItem(
      id: '21',
      category: 'Points & Wallet',
      question: 'How do I view my transaction history?',
      answer: 'Go to the Wallet tab and tap "Transaction History". You\'ll see all Point movements including bet wins, losses, purchases, and adjustments.',
    ),

    // Social Features
    FAQItem(
      id: '22',
      category: 'Social Features',
      question: 'How do I add friends?',
      answer: 'Go to the Follow tab, search for users by username, and tap "Follow". You can also find friends who joined your bets and follow them from the bet results screen.',
    ),
    FAQItem(
      id: '23',
      category: 'Social Features',
      question: 'What is the Leaderboard?',
      answer: 'The Leaderboard shows top players based on total Points won, win rate, and other stats. You can filter by time period (weekly, monthly, all-time) and see how you rank against friends and all players.',
    ),
    FAQItem(
      id: '24',
      category: 'Social Features',
      question: 'Can I make my profile private?',
      answer: 'Yes, go to Settings > Privacy Settings. You can control who can see your profile, send you bet invites, and view your statistics.',
    ),
    FAQItem(
      id: '25',
      category: 'Social Features',
      question: 'How do I block someone?',
      answer: 'Go to their profile, tap the menu icon, and select "Block User". Blocked users cannot send you bet invites or see your activity.',
    ),

    // Account & Settings
    FAQItem(
      id: '26',
      category: 'Account & Settings',
      question: 'How do I change my password?',
      answer: 'Go to Settings > Account > Change Password. Enter your current password and your new password twice to confirm.',
    ),
    FAQItem(
      id: '27',
      category: 'Account & Settings',
      question: 'How do I update my email address?',
      answer: 'Go to Settings > Account > Change Email. Enter your new email and current password. You\'ll need to verify the new email address.',
    ),
    FAQItem(
      id: '28',
      category: 'Account & Settings',
      question: 'Can I delete my account?',
      answer: 'Yes, go to Settings > Danger Zone > Delete Account. This action is permanent and cannot be undone. All your data, Points, and bet history will be deleted.',
    ),
    FAQItem(
      id: '29',
      category: 'Account & Settings',
      question: 'How do I turn off notifications?',
      answer: 'Go to Settings > Notifications. You can toggle different notification types on/off including bet invites, score updates, and result announcements.',
    ),

    // Troubleshooting
    FAQItem(
      id: '30',
      category: 'Troubleshooting',
      question: 'The app is running slowly. What should I do?',
      answer: 'Try these steps:\n1. Close and restart the app\n2. Check your internet connection\n3. Clear the app cache in Settings\n4. Make sure you have the latest version\n5. Restart your device\n\nIf issues persist, contact support.',
    ),
    FAQItem(
      id: '31',
      category: 'Troubleshooting',
      question: 'I\'m not receiving notifications. How do I fix this?',
      answer: 'Check that:\n1. Notifications are enabled in app Settings\n2. Notifications are allowed in your device settings\n3. You have an internet connection\n4. Your device isn\'t in Do Not Disturb mode\n\nGo to Settings > Notifications to verify.',
    ),
    FAQItem(
      id: '33',
      category: 'Troubleshooting',
      question: 'I forgot my password. How do I reset it?',
      answer: 'On the login screen, tap "Forgot Password?". Enter your email address and we\'ll send you a password reset link. Check your spam folder if you don\'t see the email within a few minutes.',
    ),
    FAQItem(
      id: '32',
      category: 'Troubleshooting',
      question: 'Scores aren\'t updating in real-time. Why?',
      answer: 'This usually happens due to poor internet connectivity. Make sure you have a stable connection. Scores will sync when connection is restored. If problems persist, try restarting the app.',
    ),
    FAQItem(
      id: '34',
      category: 'Troubleshooting',
      question: 'The app keeps crashing. What should I do?',
      answer: 'First, make sure you have the latest app version. If crashes continue:\n1. Uninstall and reinstall the app\n2. Check for device OS updates\n3. Free up device storage space\n4. Report the bug to our support team with details about when it crashes.',
    ),

    // Rules & Compliance
    FAQItem(
      id: '35',
      category: 'Rules & Compliance',
      question: 'Is this legal in my state?',
      answer: 'Betcha is a social platform for tracking friendly wagers between people who know each other. Laws vary by state. You are responsible for ensuring your use complies with local laws. We do not process real money transactions.',
    ),
    FAQItem(
      id: '36',
      category: 'Rules & Compliance',
      question: 'Do I need to pay taxes on my winnings?',
      answer: 'Points have no cash value, so there are no winnings to report. Any real-world settlements you arrange privately with other players are your responsibility. Consult a tax professional if you have questions.',
    ),
    FAQItem(
      id: '37',
      category: 'Rules & Compliance',
      question: 'What if someone doesn\'t pay their bet?',
      answer: 'Betcha only tracks bets in Points - we don\'t handle any money. Any real-world payments are private arrangements between players. We recommend only betting with people you know and trust.',
    ),
    FAQItem(
      id: '38',
      category: 'Rules & Compliance',
      question: 'Can I use this for business or commercial purposes?',
      answer: 'No, Betcha is intended for personal, non-commercial social use only. Commercial use, running tournaments for profit, or any business activities are prohibited.',
    ),

    // General
    FAQItem(
      id: '39',
      category: 'General',
      question: 'How do I contact support?',
      answer: 'Email us at support@betcha.com. We typically respond within 24-48 hours. For urgent issues, include "URGENT" in the subject line.',
    ),
    FAQItem(
      id: '40',
      category: 'General',
      question: 'Where can I suggest new features?',
      answer: 'We love feedback! Email suggestions to support@betcha.com or use the "Report a Problem" feature in Settings to share ideas.',
    ),
    FAQItem(
      id: '41',
      category: 'General',
      question: 'Is my data secure?',
      answer: 'Yes, we use industry-standard encryption and security measures. Read our Privacy Policy for details on how we protect your information.',
    ),
    FAQItem(
      id: '42',
      category: 'General',
      question: 'What devices are supported?',
      answer: 'Betcha is available for iOS (13.0+) and Android (8.0+) devices. We recommend keeping your device OS up to date for the best experience.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FAQItem> get filteredFAQ {
    return faqData.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.answer.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _toggleItem(String id) {
    setState(() {
      if (_expandedItems.contains(id)) {
        _expandedItems.remove(id);
      } else {
        _expandedItems.add(id);
      }
    });
  }

  Future<void> _contactSupport() async {
    final uri = Uri.parse('mailto:support@betcha.com?subject=Help Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredFAQ;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neonGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppTheme.neonBlue),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.darkSlateGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.neonBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.neonBlue.withAlpha(77)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.neonBlue, width: 2),
                ),
              ),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                    selectedColor: AppTheme.neonGreen,
                    backgroundColor: AppTheme.darkSlateGray,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.neonGreen
                          : AppTheme.neonBlue.withAlpha(77),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // FAQ List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Text(
                        '${filtered.length} ${filtered.length == 1 ? 'result' : 'results'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...filtered.map((item) => _buildFAQItem(item)),
                      const SizedBox(height: 24),
                      _buildQuickLinks(),
                      const SizedBox(height: 24),
                      _buildContactSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    final isExpanded = _expandedItems.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withAlpha(77)),
      ),
      child: InkWell(
        onTap: () => _toggleItem(item.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.question,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.neonGreen,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  item.answer,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 60,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or browse by category',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Links',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickLink(
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of Service coming soon!')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildQuickLink(
          icon: Icons.lock,
          title: 'Privacy Policy',
          subtitle: 'How we protect your data',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy Policy coming soon!')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildQuickLink(
          icon: Icons.bug_report,
          title: 'Report a Bug',
          subtitle: 'Help us improve the app',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bug report feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkSlateGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neonBlue.withAlpha(77)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.neonBlue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.neonGreen,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Still Need Help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Can\'t find what you\'re looking for? Our support team is here to help.',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _contactSupport,
              icon: const Icon(Icons.email, color: Colors.white),
              label: const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'Email: support@betcha.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Response time: 24-48 hours',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
