import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../models/transaction.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadTransactions();
    });
  }

  void _applyFilter(String? filter) {
    setState(() {
      _selectedFilter = filter;
    });
    context.read<WalletProvider>().loadTransactions(type: filter);
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.betPlaced:
        return 'Bet Placed';
      case TransactionType.betWon:
        return 'Bet Won';
      case TransactionType.betRefund:
        return 'Refund';
      case TransactionType.pointsPurchase:
        return 'Points Purchase';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.storePurchase:
        return 'Store Purchase';
      case TransactionType.outsideBetPlaced:
        return 'Outside Bet';
      case TransactionType.outsideBetWon:
        return 'Outside Bet Won';
      case TransactionType.achievementBonus:
        return 'Achievement Bonus';
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.betPlaced:
      case TransactionType.outsideBetPlaced:
        return Icons.casino_outlined;
      case TransactionType.betWon:
      case TransactionType.outsideBetWon:
        return Icons.emoji_events;
      case TransactionType.betRefund:
        return Icons.replay;
      case TransactionType.pointsPurchase:
        return Icons.add_circle_outline;
      case TransactionType.withdrawal:
        return Icons.account_balance_wallet_outlined;
      case TransactionType.storePurchase:
        return Icons.shopping_bag_outlined;
      case TransactionType.achievementBonus:
        return Icons.stars;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AppTheme.neonBlue),
            color: AppTheme.darkSlateGray,
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Transactions'),
              ),
              const PopupMenuItem(
                value: 'bet_placed',
                child: Text('Bets Placed'),
              ),
              const PopupMenuItem(
                value: 'bet_won',
                child: Text('Bets Won'),
              ),
              const PopupMenuItem(
                value: 'points_purchase',
                child: Text('Purchases'),
              ),
              const PopupMenuItem(
                value: 'withdrawal',
                child: Text('Withdrawals'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          if (walletProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.hotPink,
              ),
            );
          }

          if (walletProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.hotPink,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    walletProvider.errorMessage!,
                    style: const TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      walletProvider.loadTransactions(type: _selectedFilter);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final transactions = walletProvider.transactions;

          if (transactions.isEmpty) {
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
                  Text(
                    _selectedFilter == null
                        ? 'No transactions yet'
                        : 'No transactions found',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                walletProvider.loadTransactions(type: _selectedFilter),
            color: AppTheme.hotPink,
            backgroundColor: AppTheme.darkSlateGray,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppTheme.neonGreen : AppTheme.hotPink;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(51),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTransactionIcon(transaction.type),
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          _getTransactionTypeLabel(transaction.type),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null) ...[
              const SizedBox(height: 4),
              Text(
                transaction.description!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Balance: ${transaction.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
