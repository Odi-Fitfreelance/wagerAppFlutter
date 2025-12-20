import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

enum TransactionType {
  @JsonValue('bet_placed')
  betPlaced,
  @JsonValue('bet_won')
  betWon,
  @JsonValue('bet_lost')
  betLost,
  @JsonValue('bet_cancelled')
  betCancelled,
  @JsonValue('bet_refund')
  betRefund,
  @JsonValue('purchase')
  purchase,
  @JsonValue('points_purchase')
  pointsPurchase,
  @JsonValue('redeem')
  redeem,
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('store_purchase')
  storePurchase,
  @JsonValue('outside_bet_placed')
  outsideBetPlaced,
  @JsonValue('outside_bet_won')
  outsideBetWon,
  @JsonValue('achievement_bonus')
  achievementBonus,
  @JsonValue('judge_fee')
  judgeFee,
}

// Custom converter for amount that handles both num and String
class AmountConverter implements JsonConverter<double, dynamic> {
  const AmountConverter();

  @override
  double fromJson(dynamic json) {
    if (json == null) return 0.0;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json) ?? 0.0;
    return 0.0;
  }

  @override
  dynamic toJson(double object) => object;
}

@JsonSerializable()
class Transaction {
  final String id;
  @JsonKey(name: 'user_id')
  final String? userId;
  final TransactionType type;

  @AmountConverter() // ← This fixes the crash!
  final double amount;

  final String? currency;
  final String? status;
  final String? description;

  @JsonKey(name: 'reference_id')
  final String? referenceId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Transaction({
    required this.id,
    this.userId,
    required this.type,
    required this.amount,
    this.currency,
    this.status,
    this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  bool get isCredit =>
      type == TransactionType.betWon ||
      type == TransactionType.betCancelled ||
      type == TransactionType.betRefund ||
      type == TransactionType.purchase ||
      type == TransactionType.pointsPurchase ||
      type == TransactionType.redeem ||
      type == TransactionType.outsideBetWon ||
      type == TransactionType.achievementBonus;

  bool get isDebit =>
      type == TransactionType.betPlaced ||
      type == TransactionType.betLost ||
      type == TransactionType.withdrawal ||
      type == TransactionType.storePurchase ||
      type == TransactionType.outsideBetPlaced ||
      type == TransactionType.judgeFee;
}

// Your helper functions (already good)
num _numFromJson(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

@JsonSerializable()
class WalletStats {
  @JsonKey(name: 'points_balance', fromJson: _numFromJson)
  final num pointsBalance;
  @JsonKey(name: 'cash_balance', fromJson: _numFromJson)
  final num cashBalance;
  @JsonKey(name: 'lifetime_points_earned', fromJson: _numFromJson)
  final num lifetimePointsEarned;
  @JsonKey(name: 'lifetime_cash_earned', fromJson: _numFromJson)
  final num lifetimeCashEarned;
  @JsonKey(name: 'total_wins', fromJson: _intFromJson)
  final int totalWins;
  @JsonKey(name: 'total_losses', fromJson: _intFromJson)
  final int totalLosses;
  @JsonKey(name: 'total_purchases', fromJson: _intFromJson)
  final int totalPurchases;
  @JsonKey(name: 'total_points_purchased', fromJson: _numFromJson)
  final num totalPointsPurchased;

  WalletStats({
    required this.pointsBalance,
    required this.cashBalance,
    required this.lifetimePointsEarned,
    required this.lifetimeCashEarned,
    required this.totalWins,
    required this.totalLosses,
    required this.totalPurchases,
    required this.totalPointsPurchased,
  });

  factory WalletStats.fromJson(Map<String, dynamic> json) =>
      _$WalletStatsFromJson(json);

  Map<String, dynamic> toJson() => _$WalletStatsToJson(this);

  double get winRate => (totalWins + totalLosses) > 0
      ? totalWins / (totalWins + totalLosses)
      : 0.0;
}
