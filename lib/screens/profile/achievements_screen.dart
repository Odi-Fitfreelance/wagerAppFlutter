import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/user_service.dart';
import '../../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final userService = UserService(ApiClient());
      _achievements = await userService.getAchievements();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstBet:
        return Icons.emoji_events;
      case AchievementType.winner:
        return Icons.star;
      case AchievementType.hotStreak:
        return Icons.local_fire_department;
      case AchievementType.eagleEye:
        return Icons.visibility;
      case AchievementType.centuryClub:
        return Icons.military_tech;
      case AchievementType.socialButterfly:
        return Icons.people;
    }
  }

  Color _getAchievementColor(AchievementType type) {
    switch (type) {
      case AchievementType.firstBet:
        return AppTheme.electricYellow;
      case AchievementType.winner:
        return AppTheme.neonGreen;
      case AchievementType.hotStreak:
        return const Color(0xFFFF4500);
      case AchievementType.eagleEye:
        return AppTheme.neonBlue;
      case AchievementType.centuryClub:
        return AppTheme.richPurple;
      case AchievementType.socialButterfly:
        return AppTheme.hotPink;
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
          'Achievements',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.hotPink),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: AppTheme.hotPink),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadAchievements,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _achievements.isEmpty
                  ? const Center(
                      child: Text(
                        'No achievements yet',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAchievements,
                      color: AppTheme.hotPink,
                      backgroundColor: AppTheme.darkSlateGray,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _achievements.length,
                        itemBuilder: (context, index) {
                          final achievement = _achievements[index];
                          return _buildAchievementCard(achievement);
                        },
                      ),
                    ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final color = _getAchievementColor(achievement.type);
    final isUnlocked = achievement.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withAlpha(26),
                  AppTheme.darkSlateGray,
                ],
              )
            : null,
        color: isUnlocked ? null : AppTheme.darkSlateGray.withAlpha(128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? color.withAlpha(77) : AppTheme.textMuted,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isUnlocked ? color.withAlpha(26) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? color : AppTheme.textMuted,
                  width: 2,
                ),
              ),
              child: Icon(
                _getAchievementIcon(achievement.type),
                size: 32,
                color: isUnlocked ? color : AppTheme.textMuted,
              ),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              achievement.name,
              style: TextStyle(
                color: isUnlocked ? AppTheme.textPrimary : AppTheme.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Description
            Text(
              achievement.description,
              style: TextStyle(
                color: isUnlocked ? AppTheme.textSecondary : AppTheme.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Points or Progress
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, color: color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${achievement.points} pts',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else if (achievement.progress != null &&
                achievement.target != null) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: achievement.progressPercentage,
                backgroundColor: AppTheme.textMuted.withAlpha(51),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              const SizedBox(height: 4),
              Text(
                '${achievement.progress}/${achievement.target}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Locked',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
