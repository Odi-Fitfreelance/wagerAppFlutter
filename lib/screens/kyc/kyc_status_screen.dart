import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/kyc_session.dart';
import '../../providers/kyc_provider.dart';

class KYCStatusScreen extends StatefulWidget {
  const KYCStatusScreen({super.key});

  @override
  State<KYCStatusScreen> createState() => _KYCStatusScreenState();
}

class _KYCStatusScreenState extends State<KYCStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Load KYC status when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KYCProvider>().loadStatus();
    });
  }

  Color _getStatusColor(KYCStatus status) {
    switch (status) {
      case KYCStatus.approved:
        return Colors.green;
      case KYCStatus.pending:
      case KYCStatus.manualReview:
        return Colors.orange;
      case KYCStatus.rejected:
        return Colors.red;
      case KYCStatus.notSubmitted:
        return Colors.grey;
      case KYCStatus.completed:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(KYCStatus status) {
    switch (status) {
      case KYCStatus.approved:
        return Icons.check_circle;
      case KYCStatus.pending:
      case KYCStatus.manualReview:
        return Icons.hourglass_empty;
      case KYCStatus.rejected:
        return Icons.cancel;
      case KYCStatus.notSubmitted:
        return Icons.info_outline;
      case KYCStatus.completed:
        return Icons.done;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KYCProvider>().loadStatus();
            },
          ),
        ],
      ),
      body: Consumer<KYCProvider>(
        builder: (context, kycProvider, child) {
          if (kycProvider.isLoading && kycProvider.session == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = kycProvider.session;
          if (session == null) {
            return _buildNotSubmittedView();
          }

          final statusColor = _getStatusColor(session.status);
          final statusIcon = _getStatusIcon(session.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: statusColor, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Status Icon
                        Icon(statusIcon, size: 80, color: statusColor),
                        const SizedBox(height: 16),

                        // Status Text
                        Text(
                          session.statusText,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Status Message
                        Text(
                          kycProvider.getStatusMessage(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Details Section
                if (session.submittedAt != null) ...[
                  _DetailCard(
                    icon: Icons.calendar_today,
                    title: 'Submitted',
                    value: _formatDate(session.submittedAt!),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                ],

                if (session.reviewedAt != null) ...[
                  _DetailCard(
                    icon: Icons.done_all,
                    title: 'Reviewed',
                    value: _formatDate(session.reviewedAt!),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                ],

                if (session.isPending) ...[
                  _DetailCard(
                    icon: Icons.timer,
                    title: 'Estimated Review Time',
                    value: kycProvider.getEstimatedReviewTime(),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                ],

                if (session.sessionId != null) ...[
                  _DetailCard(
                    icon: Icons.confirmation_number,
                    title: 'Session ID',
                    value: '${session.sessionId!.substring(0, 12)}...',
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                ],

                // Rejection Reason
                if (session.isRejected && session.rejectionReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Rejection Reason',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          session.rejectionReason!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                if (session.canRetry) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/kyc/submit');
                      },
                      icon: Icon(session.isRejected ? Icons.refresh : Icons.verified_user),
                      label: Text(
                        session.isRejected ? 'Retry Verification' : 'Start Verification',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                if (session.isApproved) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/wallet/redeem');
                      },
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text(
                        'Redeem Sweeps Coins',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Help/Support
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.blue),
                    title: const Text('Need Help?'),
                    subtitle: const Text('Contact support for assistance'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to support screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support feature coming soon'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotSubmittedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Verification Not Submitted',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Complete identity verification to unlock Sweeps Coins features like betting with SC and redeeming prizes.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/kyc/submit');
                },
                icon: const Icon(Icons.verified_user),
                label: const Text(
                  'Start Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Text(
                    'Why verify?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '✓ Required by law for SC redemption\n'
                    '✓ Unlocks SC betting features\n'
                    '✓ Protects your account\n'
                    '✓ Takes only 2-3 minutes',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
