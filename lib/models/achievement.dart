import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

enum AchievementType {
  @JsonValue('first_bet')
  firstBet,
  @JsonValue('winner')
  winner,
  @JsonValue('hot_streak')
  hotStreak,
  @JsonValue('eagle_eye')
  eagleEye,
  @JsonValue('century_club')
  centuryClub,
  @JsonValue('social_butterfly')
  socialButterfly,
}

@JsonSerializable()
class Achievement {
  final String id;
  final AchievementType type;
  final String name;
  final String description;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  final int points;
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @JsonKey(name: 'unlocked_at')
  final DateTime? unlockedAt;
  final int? progress;
  final int? target;

  Achievement({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.points,
    required this.isUnlocked,
    this.unlockedAt,
    this.progress,
    this.target,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  double get progressPercentage {
    if (target == null || progress == null) return 0.0;
    return (progress! / target!).clamp(0.0, 1.0);
  }
}
