import 'package:flutter/material.dart';

enum CurrencyType { gc, sc }

class CurrencySelector extends StatelessWidget {
  final CurrencyType selectedCurrency;
  final ValueChanged<CurrencyType> onChanged;
  final int gcBalance;
  final int scBalance;
  final bool scEnabled;
  final String? scDisabledReason;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
    required this.gcBalance,
    required this.scBalance,
    this.scEnabled = true,
    this.scDisabledReason,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Currency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CurrencyOption(
                type: CurrencyType.gc,
                label: 'Gold Coins',
                balance: gcBalance,
                icon: Icons.monetization_on,
                color: const Color(0xFFFFD700),
                isSelected: selectedCurrency == CurrencyType.gc,
                isEnabled: true,
                onTap: () => onChanged(CurrencyType.gc),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CurrencyOption(
                type: CurrencyType.sc,
                label: 'Sweeps Coins',
                balance: scBalance,
                icon: Icons.stars,
                color: const Color(0xFF4CAF50),
                isSelected: selectedCurrency == CurrencyType.sc,
                isEnabled: scEnabled,
                disabledReason: scDisabledReason,
                onTap: scEnabled ? () => onChanged(CurrencyType.sc) : null,
              ),
            ),
          ],
        ),
        if (!scEnabled && scDisabledReason != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scDisabledReason!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final CurrencyType type;
  final String label;
  final int balance;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isEnabled;
  final String? disabledReason;
  final VoidCallback? onTap;

  const _CurrencyOption({
    required this.type,
    required this.label,
    required this.balance,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isEnabled,
    this.disabledReason,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isEnabled ? 1.0 : 0.5;

    return InkWell(
      onTap: isEnabled ? onTap : () => _showDisabledDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),

              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Balance
              Text(
                _formatNumber(balance),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                type == CurrencyType.gc ? 'GC' : 'SC',
                style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
              ),

              // Lock icon if disabled
              if (!isEnabled) ...[
                const SizedBox(height: 8),
                const Icon(Icons.lock_outline, size: 20, color: Colors.grey),
              ],

              // Selected indicator
              if (isSelected) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SELECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDisabledDialog(BuildContext context) {
    if (disabledReason != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: color),
              const SizedBox(width: 8),
              const Text('SC Betting Locked'),
            ],
          ),
          content: Text(disabledReason!),
          actions: [
            if (disabledReason!.contains('KYC') ||
                disabledReason!.contains('verify'))
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/kyc/submit');
                },
                child: const Text('Verify Now'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Compact toggle version
class CompactCurrencySelector extends StatelessWidget {
  final CurrencyType selectedCurrency;
  final ValueChanged<CurrencyType> onChanged;
  final bool scEnabled;

  const CompactCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
    this.scEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompactOption(
            label: 'GC',
            icon: Icons.monetization_on,
            color: const Color(0xFFFFD700),
            isSelected: selectedCurrency == CurrencyType.gc,
            onTap: () => onChanged(CurrencyType.gc),
          ),
          _CompactOption(
            label: 'SC',
            icon: Icons.stars,
            color: const Color(0xFF4CAF50),
            isSelected: selectedCurrency == CurrencyType.sc,
            isEnabled: scEnabled,
            onTap: scEnabled ? () => onChanged(CurrencyType.sc) : null,
          ),
        ],
      ),
    );
  }
}

class _CompactOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _CompactOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    this.isEnabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
              if (!isEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
