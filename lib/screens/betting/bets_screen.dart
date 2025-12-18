import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/bet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/bet.dart';
import 'create_bet_screen.dart';
import 'score_entry_sheet.dart';

class BetsScreen extends StatefulWidget {
  const BetsScreen({super.key});

  @override
  State<BetsScreen> createState() => _BetsScreenState();
}

class _BetsScreenState extends State<BetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final betProvider = context.read<BetProvider>();
      betProvider.loadPublicBets();
      betProvider.loadMyBets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bets',
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
            Tab(text: 'Public Bets'),
            Tab(text: 'My Bets'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.neonBlue),
            onPressed: () {
              final betProvider = context.read<BetProvider>();
              betProvider.loadPublicBets();
              betProvider.loadMyBets();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PublicBetsTab(),
          _MyBetsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateBetScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.hotPink,
        icon: const Icon(Icons.add),
        label: const Text('Create Bet'),
      ),
    );
  }
}

class _PublicBetsTab extends StatelessWidget {
  const _PublicBetsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<BetProvider>(
      builder: (context, betProvider, child) {
        if (betProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.hotPink),
          );
        }

        if (betProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.hotPink),
                const SizedBox(height: 16),
                Text(
                  betProvider.errorMessage!,
                  style: const TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final bets = betProvider.publicBets;

        if (bets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.casino_outlined,
                  size: 64,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No public bets available',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateBetScreen(),
                      ),
                    );
                  },
                  child: const Text('Create First Bet'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => betProvider.loadPublicBets(),
          color: AppTheme.hotPink,
          backgroundColor: AppTheme.darkSlateGray,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bets.length,
            itemBuilder: (context, index) => _BetCard(bet: bets[index], isMyBet: false),
          ),
        );
      },
    );
  }
}

class _MyBetsTab extends StatelessWidget {
  const _MyBetsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<BetProvider>(
      builder: (context, betProvider, child) {
        if (betProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.hotPink),
          );
        }

        final bets = betProvider.myBets;

        if (bets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_golf,
                  size: 64,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(height: 16),
                const Text(
                  'You haven\'t joined any bets yet',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => betProvider.loadMyBets(),
          color: AppTheme.hotPink,
          backgroundColor: AppTheme.darkSlateGray,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bets.length,
            itemBuilder: (context, index) => _BetCard(bet: bets[index], isMyBet: true),
          ),
        );
      },
    );
  }
}

class _BetCard extends StatelessWidget {
  final Bet bet;
  final bool isMyBet;

  const _BetCard({required this.bet, required this.isMyBet});

  bool _shouldShowJoinButton(BuildContext context, Bet bet) {
    // Don't show if bet is not open or pending
    if (bet.status != BetStatus.pending && bet.status != BetStatus.open) {
      return false;
    }

    // Don't show if user is the creator
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user?.id == bet.creatorId) {
      return false;
    }

    // Don't show if bet is full
    if (bet.maxPlayers != null && bet.currentPlayers >= bet.maxPlayers!) {
      return false;
    }

    // Check if user has already joined by checking myBets
    final betProvider = context.watch<BetProvider>();
    final hasJoined = betProvider.myBets.any((myBet) => myBet.id == bet.id);

    return !hasJoined;
  }

  bool _shouldShowScoreButton(Bet bet) {
    return bet.status == BetStatus.inProgress;
  }

  bool _shouldShowReadyButton(BuildContext context, Bet bet) {
    // Show ready button for non-creator participants when bet is pending/open
    if (bet.status != BetStatus.pending && bet.status != BetStatus.open) {
      return false;
    }

    final authProvider = context.read<AuthProvider>();
    return authProvider.user?.id != bet.creatorId;
  }

  bool _shouldShowStartButton(BuildContext context, Bet bet) {
    // Show start button for creator only when bet has max players
    if (bet.status != BetStatus.pending && bet.status != BetStatus.open) {
      return false;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.user?.id != bet.creatorId) {
      return false;
    }

    // Check if bet has reached max players
    return bet.maxPlayers != null && bet.currentPlayers >= bet.maxPlayers!;
  }

  String _getBetTypeLabel(BetType type) {
    switch (type) {
      case BetType.stroke:
        return 'Stroke Play';
      case BetType.skins:
        return 'Skins';
      case BetType.custom:
        return 'Custom';
    }
  }

  String _getStatusLabel(BetStatus status) {
    switch (status) {
      case BetStatus.pending:
        return 'Pending';
      case BetStatus.open:
        return 'Open';
      case BetStatus.inProgress:
        return 'In Progress';
      case BetStatus.active:
        return 'Active';
      case BetStatus.completed:
        return 'Completed';
      case BetStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(BetStatus status) {
    switch (status) {
      case BetStatus.pending:
        return AppTheme.electricYellow;
      case BetStatus.open:
        return AppTheme.neonGreen;
      case BetStatus.inProgress:
        return AppTheme.neonBlue;
      case BetStatus.active:
        return AppTheme.neonBlue;
      case BetStatus.completed:
        return AppTheme.neonBlue;
      case BetStatus.cancelled:
        return AppTheme.hotPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSlateGray,
            AppTheme.darkSlateGray.withAlpha(179),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(bet.status).withAlpha(51),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to bet details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bet.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(bet.status).withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusLabel(bet.status),
                        style: TextStyle(
                          color: _getStatusColor(bet.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.category_outlined,
                      _getBetTypeLabel(bet.betType),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.people_outline,
                      '${bet.currentPlayers}/${bet.maxPlayers}',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.attach_money,
                      '${bet.stakeAmount.toInt()} pts',
                    ),
                  ],
                ),
                if (bet.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bet.location!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pot: ${bet.totalPot.toInt()} pts',
                      style: TextStyle(
                        color: AppTheme.electricYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isMyBet && _shouldShowJoinButton(context, bet))
                      OutlinedButton(
                        onPressed: () async {
                          final betProvider = context.read<BetProvider>();
                          final success = await betProvider.joinBet(bet.id);

                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Successfully joined bet!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Refresh both tabs
                              betProvider.loadPublicBets();
                              betProvider.loadMyBets();
                            } else if (betProvider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(betProvider.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              betProvider.clearError();
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.neonBlue,
                          side: BorderSide(color: AppTheme.neonBlue),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Join'),
                      ),
                    if (isMyBet && _shouldShowScoreButton(bet))
                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ScoreEntrySheet(bet: bet),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.hotPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Score'),
                      ),
                    if (isMyBet && _shouldShowReadyButton(context, bet))
                      ElevatedButton(
                        onPressed: () async {
                          final betProvider = context.read<BetProvider>();
                          final success = await betProvider.updateReadyStatus(bet.id, true);

                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Marked as ready!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              betProvider.loadMyBets();
                            } else if (betProvider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(betProvider.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              betProvider.clearError();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Ready'),
                      ),
                    if (isMyBet && _shouldShowStartButton(context, bet))
                      ElevatedButton(
                        onPressed: () async {
                          final betProvider = context.read<BetProvider>();
                          final success = await betProvider.startBet(bet.id);

                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bet started!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              betProvider.loadMyBets();
                              betProvider.loadPublicBets();
                            } else if (betProvider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(betProvider.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              betProvider.clearError();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.electricYellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Start'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.deepNavy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.neonBlue, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
