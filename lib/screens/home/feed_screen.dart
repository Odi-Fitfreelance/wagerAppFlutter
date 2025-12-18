import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Main feed screen - TikTok style challenge feed
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();

  // Mock challenge data
  final List<Map<String, dynamic>> _challenges = [
    {
      'id': 1,
      'title': 'Kickflip over 4 steps',
      'description': 'Can Jake land this trick?',
      'username': 'Sora',
      'failOdds': '1.8x',
      'landOdds': '2.2x',
      'totalBets': '1,142 bets',
      'coins': '543 coins',
    },
    {
      'id': 2,
      'title': 'Solve 3x3 cube in under 60s',
      'description': 'Speed cubing challenge!',
      'username': 'Lina',
      'failOdds': '1.5x',
      'landOdds': '2.8x',
      'totalBets': '974 bets',
      'coins': '423 coins',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _challenges.length,
        itemBuilder: (context, index) {
          final challenge = _challenges[index];
          return _buildChallengeCard(challenge);
        },
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Stack(
      children: [
        // Video placeholder (would be actual video player)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkSlateGray,
                AppTheme.deepNavy,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 80,
              color: AppTheme.neonBlue.withValues(alpha: 0.5),
            ),
          ),
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        // Challenge info and betting UI
        SafeArea(
          child: Column(
            children: [
              // Top bar with coins
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BETCHA!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neonGreen,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSlateGray,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.electricYellow, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.monetization_on, color: AppTheme.electricYellow, size: 20),
                          SizedBox(width: 4),
                          Text(
                            '146',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Bottom section with bet info
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challenge title
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.deepNavy.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge['title'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppTheme.hotPink,
                                child: Text(
                                  challenge['username'][0],
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '@${challenge['username']}',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              Spacer(),
                              Icon(Icons.remove_red_eye, size: 16, color: AppTheme.textSecondary),
                              SizedBox(width: 4),
                              Text(
                                challenge['totalBets'],
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Betting buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildBetButton(
                            label: 'FAIL',
                            odds: challenge['failOdds'],
                            decoration: AppTheme.failButtonDecoration,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildBetButton(
                            label: 'LAND',
                            odds: challenge['landOdds'],
                            decoration: AppTheme.landButtonDecoration,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Bet stats
                    Center(
                      child: Text(
                        '${challenge['totalBets']} • Join ${challenge['coins']} stake',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBetButton({
    required String label,
    required String odds,
    required BoxDecoration decoration,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Show bet confirmation dialog
        _showBetDialog(label, odds);
      },
      child: Container(
        height: 80,
        decoration: decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              odds,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBetDialog(String choice, String odds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSlateGray,
        title: Text(
          'Place Bet',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Bet on $choice at $odds odds?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Place bet
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
