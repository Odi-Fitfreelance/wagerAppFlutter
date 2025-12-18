// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
  id: json['id'] as String,
  type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
  name: json['name'] as String,
  description: json['description'] as String,
  iconUrl: json['icon_url'] as String?,
  points: (json['points'] as num).toInt(),
  isUnlocked: json['is_unlocked'] as bool,
  unlockedAt: json['unlocked_at'] == null
      ? null
      : DateTime.parse(json['unlocked_at'] as String),
  progress: (json['progress'] as num?)?.toInt(),
  target: (json['target'] as num?)?.toInt(),
);

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'points': instance.points,
      'is_unlocked': instance.isUnlocked,
      'unlocked_at': instance.unlockedAt?.toIso8601String(),
      'progress': instance.progress,
      'target': instance.target,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.firstBet: 'first_bet',
  AchievementType.winner: 'winner',
  AchievementType.hotStreak: 'hot_streak',
  AchievementType.eagleEye: 'eagle_eye',
  AchievementType.centuryClub: 'century_club',
  AchievementType.socialButterfly: 'social_butterfly',
};
