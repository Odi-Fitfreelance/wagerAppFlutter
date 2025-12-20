import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/bet.dart';
import '../../providers/bet_provider.dart';
import '../../providers/auth_provider.dart';

class BetDetailsScreen extends StatefulWidget {
  final Bet bet;

  const BetDetailsScreen({super.key, required this.bet});

  @override
  State<BetDetailsScreen> createState() => _BetDetailsScreenState();
}

class _BetDetailsScreenState extends State<BetDetailsScreen> {
  bool _isLoading = true;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final betProvider = context.read<BetProvider>();
    await betProvider.loadParticipants(widget.bet.id);
    if (widget.bet.allowOutsideBackers) {
      await betProvider.loadBetOdds(widget.bet.id);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinBet() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    // Check if user has enough balance
    if (authProvider.user!.walletBalance < widget.bet.stakeAmount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient balance to join this bet'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSlateGray,
        title: const Text(
          'Join Bet',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Join "${widget.bet.name}" for ${widget.bet.stakeAmount} points?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.neonBlue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join', style: TextStyle(color: AppTheme.hotPink)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isJoining = true);

    try {
      final betProvider = context.read<BetProvider>();
      await betProvider.joinBet(widget.bet.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined bet!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join bet: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  String _getStatusText() {
    switch (widget.bet.status) {
      case BetStatus.open:
        return 'Open';
      case BetStatus.inProgress:
      case BetStatus.active:
        return 'In Progress';
      case BetStatus.completed:
        return 'Completed';
      case BetStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor() {
    switch (widget.bet.status) {
      case BetStatus.open:
        return AppTheme.neonGreen;
      case BetStatus.inProgress:
      case BetStatus.active:
        return AppTheme.electricYellow;
      case BetStatus.completed:
        return AppTheme.neonBlue;
      case BetStatus.cancelled:
        return AppTheme.hotPink;
      default:
        return AppTheme.textMuted;
    }
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
          'Bet Details',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.hotPink),
            )
          : Consumer<BetProvider>(
              builder: (context, betProvider, child) {
                final participants = betProvider.participants;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getStatusColor()),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bet Name
                      Text(
                        widget.bet.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      if (widget.bet.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.bet.description!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Pot Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [AppTheme.neonGlow(AppTheme.hotPink)],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total Pot',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.bet.totalPot.toInt()} pts',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Stake: ${widget.bet.stakeAmount.toInt()} pts • ${widget.bet.betType.name}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bet Info
                      _buildInfoSection(),

                      const SizedBox(height: 24),

                      // Participants
                      const Text(
                        'Participants',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.bet.currentPlayers}${widget.bet.maxPlayers != null ? "/${widget.bet.maxPlayers}" : ""} players',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (participants.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.darkSlateGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'No participants yet',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      else
                        ...participants.map((participant) => _buildParticipantCard(participant)),

                      const SizedBox(height: 24),

                      // Outside Backing Info
                      if (widget.bet.allowOutsideBackers && widget.bet.status == BetStatus.inProgress) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.darkSlateGray,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.neonBlue.withAlpha(77)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Outside Betting Available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'This bet allows outside backers to bet on participants.',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Outside betting feature coming soon!'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.neonBlue,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Place Outside Bet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Join Button (only for open bets)
                      if (widget.bet.status == BetStatus.open)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isJoining ? null : _joinBet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isJoining
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Join Bet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (widget.bet.location != null)
            _buildInfoRow(Icons.location_on, 'Location', widget.bet.location!),
          if (widget.bet.courseName != null) ...[
            if (widget.bet.location != null) const Divider(color: AppTheme.textMuted, height: 24),
            _buildInfoRow(Icons.golf_course, 'Course', widget.bet.courseName!),
          ],
          if (widget.bet.scheduledStartTime != null) ...[
            const Divider(color: AppTheme.textMuted, height: 24),
            _buildInfoRow(
              Icons.schedule,
              'Scheduled',
              '${widget.bet.scheduledStartTime!.month}/${widget.bet.scheduledStartTime!.day}/${widget.bet.scheduledStartTime!.year}',
            ),
          ],
          const Divider(color: AppTheme.textMuted, height: 24),
          _buildInfoRow(
            Icons.visibility,
            'Visibility',
            widget.bet.isPublic ? 'Public' : 'Private',
          ),
          if (widget.bet.allowOutsideBackers) ...[
            const Divider(color: AppTheme.textMuted, height: 24),
            _buildInfoRow(
              Icons.people_outline,
              'Outside Backers',
              'Allowed',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.neonBlue, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(BetParticipant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withAlpha(77)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.hotPink,
            backgroundImage: participant.profileImageUrl != null
                ? NetworkImage(participant.profileImageUrl!)
                : null,
            child: participant.profileImageUrl == null
                ? Text(
                    participant.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (participant.toPar != null)
                  Text(
                    'Score: ${participant.toPar! > 0 ? "+" : ""}${participant.toPar}',
                    style: TextStyle(
                      fontSize: 12,
                      color: participant.toPar! < 0
                          ? AppTheme.neonGreen
                          : participant.toPar! > 0
                              ? AppTheme.hotPink
                              : AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (participant.position != null && participant.position! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: participant.position == 1
                    ? AppTheme.electricYellow.withAlpha(51)
                    : AppTheme.neonBlue.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                participant.position == 1 ? '👑 1st' : '#${participant.position}',
                style: TextStyle(
                  color: participant.position == 1 ? AppTheme.electricYellow : AppTheme.neonBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
