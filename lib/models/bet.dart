import 'package:json_annotation/json_annotation.dart';

part 'bet.g.dart';

enum BetStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('open')
  open,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum BetType {
  @JsonValue('stroke')
  stroke,
  @JsonValue('skins')
  skins,
  @JsonValue('custom')
  custom,
}

@JsonSerializable()
class Bet {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'creator_id')
  final String creatorId;
  @JsonKey(name: 'bet_code')
  final String? betCode;
  @JsonKey(name: 'bet_type')
  final BetType betType;
  @JsonKey(name: 'stake_amount')
  final num stakeAmount;
  @JsonKey(name: 'stake_currency')
  final String? stakeCurrency;
  @JsonKey(name: 'total_pot')
  final num totalPot;
  @JsonKey(name: 'max_players')
  final int? maxPlayers;
  @JsonKey(name: 'current_players')
  final int currentPlayers;
  final String? location;
  @JsonKey(name: 'course_name')
  final String? courseName;
  final num? latitude;
  final num? longitude;
  @JsonKey(name: 'scheduled_start_time')
  final DateTime? scheduledStartTime;
  @JsonKey(name: 'actual_start_time')
  final DateTime? actualStartTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final BetStatus status;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'allow_outside_backers')
  final bool allowOutsideBackers;
  final Map<String, dynamic>? settings;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'odds_last_updated')
  final DateTime? oddsLastUpdated;
  @JsonKey(name: 'odds_calculation_method')
  final String? oddsCalculationMethod;
  @JsonKey(name: 'course_id')
  final String? courseId;

  Bet({
    required this.id,
    required this.name,
    this.description,
    required this.creatorId,
    this.betCode,
    required this.betType,
    required this.stakeAmount,
    this.stakeCurrency,
    required this.totalPot,
    this.maxPlayers,
    required this.currentPlayers,
    this.location,
    this.courseName,
    this.latitude,
    this.longitude,
    this.scheduledStartTime,
    this.actualStartTime,
    this.endTime,
    required this.status,
    required this.isPublic,
    this.allowOutsideBackers = false,
    this.settings,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.oddsLastUpdated,
    this.oddsCalculationMethod,
    this.courseId,
  });

  factory Bet.fromJson(Map<String, dynamic> json) => _$BetFromJson(json);
  Map<String, dynamic> toJson() => _$BetToJson(this);
}

@JsonSerializable()
class BetParticipant {
  final String id;
  @JsonKey(name: 'bet_id')
  final String betId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String username;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  @JsonKey(name: 'is_ready')
  final bool isReady;
  @JsonKey(name: 'current_score')
  final int? currentScore;
  @JsonKey(name: 'to_par')
  final int? toPar;
  final int? position;
  final double? payout;
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  BetParticipant({
    required this.id,
    required this.betId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.isReady,
    this.currentScore,
    this.toPar,
    this.position,
    this.payout,
    required this.joinedAt,
  });

  factory BetParticipant.fromJson(Map<String, dynamic> json) =>
      _$BetParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$BetParticipantToJson(this);
}

@JsonSerializable()
class BetOdds {
  @JsonKey(name: 'user_id')
  final String userId;
  final String username;
  final double odds;
  @JsonKey(name: 'win_probability')
  final double winProbability;
  @JsonKey(name: 'current_position')
  final int currentPosition;

  BetOdds({
    required this.userId,
    required this.username,
    required this.odds,
    required this.winProbability,
    required this.currentPosition,
  });

  factory BetOdds.fromJson(Map<String, dynamic> json) =>
      _$BetOddsFromJson(json);
  Map<String, dynamic> toJson() => _$BetOddsToJson(this);
}
