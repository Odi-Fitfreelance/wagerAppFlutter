// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bet _$BetFromJson(Map<String, dynamic> json) => Bet(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  creatorId: json['creator_id'] as String,
  betCode: json['bet_code'] as String?,
  betType: $enumDecode(_$BetTypeEnumMap, json['bet_type']),
  stakeAmount: json['stake_amount'] as num,
  stakeCurrency: json['stake_currency'] as String?,
  totalPot: json['total_pot'] as num,
  maxPlayers: (json['max_players'] as num?)?.toInt(),
  currentPlayers: (json['current_players'] as num).toInt(),
  location: json['location'] as String?,
  courseName: json['course_name'] as String?,
  latitude: json['latitude'] as num?,
  longitude: json['longitude'] as num?,
  scheduledStartTime: json['scheduled_start_time'] == null
      ? null
      : DateTime.parse(json['scheduled_start_time'] as String),
  actualStartTime: json['actual_start_time'] == null
      ? null
      : DateTime.parse(json['actual_start_time'] as String),
  endTime: json['end_time'] == null
      ? null
      : DateTime.parse(json['end_time'] as String),
  status: $enumDecode(_$BetStatusEnumMap, json['status']),
  isPublic: json['is_public'] as bool,
  allowOutsideBackers: json['allow_outside_backers'] as bool? ?? false,
  settings: json['settings'] as Map<String, dynamic>?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  oddsLastUpdated: json['odds_last_updated'] == null
      ? null
      : DateTime.parse(json['odds_last_updated'] as String),
  oddsCalculationMethod: json['odds_calculation_method'] as String?,
  courseId: json['course_id'] as String?,
);

Map<String, dynamic> _$BetToJson(Bet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'creator_id': instance.creatorId,
  'bet_code': instance.betCode,
  'bet_type': _$BetTypeEnumMap[instance.betType]!,
  'stake_amount': instance.stakeAmount,
  'stake_currency': instance.stakeCurrency,
  'total_pot': instance.totalPot,
  'max_players': instance.maxPlayers,
  'current_players': instance.currentPlayers,
  'location': instance.location,
  'course_name': instance.courseName,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'scheduled_start_time': instance.scheduledStartTime?.toIso8601String(),
  'actual_start_time': instance.actualStartTime?.toIso8601String(),
  'end_time': instance.endTime?.toIso8601String(),
  'status': _$BetStatusEnumMap[instance.status]!,
  'is_public': instance.isPublic,
  'allow_outside_backers': instance.allowOutsideBackers,
  'settings': instance.settings,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'odds_last_updated': instance.oddsLastUpdated?.toIso8601String(),
  'odds_calculation_method': instance.oddsCalculationMethod,
  'course_id': instance.courseId,
};

const _$BetTypeEnumMap = {
  BetType.stroke: 'stroke',
  BetType.skins: 'skins',
  BetType.custom: 'custom',
};

const _$BetStatusEnumMap = {
  BetStatus.pending: 'pending',
  BetStatus.open: 'open',
  BetStatus.inProgress: 'in_progress',
  BetStatus.active: 'active',
  BetStatus.completed: 'completed',
  BetStatus.cancelled: 'cancelled',
};

BetParticipant _$BetParticipantFromJson(Map<String, dynamic> json) =>
    BetParticipant(
      id: json['id'] as String,
      betId: json['bet_id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      isReady: json['is_ready'] as bool,
      currentScore: (json['current_score'] as num?)?.toInt(),
      toPar: (json['to_par'] as num?)?.toInt(),
      position: (json['position'] as num?)?.toInt(),
      payout: (json['payout'] as num?)?.toDouble(),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$BetParticipantToJson(BetParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bet_id': instance.betId,
      'user_id': instance.userId,
      'username': instance.username,
      'profile_image_url': instance.profileImageUrl,
      'is_ready': instance.isReady,
      'current_score': instance.currentScore,
      'to_par': instance.toPar,
      'position': instance.position,
      'payout': instance.payout,
      'joined_at': instance.joinedAt.toIso8601String(),
    };

BetOdds _$BetOddsFromJson(Map<String, dynamic> json) => BetOdds(
  userId: json['user_id'] as String,
  username: json['username'] as String,
  odds: (json['odds'] as num).toDouble(),
  winProbability: (json['win_probability'] as num).toDouble(),
  currentPosition: (json['current_position'] as num).toInt(),
);

Map<String, dynamic> _$BetOddsToJson(BetOdds instance) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'odds': instance.odds,
  'win_probability': instance.winProbability,
  'current_position': instance.currentPosition,
};
