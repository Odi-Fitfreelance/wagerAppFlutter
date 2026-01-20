// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  isVerified: json['isVerified'] as bool,
  walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
  profileImageUrl: json['profileImageUrl'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  bio: json['bio'] as String?,
  handicap: (json['handicap'] as num?)?.toDouble(),
  favoriteCourse: json['favoriteCourse'] as String?,
  bestScore: (json['bestScore'] as num?)?.toInt(),
  holesPlayed: (json['holesPlayed'] as num?)?.toInt(),
  averageScore: (json['averageScore'] as num?)?.toDouble(),
  followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
  followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
  trustScore: (json['trust_score'] as num?)?.toInt() ?? 500,
  kycVerified: json['kyc_verified'] as bool? ?? false,
  kycStatus: json['kyc_status'] as String?,
  isAdmin: json['is_admin'] as bool? ?? false,
  state: json['state'] as String?,
  country: json['country'] as String?,
  isBlocked: json['is_blocked'] as bool? ?? false,
  accountForfeited: json['account_forfeited'] as bool? ?? false,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'isVerified': instance.isVerified,
  'walletBalance': instance.walletBalance,
  'profileImageUrl': instance.profileImageUrl,
  'createdAt': instance.createdAt?.toIso8601String(),
  'bio': instance.bio,
  'handicap': instance.handicap,
  'favoriteCourse': instance.favoriteCourse,
  'bestScore': instance.bestScore,
  'holesPlayed': instance.holesPlayed,
  'averageScore': instance.averageScore,
  'followersCount': instance.followersCount,
  'followingCount': instance.followingCount,
  'trust_score': instance.trustScore,
  'kyc_verified': instance.kycVerified,
  'kyc_status': instance.kycStatus,
  'is_admin': instance.isAdmin,
  'state': instance.state,
  'country': instance.country,
  'is_blocked': instance.isBlocked,
  'account_forfeited': instance.accountForfeited,
};
