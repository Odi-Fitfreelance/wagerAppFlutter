import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/bet.dart';
import '../../providers/bet_provider.dart';
import '../../providers/auth_provider.dart';

class ScoreEntrySheet extends StatefulWidget {
  final Bet bet;

  const ScoreEntrySheet({super.key, required this.bet});

  @override
  State<ScoreEntrySheet> createState() => _ScoreEntrySheetState();
}

class _ScoreEntrySheetState extends State<ScoreEntrySheet> {
  int _selectedHole = 1;
  int _strokes = 4; // Default par
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final betProvider = context.read<BetProvider>();
      final authProvider = context.read<AuthProvider>();

      betProvider.loadParticipants(widget.bet.id).then((_) {
        betProvider.loadScores(widget.bet.id).then((_) {
          // Find the first incomplete hole
          final myParticipant = betProvider.participants
              .where((p) => p.userId == authProvider.user?.id)
              .firstOrNull;

          if (myParticipant != null) {
            final myScores = betProvider.scores
                .where((s) => s.userId == myParticipant.id)
                .toList();

            // Find first hole without a score
            int firstIncompleteHole = 1;
            for (int hole = 1; hole <= 18; hole++) {
              if (!myScores.any((s) => s.holeNumber == hole)) {
                firstIncompleteHole = hole;
                break;
              }
            }

            setState(() {
              _selectedHole = firstIncompleteHole;
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.deepNavy,
            AppTheme.darkSlateGray,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bet.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.bet.courseName != null)
                      Text(
                        widget.bet.courseName!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          const Divider(color: AppTheme.textMuted, height: 1),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hole selector
                  _buildHoleSelector(),

                  const SizedBox(height: 24),

                  // Score input
                  _buildScoreInput(),

                  const SizedBox(height: 24),

                  // Leaderboard
                  _buildLeaderboard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Select Hole',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 18,
            itemBuilder: (context, index) {
              final holeNumber = index + 1;
              final isSelected = _selectedHole == holeNumber;

              // Check if this hole has been scored
              final betProvider = context.watch<BetProvider>();
              final authProvider = context.read<AuthProvider>();

              // Find my participant ID first
              final myParticipant = betProvider.participants
                  .where((p) => p.userId == authProvider.user?.id)
                  .firstOrNull;

              final myScores = betProvider.scores
                  .where((s) => myParticipant != null && s.userId == myParticipant.id)
                  .toList();
              final hasScore = myScores.any((s) => s.holeNumber == holeNumber);

              // Determine if this hole can be selected
              // Can select: completed holes OR the next sequential incomplete hole
              // Players can score independently without waiting for others
              bool canSelect = hasScore || (myScores.isEmpty && holeNumber == 1) ||
                  (myScores.isNotEmpty &&
                   myScores.any((s) => s.holeNumber == holeNumber - 1));

              return GestureDetector(
                onTap: canSelect ? () {
                  setState(() {
                    _selectedHole = holeNumber;
                    _strokes = 4; // Reset to default
                  });
                } : null,
                child: Opacity(
                  opacity: canSelect ? 1.0 : 0.3,
                  child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.hotPink
                        : hasScore
                            ? AppTheme.neonGreen.withAlpha(51)
                            : AppTheme.darkSlateGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.hotPink
                          : hasScore
                              ? AppTheme.neonGreen
                              : AppTheme.textMuted,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$holeNumber',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : hasScore
                                  ? AppTheme.neonGreen
                                  : AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasScore)
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.neonGreen,
                          size: 12,
                        ),
                    ],
                  ),
                ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScoreInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSlateGray,
            AppTheme.darkSlateGray.withAlpha(179),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.hotPink.withAlpha(51)),
      ),
      child: Column(
        children: [
          Text(
            'Hole $_selectedHole',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Par 4', // TODO: Get actual par from course data
            style: TextStyle(
              color: AppTheme.electricYellow,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _strokes > 1
                    ? () => setState(() => _strokes--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppTheme.neonBlue,
                iconSize: 40,
              ),
              const SizedBox(width: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.deepNavy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.hotPink, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$_strokes',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: _strokes < 15
                    ? () => setState(() => _strokes++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppTheme.neonBlue,
                iconSize: 40,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitScore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.hotPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit Score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Consumer<BetProvider>(
      builder: (context, betProvider, child) {
        final participants = betProvider.participants;

        if (kDebugMode) {
          print('🏆 Building leaderboard: ${participants.length} participants, ${betProvider.scores.length} scores');
        }

        if (participants.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.hotPink),
            ),
          );
        }

        // Calculate total scores for each participant
        final participantScores = participants.map((participant) {
          // Match scores by participant.id (not userId) since Score.userId is actually participant_id
          final scores = betProvider.scores
              .where((s) => s.userId == participant.id)
              .toList();
          final totalStrokes = scores.fold<int>(0, (sum, s) => sum + s.strokes);
          final holesPlayed = scores.length;
          final toPar = scores.fold<int>(0, (sum, s) => sum + s.toPar);

          if (kDebugMode) {
            print('  ${participant.username}: ${scores.length} scores, total=$totalStrokes, toPar=$toPar');
          }

          return {
            'participant': participant,
            'totalStrokes': totalStrokes,
            'holesPlayed': holesPlayed,
            'toPar': toPar,
          };
        }).toList();

        // Sort by total strokes (ascending)
        participantScores.sort((a, b) =>
          (a['totalStrokes'] as int).compareTo(b['totalStrokes'] as int));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Leaderboard',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: participantScores.length,
              itemBuilder: (context, index) {
                final data = participantScores[index];
                final participant = data['participant'] as BetParticipant;
                final totalStrokes = data['totalStrokes'] as int;
                final holesPlayed = data['holesPlayed'] as int;
                final toPar = data['toPar'] as int;
                final position = index + 1;

                final authProvider = context.read<AuthProvider>();
                final isCurrentUser = participant.userId == authProvider.user?.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? AppTheme.hotPink.withAlpha(26)
                        : AppTheme.darkSlateGray.withAlpha(128),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentUser
                          ? AppTheme.hotPink.withAlpha(77)
                          : AppTheme.textMuted.withAlpha(51),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Position
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: position == 1
                              ? AppTheme.electricYellow
                              : AppTheme.deepNavy,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$position',
                            style: TextStyle(
                              color: position == 1
                                  ? Colors.black
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Player name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              participant.username,
                              style: TextStyle(
                                color: isCurrentUser
                                    ? AppTheme.hotPink
                                    : AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$holesPlayed/18 holes',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Score
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$totalStrokes',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            toPar > 0 ? '+$toPar' : toPar < 0 ? '$toPar' : 'E',
                            style: TextStyle(
                              color: toPar < 0
                                  ? AppTheme.neonGreen
                                  : toPar > 0
                                      ? Colors.red
                                      : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitScore() async {
    setState(() => _isSubmitting = true);

    try {
      final betProvider = context.read<BetProvider>();
      final authProvider = context.read<AuthProvider>();

      await betProvider.submitScore(
        betId: widget.bet.id,
        holeNumber: _selectedHole,
        strokes: _strokes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hole $_selectedHole score submitted!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload scores to update leaderboard
        await betProvider.loadScores(widget.bet.id);
        await betProvider.loadParticipants(widget.bet.id);

        // Find next incomplete hole
        final myParticipant = betProvider.participants
            .where((p) => p.userId == authProvider.user?.id)
            .firstOrNull;

        if (myParticipant != null) {
          final myScores = betProvider.scores
              .where((s) => s.userId == myParticipant.id)
              .toList();

          // Find next hole without a score
          int? nextIncompleteHole;
          for (int hole = _selectedHole + 1; hole <= 18; hole++) {
            if (!myScores.any((s) => s.holeNumber == hole)) {
              nextIncompleteHole = hole;
              break;
            }
          }

          // If we found an incomplete hole, move to it
          if (nextIncompleteHole != null) {
            setState(() {
              _selectedHole = nextIncompleteHole!;
              _strokes = 4; // Reset to default
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
