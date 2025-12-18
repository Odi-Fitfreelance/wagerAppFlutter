import 'package:json_annotation/json_annotation.dart';

part 'leaderboard.g.dart';

enum LeaderboardPeriod {
  @JsonValue('week')
  week,
  @JsonValue('month')
  month,
  @JsonValue('all_time')
  allTime,
}

enum TrendDirection {
  @JsonValue('up')
  up,
  @JsonValue('down')
  down,
  @JsonValue('same')
  same,
}

@JsonSerializable()
class LeaderboardEntry {
  final int rank;
  @JsonKey(name: 'user_id')
  final String userId;
  final String username;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  final int points;
  @JsonKey(name: 'total_wins')
  final int totalWins;
  @JsonKey(name: 'total_bets')
  final int totalBets;
  @JsonKey(name: 'win_rate')
  final double winRate;
  final TrendDirection? trend;
  @JsonKey(name: 'rank_change')
  final int? rankChange;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.points,
    required this.totalWins,
    required this.totalBets,
    required this.winRate,
    this.trend,
    this.rankChange,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);
}
