import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../betting/bets_screen.dart';
import '../social/social_feed_screen.dart';
import 'challenges_list_screen.dart';
import 'create_challenge_screen.dart';
import 'profile_screen.dart';

/// Main navigation with bottom tabs
/// Features challenges list as home with FAB to create new challenges
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChallengesListScreen(), // Home - Browse video challenges
    const BetsScreen(), // My Bets
    const SocialFeedScreen(), // Social Feed
    const ProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              heroTag: 'main_nav_create_challenge',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateChallengeScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.neonGreen,
              icon: const Icon(Icons.add),
              label: const Text(
                'NEW CHALLENGE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.deepNavy,
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.video_library,
                  label: 'Challenges',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.golf_course,
                  label: 'My Bets',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.feed_outlined,
                  label: 'Social',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool hasLiveDot = false,
  }) {
    final isSelected = _currentIndex == index;
    final iconColor = isSelected ? AppTheme.hotPink : AppTheme.textSecondary;
    final textColor = isSelected ? AppTheme.hotPink : AppTheme.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: iconColor,
                  ),
                  if (hasLiveDot)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen,
                          shape: BoxShape.circle,
                          boxShadow: [AppTheme.neonGlow(AppTheme.neonGreen, blurRadius: 8)],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
