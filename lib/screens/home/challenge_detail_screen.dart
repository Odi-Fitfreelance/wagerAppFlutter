import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../config/app_theme.dart';
import '../../services/challenge_service.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _challenge;
  String _selectedCoinType = 'GC'; // 'GC' or 'SC'
  int _betAmount = 50;
  String? _selectedOutcome; // For Fail/Land: 'fail' or 'land'

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoLoadFailed = false;
  String? _videoErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  String _extractErrorMessage(String fullError) {
    if (fullError.contains('MediaCodecVideoRenderer')) {
      return 'Video codec not supported on this device';
    } else if (fullError.contains('network') || fullError.contains('timeout')) {
      return 'Network error loading video';
    } else if (fullError.contains('403') || fullError.contains('401')) {
      return 'Access denied to video';
    } else {
      return 'Unable to play video on this device';
    }
  }

  Future<void> _loadChallenge() async {
    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        print('🔍 Loading challenge detail for ID: ${widget.challengeId}');
      }

      final challengeService = ChallengeService(ApiClient());
      final challenge = await challengeService.getChallengeById(widget.challengeId);

      if (kDebugMode) {
        print('📦 Challenge data received:');
        print('   Keys in challenge: ${challenge.keys.toList()}');
        challenge.forEach((key, value) {
          print('   $key: $value');
        });
      }

      // Initialize video player
      if (challenge['videoUrl'] != null) {
        try {
          if (kDebugMode) {
            print('🎥 Initializing video player for: ${challenge['videoUrl']}');
          }

          _videoController = VideoPlayerController.networkUrl(
            Uri.parse(challenge['videoUrl']),
          );

          await _videoController!.initialize();

          if (kDebugMode) {
            print('✅ Video player initialized');
            print('   Duration: ${_videoController!.value.duration}');
            print('   Aspect ratio: ${_videoController!.value.aspectRatio}');
            print('   Size: ${_videoController!.value.size}');
          }

          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: true,
            aspectRatio: _videoController!.value.aspectRatio,
            showControls: true,
            placeholder: Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.neonBlue),
              ),
            ),
            errorBuilder: (context, errorMessage) {
              if (kDebugMode) {
                print('❌ Video player error: $errorMessage');
              }
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppTheme.hotPink, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading video',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage,
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } catch (videoError) {
          if (kDebugMode) {
            print('❌ Video initialization error: $videoError');
          }
          // Continue without video player - show thumbnail instead
          _videoController = null;
          _chewieController = null;
          _videoLoadFailed = true;
          _videoErrorMessage = _extractErrorMessage(videoError.toString());
        }
      }

      setState(() {
        _challenge = challenge;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading challenge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _closeChallenge(String outcome) async {
    if (_challenge == null) return;

    // Confirm action
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSlateGray,
        title: Text(
          'Close Challenge',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to close this challenge?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: outcome == 'land'
                    ? AppTheme.neonGreen.withAlpha(51)
                    : AppTheme.hotPink.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    outcome == 'land' ? Icons.check_circle : Icons.cancel,
                    color: outcome == 'land' ? AppTheme.neonGreen : AppTheme.hotPink,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Outcome: ${outcome.toUpperCase()}',
                    style: TextStyle(
                      color: outcome == 'land' ? AppTheme.neonGreen : AppTheme.hotPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will distribute payouts to winners and cannot be undone.',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: outcome == 'land' ? AppTheme.neonGreen : AppTheme.hotPink,
            ),
            child: const Text('Close Challenge'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final challengeService = ChallengeService(ApiClient());
      final result = await challengeService.closeChallenge(
        challengeId: widget.challengeId,
        outcome: outcome,
      );

      if (mounted) {
        Navigator.pop(context); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Challenge closed! ${result['winners']} winner(s), ${result['losers']} loser(s)',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error closing challenge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _placeBet() async {
    if (_challenge == null) return;

    final isFailLand = _challenge!['type'] == 'fail_land';

    if (isFailLand && _selectedOutcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select FAIL or LAND'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm bet
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSlateGray,
        title: Text(
          'Confirm Bet',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge: ${_challenge!['title']}',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            if (isFailLand) ...[
              const SizedBox(height: 8),
              Text(
                'Your prediction: ${_selectedOutcome!.toUpperCase()}',
                style: TextStyle(
                  color: _selectedOutcome == 'land'
                      ? AppTheme.neonGreen
                      : AppTheme.hotPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Bet amount: $_betAmount $_selectedCoinType',
              style: TextStyle(
                color: _selectedCoinType == 'GC'
                    ? AppTheme.goldCoin
                    : AppTheme.sweepsCoin,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonBlue),
            child: const Text('Place Bet'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final challengeService = ChallengeService(ApiClient());
      await challengeService.placeBet(
        challengeId: widget.challengeId,
        amount: _betAmount,
        coinType: _selectedCoinType.toLowerCase(),
        prediction: isFailLand ? _selectedOutcome : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bet placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing bet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _challenge == null) {
      return Scaffold(
        backgroundColor: AppTheme.deepNavy,
        appBar: AppBar(title: const Text('Challenge')),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.neonBlue),
        ),
      );
    }

    final isFailLand = _challenge!['type'] == 'fail_land';

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: Text(_challenge!['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Check out this challenge: ${_challenge!['title']}\n'
                'Total pot: ${_challenge!['totalPot']} GC\n'
                'Join now and place your bet!',
                subject: 'FriendlyWager Challenge',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video player
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.black,
                    child: _chewieController != null
                        ? Chewie(controller: _chewieController!)
                        : _videoLoadFailed
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Show thumbnail
                                  if (_challenge!['thumbnailUrl'] != null)
                                    Image.network(
                                      _challenge!['thumbnailUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(color: AppTheme.darkSlateGray);
                                      },
                                    ),
                                  // Error overlay
                                  Container(
                                    color: Colors.black.withAlpha(179),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              size: 64,
                                              color: AppTheme.electricYellow,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              _videoErrorMessage ?? 'Video unavailable',
                                              style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Challenge details are still available below',
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 13,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            OutlinedButton.icon(
                                              onPressed: () async {
                                                // Try opening in external browser
                                                final url = _challenge!['videoUrl'];
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Video URL: $url'),
                                                    action: SnackBarAction(
                                                      label: 'Copy',
                                                      onPressed: () {
                                                        // Could add clipboard copy here
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.open_in_browser, color: AppTheme.neonBlue),
                                              label: Text(
                                                'View video URL',
                                                style: TextStyle(color: AppTheme.neonBlue),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: AppTheme.neonBlue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _challenge!['thumbnailUrl'] != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        _challenge!['thumbnailUrl'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.videocam_off,
                                              size: 64,
                                              color: AppTheme.textMuted,
                                            ),
                                          );
                                        },
                                      ),
                                      Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          size: 80,
                                          color: AppTheme.neonBlue.withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.neonBlue,
                                    ),
                                  ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Challenge type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isFailLand
                                ? AppTheme.hotPink.withAlpha(51)
                                : AppTheme.neonBlue.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isFailLand ? 'FAIL / LAND' : 'HEAD-TO-HEAD',
                            style: TextStyle(
                              color: isFailLand
                                  ? AppTheme.hotPink
                                  : AppTheme.neonBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Creator info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.darkSlateGray,
                              child: Icon(
                                Icons.person,
                                color: AppTheme.neonBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _challenge!['creator'],
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '2 hours ago',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          _challenge!['description'],
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Betting stats
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.darkSlateGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Pot',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.monetization_on,
                                        size: 20,
                                        color: AppTheme.goldCoin,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_challenge!['totalPot']} GC',
                                        style: TextStyle(
                                          color: AppTheme.goldCoin,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              if (isFailLand) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildBettingStatBar(
                                        'FAIL',
                                        _challenge!['bettingStats']['fail'],
                                        _challenge!['totalPot'],
                                        AppTheme.hotPink,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildBettingStatBar(
                                        'LAND',
                                        _challenge!['bettingStats']['land'],
                                        _challenge!['totalPot'],
                                        AppTheme.neonGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Betting panel or Creator controls
          _buildBottomPanel(isFailLand),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(bool isFailLand) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.id;
    final creatorId = _challenge!['creatorId'];
    final isCreator = currentUserId == creatorId;
    final status = _challenge!['status'];
    final challengeType = _challenge!['type'];

    // If user is creator and challenge is open, show close challenge controls
    if (isCreator && status == 'open') {
      if (isFailLand) {
        return _buildFailLandCreatorControls();
      } else {
        return _buildHeadToHeadCreatorControls();
      }
    }

    // Otherwise show normal betting panel
    if (status == 'open') {
      return _buildBettingPanel(isFailLand);
    }

    // Challenge is closed - show status
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            'Challenge ${status.toUpperCase()}',
            style: TextStyle(
              color: status == 'completed' ? AppTheme.neonGreen : AppTheme.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailLandCreatorControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppTheme.neonBlue),
                const SizedBox(width: 8),
                Text(
                  'Declare Challenge Outcome',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _closeChallenge('fail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.hotPink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.cancel),
                    label: const Text(
                      'FAIL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _closeChallenge('land'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'LAND',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This will finalize the challenge and distribute winnings',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadToHeadCreatorControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppTheme.neonBlue),
                const SizedBox(width: 8),
                Text(
                  'Select Winner',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _showWinnerSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonBlue,
                ),
                icon: const Icon(Icons.emoji_events),
                label: const Text(
                  'CHOOSE WINNER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select the participant who won this challenge',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showWinnerSelection() async {
    if (_challenge == null) return;

    setState(() => _isLoading = true);

    try {
      final challengeService = ChallengeService(ApiClient());
      final participants = await challengeService.getChallengeParticipants(widget.challengeId);

      setState(() => _isLoading = false);

      if (participants.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No participants to select from'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final winnerId = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.darkSlateGray,
          title: Text(
            'Select Winner',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.hotPink,
                    child: Text(
                      participant['username'].substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '@${participant['username']}',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: Icon(Icons.chevron_right, color: AppTheme.neonBlue),
                  onTap: () => Navigator.pop(context, participant['userId']),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      );

      if (winnerId != null) {
        await _closeHeadToHeadChallenge(winnerId);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading participants: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _closeHeadToHeadChallenge(String winnerId) async {
    setState(() => _isLoading = true);

    try {
      final challengeService = ChallengeService(ApiClient());
      final result = await challengeService.closeChallenge(
        challengeId: widget.challengeId,
        winnerId: winnerId,
      );

      if (mounted) {
        Navigator.pop(context); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Challenge closed! 1 winner, ${result['losers']} loser(s)',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error closing challenge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBettingStatBar(
    String label,
    int amount,
    int total,
    Color color,
  ) {
    // Handle case where total is 0 or amount is 0
    final percentage = total > 0 ? (amount / total * 100).toStringAsFixed(0) : '0';
    final progressValue = total > 0 ? (amount / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: color.withAlpha(51),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBettingPanel(bool isFailLand) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFailLand) ...[
              // Outcome selector for Fail/Land
              Row(
                children: [
                  Expanded(
                    child: _buildOutcomeButton(
                      'fail',
                      'FAIL',
                      AppTheme.hotPink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOutcomeButton(
                      'land',
                      'LAND',
                      AppTheme.neonGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Coin type selector
            Row(
              children: [
                Expanded(child: _buildCoinTypeButton('GC', AppTheme.goldCoin)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCoinTypeButton('SC', AppTheme.sweepsCoin),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bet amount slider
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: _selectedCoinType == 'GC'
                      ? AppTheme.goldCoin
                      : AppTheme.sweepsCoin,
                ),
                Expanded(
                  child: Slider(
                    value: _betAmount.toDouble(),
                    min: 10,
                    max: 500,
                    divisions: 49,
                    label: '$_betAmount $_selectedCoinType',
                    activeColor: _selectedCoinType == 'GC'
                        ? AppTheme.goldCoin
                        : AppTheme.sweepsCoin,
                    onChanged: (value) {
                      setState(() => _betAmount = value.toInt());
                    },
                  ),
                ),
                Text(
                  '$_betAmount',
                  style: TextStyle(
                    color: _selectedCoinType == 'GC'
                        ? AppTheme.goldCoin
                        : AppTheme.sweepsCoin,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Place bet button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _placeBet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonBlue,
                ),
                child: Text(
                  'PLACE BET',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeButton(String value, String label, Color color) {
    final isSelected = _selectedOutcome == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedOutcome = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(51) : AppTheme.deepNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinTypeButton(String coinType, Color color) {
    final isSelected = _selectedCoinType == coinType;

    return GestureDetector(
      onTap: () => setState(() => _selectedCoinType = coinType),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(51) : AppTheme.deepNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            coinType,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
