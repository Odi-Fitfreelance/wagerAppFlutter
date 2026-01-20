import 'package:flutter/material.dart';

class CoinBalanceCard extends StatelessWidget {
  final String coinType; // 'gc' or 'sc'
  final int balance;
  final int? escrowAmount;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showEscrow;

  const CoinBalanceCard({
    super.key,
    required this.coinType,
    required this.balance,
    this.escrowAmount,
    this.subtitle,
    this.onTap,
    this.showEscrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isGC = coinType.toLowerCase() == 'gc';
    final color = isGC ? const Color(0xFFFFD700) : const Color(0xFF4CAF50);
    final icon = isGC ? Icons.monetization_on : Icons.stars;
    final title = isGC ? 'Gold Coins' : 'Sweeps Coins';
    final suffix = isGC ? 'GC' : 'SC';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 16),

              // Balance
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatNumber(balance),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      suffix,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),

              // Escrow info
              if (showEscrow && escrowAmount != null && escrowAmount! > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatNumber(escrowAmount!)} $suffix in active bets',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Compact version for smaller spaces
class CompactCoinBalance extends StatelessWidget {
  final String coinType; // 'gc' or 'sc'
  final int balance;
  final VoidCallback? onTap;

  const CompactCoinBalance({
    super.key,
    required this.coinType,
    required this.balance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGC = coinType.toLowerCase() == 'gc';
    final color = isGC ? const Color(0xFFFFD700) : const Color(0xFF4CAF50);
    final icon = isGC ? Icons.monetization_on : Icons.stars;
    final suffix = isGC ? 'GC' : 'SC';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              '${_formatNumber(balance)} $suffix',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Displays both GC and SC side by side
class DualCoinBalance extends StatelessWidget {
  final int gcBalance;
  final int scBalance;
  final int? gcEscrow;
  final int? scEscrow;
  final VoidCallback? onGCTap;
  final VoidCallback? onSCTap;

  const DualCoinBalance({
    super.key,
    required this.gcBalance,
    required this.scBalance,
    this.gcEscrow,
    this.scEscrow,
    this.onGCTap,
    this.onSCTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CoinBalanceCard(
            coinType: 'gc',
            balance: gcBalance,
            escrowAmount: gcEscrow,
            subtitle: 'Social Play',
            onTap: onGCTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CoinBalanceCard(
            coinType: 'sc',
            balance: scBalance,
            escrowAmount: scEscrow,
            subtitle: 'Redeemable',
            onTap: onSCTap,
          ),
        ),
      ],
    );
  }
}
