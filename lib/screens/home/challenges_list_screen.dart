import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/challenge_service.dart';
import '../../services/api_client.dart';
import 'challenge_detail_screen.dart';

class ChallengesListScreen extends StatefulWidget {
  const ChallengesListScreen({super.key});

  @override
  State<ChallengesListScreen> createState() => _ChallengesListScreenState();
}

class _ChallengesListScreenState extends State<ChallengesListScreen> {
  String _selectedFilter = 'all'; // 'all', 'fail_land', 'head_to_head'
  bool _isLoading = true;
  List<Map<String, dynamic>> _challenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);

    try {
      final challengeService = ChallengeService(ApiClient());
      final fetchedChallenges = await challengeService.getChallenges(
        type: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      setState(() {
        _challenges = fetchedChallenges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading challenges: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredChallenges {
    if (_selectedFilter == 'all') return _challenges;
    return _challenges.where((c) => c['type'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('Challenges'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChallenges,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Fail / Land', 'fail_land'),
                const SizedBox(width: 8),
                _buildFilterChip('Head-to-Head', 'head_to_head'),
              ],
            ),
          ),

          // Challenges list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppTheme.neonBlue),
                  )
                : _filteredChallenges.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadChallenges,
                    color: AppTheme.neonBlue,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredChallenges.length,
                      itemBuilder: (context, index) {
                        return _buildChallengeCard(_filteredChallenges[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: AppTheme.darkSlateGray,
      selectedColor: AppTheme.neonBlue.withAlpha(77),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.neonBlue : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: AppTheme.neonBlue,
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    final isFailLand = challenge['type'] == 'fail_land';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challengeId: challenge['id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.darkSlateGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFailLand
                ? AppTheme.hotPink.withAlpha(77)
                : AppTheme.neonBlue.withAlpha(77),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.deepNavy,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail image
                  if (challenge['thumbnailUrl'] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        challenge['thumbnailUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 64,
                              color: AppTheme.textMuted,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppTheme.neonBlue,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.videocam_outlined,
                        size: 64,
                        color: AppTheme.textMuted,
                      ),
                    ),

                  // Play button overlay
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 48,
                        color: AppTheme.neonBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Challenge info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
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
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    challenge['title'],
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Creator
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        challenge['creator'],
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      // Total pot
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 20,
                            color: AppTheme.goldCoin,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge['totalPot']} GC',
                            style: TextStyle(
                              color: AppTheme.goldCoin,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),

                      // Participants
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge['participants']} betting',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 64,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No challenges found',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a challenge to get started!',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
