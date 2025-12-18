import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/social_provider.dart';
import '../../models/leaderboard.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'all_time';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadLeaderboard();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLeaderboard() {
    final socialProvider = context.read<SocialProvider>();
    if (_tabController.index == 0) {
      socialProvider.loadGlobalLeaderboard(period: _selectedPeriod);
    } else {
      socialProvider.loadFriendsLeaderboard(period: _selectedPeriod);
    }
  }

  void _changePeriod(String period) {
    setState(() => _selectedPeriod = period);
    _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.hotPink,
          labelColor: AppTheme.hotPink,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Friends'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today, color: AppTheme.neonBlue),
            color: AppTheme.darkSlateGray,
            onSelected: _changePeriod,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('This Week'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('This Month'),
              ),
              const PopupMenuItem(
                value: 'all_time',
                child: Text('All Time'),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GlobalLeaderboardTab(),
          _FriendsLeaderboardTab(),
        ],
      ),
    );
  }
}

class _GlobalLeaderboardTab extends StatelessWidget {
  const _GlobalLeaderboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        if (socialProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.hotPink),
          );
        }

        if (socialProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.hotPink),
                const SizedBox(height: 16),
                Text(
                  socialProvider.errorMessage!,
                  style: const TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    socialProvider.loadGlobalLeaderboard();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final entries = socialProvider.globalLeaderboard;

        if (entries.isEmpty) {
          return const Center(
            child: Text(
              'No leaderboard data available',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => socialProvider.loadGlobalLeaderboard(),
          color: AppTheme.hotPink,
          backgroundColor: AppTheme.darkSlateGray,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) =>
                _LeaderboardCard(entry: entries[index]),
          ),
        );
      },
    );
  }
}

class _FriendsLeaderboardTab extends StatelessWidget {
  const _FriendsLeaderboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        if (socialProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.hotPink),
          );
        }

        if (socialProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.hotPink),
                const SizedBox(height: 16),
                Text(
                  socialProvider.errorMessage!,
                  style: const TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final entries = socialProvider.friendsLeaderboard;

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Follow friends to see their rankings',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => socialProvider.loadFriendsLeaderboard(),
          color: AppTheme.hotPink,
          backgroundColor: AppTheme.darkSlateGray,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) =>
                _LeaderboardCard(entry: entries[index]),
          ),
        );
      },
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardCard({required this.entry});

  Color _getRankColor(int rank) {
    if (rank == 1) return AppTheme.electricYellow;
    if (rank == 2) return AppTheme.textSecondary;
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppTheme.neonBlue;
  }

  IconData _getTrendIcon(TrendDirection? trend) {
    if (trend == null) return Icons.remove;
    switch (trend) {
      case TrendDirection.up:
        return Icons.arrow_upward;
      case TrendDirection.down:
        return Icons.arrow_downward;
      case TrendDirection.same:
        return Icons.remove;
    }
  }

  Color _getTrendColor(TrendDirection? trend) {
    if (trend == null) return AppTheme.textMuted;
    switch (trend) {
      case TrendDirection.up:
        return AppTheme.neonGreen;
      case TrendDirection.down:
        return AppTheme.hotPink;
      case TrendDirection.same:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(entry.rank);
    final isTopThree = entry.rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isTopThree
            ? LinearGradient(
                colors: [
                  rankColor.withAlpha(26),
                  AppTheme.darkSlateGray,
                ],
              )
            : null,
        color: isTopThree ? null : AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(16),
        border: isTopThree
            ? Border.all(color: rankColor.withAlpha(51), width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: rankColor.withAlpha(26),
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: TextStyle(
                    color: rankColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '@${entry.username}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (entry.trend != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTrendColor(entry.trend).withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTrendIcon(entry.trend),
                                size: 12,
                                color: _getTrendColor(entry.trend),
                              ),
                              if (entry.rankChange != null &&
                                  entry.rankChange != 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '${entry.rankChange!.abs()}',
                                  style: TextStyle(
                                    color: _getTrendColor(entry.trend),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.stars,
                        label: '${entry.points} pts',
                        color: AppTheme.electricYellow,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        icon: Icons.emoji_events,
                        label: '${entry.totalWins}W',
                        color: AppTheme.neonGreen,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        icon: Icons.percent,
                        label: '${(entry.winRate * 100).toInt()}%',
                        color: AppTheme.neonBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.deepNavy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
