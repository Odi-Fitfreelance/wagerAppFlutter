// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletBalance _$WalletBalanceFromJson(Map<String, dynamic> json) =>
    WalletBalance(
      gcBalance: WalletBalance._intFromJson(json['gc_balance']),
      scBalance: WalletBalance._intFromJson(json['sc_balance']),
      escrowGc: WalletBalance._intFromJson(json['escrow_gc']),
      escrowSc: WalletBalance._intFromJson(json['escrow_sc']),
      redeemableSc: WalletBalance._intFromJson(json['redeemable_sc']),
      scPlaythroughRemaining: WalletBalance._intFromJson(
        json['sc_playthrough_remaining'],
      ),
      lifetimeGcEarned: WalletBalance._intFromJson(json['lifetime_gc_earned']),
      lifetimeScEarned: WalletBalance._intFromJson(json['lifetime_sc_earned']),
      lastActivityAt: json['last_activity_at'] == null
          ? null
          : DateTime.parse(json['last_activity_at'] as String),
    );

Map<String, dynamic> _$WalletBalanceToJson(WalletBalance instance) =>
    <String, dynamic>{
      'gc_balance': instance.gcBalance,
      'sc_balance': instance.scBalance,
      'escrow_gc': instance.escrowGc,
      'escrow_sc': instance.escrowSc,
      'redeemable_sc': instance.redeemableSc,
      'sc_playthrough_remaining': instance.scPlaythroughRemaining,
      'lifetime_gc_earned': instance.lifetimeGcEarned,
      'lifetime_sc_earned': instance.lifetimeScEarned,
      'last_activity_at': instance.lastActivityAt?.toIso8601String(),
    };
