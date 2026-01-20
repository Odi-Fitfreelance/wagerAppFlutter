import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String username;
  final DateTime? dateOfBirth;
  final bool isVerified;
  @Deprecated('Use WalletBalance model instead')
  final double walletBalance;
  final String? profileImageUrl;
  final DateTime? createdAt;

  // Profile details
  final String? bio;
  final double? handicap;
  final String? favoriteCourse;
  final int? bestScore;
  final int? holesPlayed;
  final double? averageScore;

  // Social counts
  final int followersCount;
  final int followingCount;

  // Sweepstakes compliance fields
  @JsonKey(name: 'trust_score')
  final int trustScore; // 0-1000, affects betting permissions

  @JsonKey(name: 'kyc_verified')
  final bool kycVerified; // KYC verification status

  @JsonKey(name: 'kyc_status')
  final String? kycStatus; // 'not_submitted', 'pending', 'approved', 'rejected'

  @JsonKey(name: 'is_admin')
  final bool isAdmin; // Admin privileges

  @JsonKey(name: 'state')
  final String? state; // US state code for geofencing (e.g., 'CA', 'WA')

  @JsonKey(name: 'country')
  final String? country; // Country code (e.g., 'US')

  @JsonKey(name: 'is_blocked')
  final bool isBlocked; // Account blocked status

  @JsonKey(name: 'account_forfeited')
  final bool accountForfeited; // Fraud/collusion forfeit

  User({
    required this.id,
    required this.email,
    required this.username,
    this.dateOfBirth,
    required this.isVerified,
    this.walletBalance = 0.0,
    this.profileImageUrl,
    this.createdAt,
    this.bio,
    this.handicap,
    this.favoriteCourse,
    this.bestScore,
    this.holesPlayed,
    this.averageScore,
    this.followersCount = 0,
    this.followingCount = 0,
    this.trustScore = 500,
    this.kycVerified = false,
    this.kycStatus,
    this.isAdmin = false,
    this.state,
    this.country,
    this.isBlocked = false,
    this.accountForfeited = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? username,
    DateTime? dateOfBirth,
    bool? isVerified,
    double? walletBalance,
    String? profileImageUrl,
    DateTime? createdAt,
    String? bio,
    double? handicap,
    String? favoriteCourse,
    int? bestScore,
    int? holesPlayed,
    double? averageScore,
    int? followersCount,
    int? followingCount,
    int? trustScore,
    bool? kycVerified,
    String? kycStatus,
    bool? isAdmin,
    String? state,
    String? country,
    bool? isBlocked,
    bool? accountForfeited,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isVerified: isVerified ?? this.isVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      handicap: handicap ?? this.handicap,
      favoriteCourse: favoriteCourse ?? this.favoriteCourse,
      bestScore: bestScore ?? this.bestScore,
      holesPlayed: holesPlayed ?? this.holesPlayed,
      averageScore: averageScore ?? this.averageScore,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      trustScore: trustScore ?? this.trustScore,
      kycVerified: kycVerified ?? this.kycVerified,
      kycStatus: kycStatus ?? this.kycStatus,
      isAdmin: isAdmin ?? this.isAdmin,
      state: state ?? this.state,
      country: country ?? this.country,
      isBlocked: isBlocked ?? this.isBlocked,
      accountForfeited: accountForfeited ?? this.accountForfeited,
    );
  }

  /// Can user place SC bets?
  bool get canBetSC => kycVerified && !isBlocked && !accountForfeited;

  /// Can user redeem SC for prizes?
  bool get canRedeemSC => kycVerified && trustScore >= 300 && !isBlocked;

  /// Is user in restricted state?
  bool get isInRestrictedState {
    if (state == null) return false;
    const restrictedStates = ['WA', 'ID', 'NV', 'MT'];
    return restrictedStates.contains(state?.toUpperCase());
  }

  /// Trust score status text
  String get trustScoreStatus {
    if (trustScore >= 800) return 'Excellent';
    if (trustScore >= 600) return 'Good';
    if (trustScore >= 400) return 'Fair';
    if (trustScore >= 200) return 'Low';
    return 'Very Low';
  }

  /// Trust score color
  String get trustScoreColor {
    if (trustScore >= 800) return 'green';
    if (trustScore >= 600) return 'lightGreen';
    if (trustScore >= 400) return 'orange';
    if (trustScore >= 200) return 'deepOrange';
    return 'red';
  }
}
