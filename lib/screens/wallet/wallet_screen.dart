// ignore_for_file: unused_element

import 'package:betcha_flutter/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/kyc_provider.dart';
import '../../widgets/coin_balance_card.dart';
import '../../widgets/playthrough_indicator.dart';
import '../settings/settings_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'bundle_purchase_screen.dart';
import 'redeem_screen.dart';
import 'amoe_screen.dart';
import '../kyc/kyc_status_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _hasLoadedTransactions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final walletProvider = context.read<WalletProvider>();
    final kycProvider = context.read<KYCProvider>();
    await Future.wait([
      walletProvider.loadBalance(),
      walletProvider.loadBundles(),
      walletProvider.loadStats(),
      kycProvider.loadStatus(),
    ]);
  }

  Future<void> _handleRefresh() async {
    final authProvider = context.read<AuthProvider>();
    final walletProvider = context.read<WalletProvider>();
    final kycProvider = context.read<KYCProvider>();

    // Reset transaction load flag to allow reloading
    _hasLoadedTransactions = false;

    await Future.wait([
      authProvider.refreshUser(),
      walletProvider.loadBalance(),
      walletProvider.loadBundles(),
      walletProvider.loadStats(),
      walletProvider.loadTransactions(),
      kycProvider.loadStatus(),
    ]);

    // Mark transactions as loaded after refresh
    _hasLoadedTransactions = true;
  }

  Future<void> _handlePurchasePoints(int amount, String price) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSlateGray,
        title: const Text(
          'Purchase Points',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Purchase $amount points for \$$price?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.neonBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Purchase',
              style: TextStyle(color: AppTheme.hotPink),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final walletProvider = context.read<WalletProvider>();
      await walletProvider.purchasePoints(amount.toString(), packageId: '');

      if (mounted) {
        await context.read<AuthProvider>().refreshUser();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$amount points added to your wallet!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSlateGray,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.neonBlue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.hotPink),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String username) {
    final parts = username.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      body: SafeArea(
        child: Consumer3<AuthProvider, WalletProvider, KYCProvider>(
          builder: (context, authProvider, walletProvider, kycProvider, child) {
            final user = authProvider.user;

            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.hotPink),
              );
            }

            final stats = walletProvider.stats;

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppTheme.hotPink,
              backgroundColor: AppTheme.darkSlateGray,
              child: Column(
                children: [
                  // Header with Settings Icon
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Wallet',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: AppTheme.neonBlue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // User Profile Card
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.darkSlateGray,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.neonBlue.withAlpha(77),
                              ),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: AppTheme.hotPink,
                                  backgroundImage: user.profileImageUrl != null
                                      ? NetworkImage(user.profileImageUrl!)
                                      : null,
                                  child: user.profileImageUrl == null
                                      ? Text(
                                          _getInitials(user.username),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'View Profile',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.neonBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Dual Coin Balance Cards
                        DualCoinBalance(
                          gcBalance: walletProvider.gcBalance,
                          scBalance: walletProvider.scBalance,
                          gcEscrow: walletProvider.walletBalance?.escrowGc,
                          scEscrow: walletProvider.walletBalance?.escrowSc,
                        ),

                        const SizedBox(height: 16),

                        // Playthrough Indicator
                        if (walletProvider.scBalance > 0)
                          PlaythroughIndicator(
                            redeemableSc: walletProvider.redeemableSc,
                            playthroughRemaining:
                                walletProvider.scPlaythroughRemaining,
                          ),

                        const SizedBox(height: 16),

                        // Quick Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const BundlePurchaseScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Buy Coins'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.hotPink,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RedeemScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                icon: const Icon(Icons.card_giftcard),
                                label: const Text('Redeem SC'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Secondary Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AMOEScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                icon: const Icon(
                                  Icons.stars,
                                  color: Color(0xFF4CAF50),
                                ),
                                label: const Text(
                                  'Free SC',
                                  style: TextStyle(color: AppTheme.textPrimary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF4CAF50),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Consumer<KYCProvider>(
                                builder: (context, kycProvider, child) {
                                  return OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const KYCStatusScreen(),
                                        ),
                                      ).then((_) => _loadData());
                                    },
                                    icon: Icon(
                                      kycProvider.isApproved
                                          ? Icons.verified_user
                                          : Icons.verified_user_outlined,
                                      color: kycProvider.isApproved
                                          ? Colors.green
                                          : AppTheme.neonBlue,
                                    ),
                                    label: Text(
                                      kycProvider.isApproved
                                          ? 'Verified'
                                          : 'Verify ID',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      side: BorderSide(
                                        color: kycProvider.isApproved
                                            ? Colors.green
                                            : AppTheme.neonBlue,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Tabs
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.darkSlateGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: AppTheme.hotPink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: AppTheme.textSecondary,
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            tabs: const [
                              Tab(text: 'Overview'),
                              Tab(text: 'History'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tab Content
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Overview Tab
                              _buildOverviewTab(stats),

                              // History Tab
                              _buildHistoryTab(walletProvider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab(WalletStats? stats) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Color(0xFF4CAF50)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Play with GC for fun or SC for prizes! SC can be redeemed for gift cards.',
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats Section
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard(
                '${stats?.totalWins ?? 0 + (stats?.totalLosses ?? 0)}',
                'Total Bets',
                AppTheme.neonBlue,
              ),
              _buildStatCard(
                '${stats?.totalWins ?? 0}',
                'Wins',
                AppTheme.neonGreen,
              ),
              _buildStatCard(
                '${((stats?.winRate ?? 0) * 100).toStringAsFixed(1)}%',
                'Win Rate',
                AppTheme.electricYellow,
              ),
              _buildStatCard(
                '${stats?.lifetimePointsEarned.toInt() ?? 0}',
                'Points Won',
                AppTheme.hotPink,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppTheme.hotPink, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppTheme.hotPink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              'Points can be redeemed in the Store for gift cards and golf gear',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(WalletProvider walletProvider) {
    // Only load transactions once when tab is first viewed
    if (walletProvider.transactions.isEmpty && !_hasLoadedTransactions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasLoadedTransactions) {
          _hasLoadedTransactions = true;
          walletProvider.loadTransactions();
        }
      });
    }

    if (walletProvider.isLoading && walletProvider.transactions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.hotPink),
      );
    }

    if (walletProvider.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions yet',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your transaction history will appear here',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: walletProvider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = walletProvider.transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildPurchaseButton(int points, String price, {String? badge}) {
    return InkWell(
      onTap: _isLoading ? null : () => _handlePurchasePoints(points, price),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkSlateGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.hotPink, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Points',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$$price',
                  style: const TextStyle(fontSize: 14, color: AppTheme.hotPink),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.electricYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            if (_isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.hotPink,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withAlpha(77)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ignore: strict_top_level_inference
  Widget _buildTransactionCard(transaction) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppTheme.neonGreen : AppTheme.hotPink;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTransactionIcon(transaction.type),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(transaction.type),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: strict_top_level_inference
  IconData _getTransactionIcon(type) {
    switch (type.toString()) {
      case 'TransactionType.purchase':
      case 'TransactionType.pointsPurchase':
      case 'TransactionType.bundlePurchase':
        return Icons.add_circle_outline;
      case 'TransactionType.betPlaced':
      case 'TransactionType.outsideBetPlaced':
        return Icons.casino_outlined;
      case 'TransactionType.betWon':
      case 'TransactionType.outsideBetWon':
        return Icons.emoji_events;
      case 'TransactionType.betLost':
        return Icons.trending_down;
      case 'TransactionType.redeem':
      case 'TransactionType.scRedemption':
        return Icons.card_giftcard;
      case 'TransactionType.betRefund':
      case 'TransactionType.betCancelled':
        return Icons.replay;
      case 'TransactionType.scBonus':
      case 'TransactionType.amoeGrant':
      case 'TransactionType.viralMilestoneBonus':
      case 'TransactionType.referralBonus':
        return Icons.stars;
      case 'TransactionType.playthroughProgress':
        return Icons.trending_up;
      case 'TransactionType.platformFee':
        return Icons.receipt;
      default:
        return Icons.monetization_on;
    }
  }

  // ignore: strict_top_level_inference
  String _getTransactionTitle(type) {
    switch (type.toString()) {
      case 'TransactionType.purchase':
      case 'TransactionType.pointsPurchase':
        return 'Points Purchase';
      case 'TransactionType.bundlePurchase':
        return 'Bundle Purchase';
      case 'TransactionType.scBonus':
        return 'Free SC Bonus';
      case 'TransactionType.scRedemption':
        return 'SC Redeemed';
      case 'TransactionType.amoeGrant':
        return 'Free SC (AMOE)';
      case 'TransactionType.viralMilestoneBonus':
        return 'Viral Milestone Bonus';
      case 'TransactionType.referralBonus':
        return 'Referral Bonus';
      case 'TransactionType.playthroughProgress':
        return 'Playthrough Progress';
      case 'TransactionType.platformFee':
        return 'Platform Fee';
      case 'TransactionType.betPlaced':
        return 'Bet Placed';
      case 'TransactionType.betWon':
        return 'Bet Won';
      case 'TransactionType.betLost':
        return 'Bet Lost';
      case 'TransactionType.redeem':
        return 'Store Redemption';
      case 'TransactionType.betRefund':
        return 'Refund';
      case 'TransactionType.withdrawal':
        return 'Withdrawal';
      case 'TransactionType.outsideBetPlaced':
        return 'Outside Bet';
      case 'TransactionType.outsideBetWon':
        return 'Outside Bet Won';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.month}/${date.day}/${date.year}';
  }
}
