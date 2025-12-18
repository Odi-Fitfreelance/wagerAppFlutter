import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

enum TransactionType {
  @JsonValue('bet_placed')
  betPlaced,
  @JsonValue('bet_won')
  betWon,
  @JsonValue('bet_refund')
  betRefund,
  @JsonValue('points_purchase')
  pointsPurchase,
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
}

@JsonSerializable()
class Transaction {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final TransactionType type;
  final double amount;
  final double balance;
  final String? description;
  @JsonKey(name: 'bet_id')
  final String? betId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balance,
    this.description,
    this.betId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  bool get isCredit =>
      type == TransactionType.betWon ||
      type == TransactionType.betRefund ||
      type == TransactionType.pointsPurchase ||
      type == TransactionType.outsideBetWon ||
      type == TransactionType.achievementBonus;

  bool get isDebit =>
      type == TransactionType.betPlaced ||
      type == TransactionType.withdrawal ||
      type == TransactionType.storePurchase ||
      type == TransactionType.outsideBetPlaced;
}

// Helper function to convert string or num to num
num _numFromJson(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.parse(value);
  return 0;
}

// Helper function to convert string or num to int
int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
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
