// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      userId: json['user_id'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      points: (json['points'] as num).toInt(),
      totalWins: (json['total_wins'] as num).toInt(),
      totalBets: (json['total_bets'] as num).toInt(),
      winRate: (json['win_rate'] as num).toDouble(),
      trend: $enumDecodeNullable(_$TrendDirectionEnumMap, json['trend']),
      rankChange: (json['rank_change'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(LeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'user_id': instance.userId,
      'username': instance.username,
      'profile_image_url': instance.profileImageUrl,
      'points': instance.points,
      'total_wins': instance.totalWins,
      'total_bets': instance.totalBets,
      'win_rate': instance.winRate,
      'trend': _$TrendDirectionEnumMap[instance.trend],
      'rank_change': instance.rankChange,
    };

const _$TrendDirectionEnumMap = {
  TrendDirection.up: 'up',
  TrendDirection.down: 'down',
  TrendDirection.same: 'same',
};
