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
  // Sweepstakes transaction types
  @JsonValue('bundle_purchase')
  bundlePurchase,
  @JsonValue('sc_bonus')
  scBonus,
  @JsonValue('sc_redemption')
  scRedemption,
  @JsonValue('amoe_grant')
  amoeGrant,
  @JsonValue('viral_milestone_bonus')
  viralMilestoneBonus,
  @JsonValue('referral_bonus')
  referralBonus,
  @JsonValue('playthrough_progress')
  playthroughProgress,
  @JsonValue('platform_fee')
  platformFee,
  // KYC and bonus transaction types
  @JsonValue('kyc_submission')
  kycSubmission,
  @JsonValue('kyc_completion')
  kycCompletion,
  @JsonValue('bonus')
  bonus,
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

  // Sweepstakes-specific fields
  @JsonKey(name: 'bonus_type')
  final String? bonusType; // 'signup', 'login_streak', 'referral', 'viral_milestone', etc.

  @JsonKey(name: 'gc_amount')
  final int? gcAmount; // Gold Coins amount (if applicable)

  @JsonKey(name: 'sc_amount')
  final int? scAmount; // Sweeps Coins amount (if applicable)

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
    this.bonusType,
    this.gcAmount,
    this.scAmount,
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
      type == TransactionType.achievementBonus ||
      type == TransactionType.bundlePurchase ||
      type == TransactionType.scBonus ||
      type == TransactionType.amoeGrant ||
      type == TransactionType.viralMilestoneBonus ||
      type == TransactionType.referralBonus ||
      type == TransactionType.kycCompletion ||
      type == TransactionType.bonus;

  bool get isDebit =>
      type == TransactionType.betPlaced ||
      type == TransactionType.betLost ||
      type == TransactionType.withdrawal ||
      type == TransactionType.storePurchase ||
      type == TransactionType.outsideBetPlaced ||
      type == TransactionType.judgeFee ||
      type == TransactionType.scRedemption ||
      type == TransactionType.platformFee;

  /// Helper to check if this is a sweepstakes transaction
  bool get isSweepstakes =>
      type == TransactionType.bundlePurchase ||
      type == TransactionType.scBonus ||
      type == TransactionType.scRedemption ||
      type == TransactionType.amoeGrant ||
      type == TransactionType.viralMilestoneBonus ||
      type == TransactionType.referralBonus ||
      type == TransactionType.playthroughProgress ||
      type == TransactionType.platformFee;

  /// Display-friendly transaction type text
  String get typeDisplayText {
    switch (type) {
      case TransactionType.bundlePurchase:
        return 'Bundle Purchase';
      case TransactionType.scBonus:
        return 'Free SC Bonus';
      case TransactionType.scRedemption:
        return 'SC Redeemed';
      case TransactionType.amoeGrant:
        return 'Free SC (AMOE)';
      case TransactionType.viralMilestoneBonus:
        return 'Viral Milestone Bonus';
      case TransactionType.referralBonus:
        return 'Referral Bonus';
      case TransactionType.playthroughProgress:
        return 'Playthrough Progress';
      case TransactionType.platformFee:
        return 'Platform Fee';
      case TransactionType.betPlaced:
        return 'Bet Placed';
      case TransactionType.betWon:
        return 'Bet Won';
      case TransactionType.betLost:
        return 'Bet Lost';
      case TransactionType.kycSubmission:
        return 'KYC Submission';
      case TransactionType.kycCompletion:
        return 'KYC Completed';
      case TransactionType.bonus:
        return 'Bonus';
      default:
        return type.toString().split('.').last;
    }
  }
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
