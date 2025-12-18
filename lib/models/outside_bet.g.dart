// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outside_bet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutsideBet _$OutsideBetFromJson(Map<String, dynamic> json) => OutsideBet(
  id: json['id'] as String,
  betId: json['bet_id'] as String,
  bettorId: json['bettor_id'] as String,
  playerId: json['player_id'] as String,
  playerName: json['player_name'] as String,
  amount: (json['amount'] as num).toDouble(),
  odds: (json['odds'] as num).toDouble(),
  potentialPayout: (json['potential_payout'] as num).toDouble(),
  actualPayout: (json['actual_payout'] as num?)?.toDouble(),
  status: $enumDecode(_$OutsideBetStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
);

Map<String, dynamic> _$OutsideBetToJson(OutsideBet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bet_id': instance.betId,
      'bettor_id': instance.bettorId,
      'player_id': instance.playerId,
      'player_name': instance.playerName,
      'amount': instance.amount,
      'odds': instance.odds,
      'potential_payout': instance.potentialPayout,
      'actual_payout': instance.actualPayout,
      'status': _$OutsideBetStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
    };

const _$OutsideBetStatusEnumMap = {
  OutsideBetStatus.pending: 'pending',
  OutsideBetStatus.won: 'won',
  OutsideBetStatus.lost: 'lost',
  OutsideBetStatus.refunded: 'refunded',
};
