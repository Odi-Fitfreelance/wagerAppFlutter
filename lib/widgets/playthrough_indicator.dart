import 'package:flutter/material.dart';

class PlaythroughIndicator extends StatelessWidget {
  final int redeemableSc;
  final int playthroughRemaining;
  final bool showDetails;
  final VoidCallback? onTap;

  const PlaythroughIndicator({
    super.key,
    required this.redeemableSc,
    required this.playthroughRemaining,
    this.showDetails = true,
    this.onTap,
  });

  double get progress {
    final total = redeemableSc + playthroughRemaining;
    if (total == 0) return 100.0;
    return (redeemableSc / total) * 100;
  }

  bool get isComplete => playthroughRemaining == 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isComplete ? Icons.check_circle : Icons.timeline,
                        color: isComplete ? Colors.green : Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Playthrough Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isComplete ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : Colors.blue,
                  ),
                ),
              ),

              if (showDetails) ...[
                const SizedBox(height: 12),
                // Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DetailItem(
                      icon: Icons.check_circle_outline,
                      label: 'Redeemable',
                      value: '$redeemableSc SC',
                      color: Colors.green,
                    ),
                    _DetailItem(
                      icon: Icons.pending_outlined,
                      label: 'Remaining',
                      value: '$playthroughRemaining SC',
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Explanation
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isComplete
                              ? 'All SC are redeemable! You can now redeem for prizes.'
                              : 'Play bets with SC to unlock redemption. Each SC must be played once.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
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
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Compact version for smaller spaces
class CompactPlaythroughIndicator extends StatelessWidget {
  final int redeemableSc;
  final int playthroughRemaining;

  const CompactPlaythroughIndicator({
    super.key,
    required this.redeemableSc,
    required this.playthroughRemaining,
  });

  double get progress {
    final total = redeemableSc + playthroughRemaining;
    if (total == 0) return 100.0;
    return (redeemableSc / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Playthrough',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ],
    );
  }
}

/// Minimal badge showing playthrough status
class PlaythroughBadge extends StatelessWidget {
  final int redeemableSc;
  final int playthroughRemaining;

  const PlaythroughBadge({
    super.key,
    required this.redeemableSc,
    required this.playthroughRemaining,
  });

  bool get isComplete => playthroughRemaining == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.hourglass_empty,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isComplete ? 'Redeemable' : '$playthroughRemaining SC to go',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
