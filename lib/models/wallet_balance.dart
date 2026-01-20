import 'package:json_annotation/json_annotation.dart';

part 'wallet_balance.g.dart';

@JsonSerializable()
class WalletBalance {
  @JsonKey(name: 'gc_balance', fromJson: _intFromJson)
  final int gcBalance; // Gold Coins (social play, non-redeemable)

  @JsonKey(name: 'sc_balance', fromJson: _intFromJson)
  final int scBalance; // Sweeps Coins (redeemable for prizes)

  @JsonKey(name: 'escrow_gc', fromJson: _intFromJson)
  final int escrowGc; // GC locked in active bets

  @JsonKey(name: 'escrow_sc', fromJson: _intFromJson)
  final int escrowSc; // SC locked in active bets

  @JsonKey(name: 'redeemable_sc', fromJson: _intFromJson)
  final int redeemableSc; // SC that completed playthrough

  @JsonKey(name: 'sc_playthrough_remaining', fromJson: _intFromJson)
  final int scPlaythroughRemaining; // SC that needs to be played once

  @JsonKey(name: 'lifetime_gc_earned', fromJson: _intFromJson)
  final int lifetimeGcEarned;

  @JsonKey(name: 'lifetime_sc_earned', fromJson: _intFromJson)
  final int lifetimeScEarned;

  @JsonKey(name: 'last_activity_at')
  final DateTime? lastActivityAt;

  WalletBalance({
    required this.gcBalance,
    required this.scBalance,
    required this.escrowGc,
    required this.escrowSc,
    required this.redeemableSc,
    required this.scPlaythroughRemaining,
    required this.lifetimeGcEarned,
    required this.lifetimeScEarned,
    this.lastActivityAt,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$WalletBalanceToJson(this);

  // Custom converter to handle both String and num from API
  static int _intFromJson(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Handle decimals like "0.00" by parsing as double first
      final parsed = double.tryParse(value);
      return parsed?.toInt() ?? 0;
    }
    return 0;
  }

  /// Total available GC (not in escrow)
  int get totalAvailableGc => gcBalance;

  /// Total available SC (not in escrow)
  int get totalAvailableSc => scBalance;

  /// Total GC including escrow
  int get totalGc => gcBalance + escrowGc;

  /// Total SC including escrow
  int get totalSc => scBalance + escrowSc;

  /// Playthrough progress as percentage (0-100)
  double get playthroughProgress {
    final totalPlaythrough = scPlaythroughRemaining + redeemableSc;
    if (totalPlaythrough == 0) return 100.0;
    return (redeemableSc / totalPlaythrough) * 100;
  }

  /// Can user redeem SC?
  bool get canRedeem => redeemableSc >= 50; // Minimum 50 SC

  /// Is playthrough complete?
  bool get playthroughComplete => scPlaythroughRemaining == 0;

  WalletBalance copyWith({
    int? gcBalance,
    int? scBalance,
    int? escrowGc,
    int? escrowSc,
    int? redeemableSc,
    int? scPlaythroughRemaining,
    int? lifetimeGcEarned,
    int? lifetimeScEarned,
    DateTime? lastActivityAt,
  }) {
    return WalletBalance(
      gcBalance: gcBalance ?? this.gcBalance,
      scBalance: scBalance ?? this.scBalance,
      escrowGc: escrowGc ?? this.escrowGc,
      escrowSc: escrowSc ?? this.escrowSc,
      redeemableSc: redeemableSc ?? this.redeemableSc,
      scPlaythroughRemaining:
          scPlaythroughRemaining ?? this.scPlaythroughRemaining,
      lifetimeGcEarned: lifetimeGcEarned ?? this.lifetimeGcEarned,
      lifetimeScEarned: lifetimeScEarned ?? this.lifetimeScEarned,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}
