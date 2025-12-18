import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String username;
  final DateTime? dateOfBirth;
  final bool isVerified;
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

  User({
    required this.id,
    required this.email,
    required this.username,
    this.dateOfBirth,
    required this.isVerified,
    required this.walletBalance,
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
    );
  }
}
