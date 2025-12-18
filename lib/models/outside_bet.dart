import 'package:json_annotation/json_annotation.dart';

part 'outside_bet.g.dart';

enum OutsideBetStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('won')
  won,
  @JsonValue('lost')
  lost,
  @JsonValue('refunded')
  refunded,
}

@JsonSerializable()
class OutsideBet {
  final String id;
  @JsonKey(name: 'bet_id')
  final String betId;
  @JsonKey(name: 'bettor_id')
  final String bettorId;
  @JsonKey(name: 'player_id')
  final String playerId;
  @JsonKey(name: 'player_name')
  final String playerName;
  final double amount;
  final double odds;
  @JsonKey(name: 'potential_payout')
  final double potentialPayout;
  @JsonKey(name: 'actual_payout')
  final double? actualPayout;
  final OutsideBetStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;

  OutsideBet({
    required this.id,
    required this.betId,
    required this.bettorId,
    required this.playerId,
    required this.playerName,
    required this.amount,
    required this.odds,
    required this.potentialPayout,
    this.actualPayout,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory OutsideBet.fromJson(Map<String, dynamic> json) =>
      _$OutsideBetFromJson(json);
  Map<String, dynamic> toJson() => _$OutsideBetToJson(this);

  double get potentialProfit => potentialPayout - amount;
  double? get actualProfit =>
      actualPayout != null ? actualPayout! - amount : null;
}
