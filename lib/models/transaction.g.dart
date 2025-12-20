// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  userId: json['user_id'] as String?,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String?,
  status: json['status'] as String?,
  description: json['description'] as String?,
  referenceId: json['reference_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'description': instance.description,
      'reference_id': instance.referenceId,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.betPlaced: 'bet_placed',
  TransactionType.betWon: 'bet_won',
  TransactionType.betLost: 'bet_lost',
  TransactionType.betCancelled: 'bet_cancelled',
  TransactionType.betRefund: 'bet_refund',
  TransactionType.purchase: 'purchase',
  TransactionType.pointsPurchase: 'points_purchase',
  TransactionType.redeem: 'redeem',
  TransactionType.withdrawal: 'withdrawal',
  TransactionType.storePurchase: 'store_purchase',
  TransactionType.outsideBetPlaced: 'outside_bet_placed',
  TransactionType.outsideBetWon: 'outside_bet_won',
  TransactionType.achievementBonus: 'achievement_bonus',
  TransactionType.judgeFee: 'judge_fee',
};

WalletStats _$WalletStatsFromJson(Map<String, dynamic> json) => WalletStats(
  pointsBalance: _numFromJson(json['points_balance']),
  cashBalance: _numFromJson(json['cash_balance']),
  lifetimePointsEarned: _numFromJson(json['lifetime_points_earned']),
  lifetimeCashEarned: _numFromJson(json['lifetime_cash_earned']),
  totalWins: _intFromJson(json['total_wins']),
  totalLosses: _intFromJson(json['total_losses']),
  totalPurchases: _intFromJson(json['total_purchases']),
  totalPointsPurchased: _numFromJson(json['total_points_purchased']),
);

Map<String, dynamic> _$WalletStatsToJson(WalletStats instance) =>
    <String, dynamic>{
      'points_balance': instance.pointsBalance,
      'cash_balance': instance.cashBalance,
      'lifetime_points_earned': instance.lifetimePointsEarned,
      'lifetime_cash_earned': instance.lifetimeCashEarned,
      'total_wins': instance.totalWins,
      'total_losses': instance.totalLosses,
      'total_purchases': instance.totalPurchases,
      'total_points_purchased': instance.totalPointsPurchased,
    };
