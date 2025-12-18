import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

// Helper function to convert string or num to int
int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  return 0;
}

// Helper function to convert string or num to num (nullable)
num? _numFromJsonNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.parse(value);
  return null;
}

enum PostType {
  @JsonValue('general')
  general,
  @JsonValue('bet_update')
  betUpdate,
  @JsonValue('bet_result')
  betResult,
  @JsonValue('achievement')
  achievement,
}

enum PostVisibility {
  @JsonValue('public')
  public,
  @JsonValue('followers')
  followers,
  @JsonValue('private')
  private,
}

@JsonSerializable()
class Post {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String username;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  final String content;
  final PostType type;
  final PostVisibility visibility;
  final String? location;
  @JsonKey(fromJson: _numFromJsonNullable)
  final num? latitude;
  @JsonKey(fromJson: _numFromJsonNullable)
  final num? longitude;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'bet_id')
  final String? betId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;
  @JsonKey(name: 'likes_count', fromJson: _intFromJson)
  final int likesCount;
  @JsonKey(name: 'comments_count', fromJson: _intFromJson)
  final int commentsCount;
  @JsonKey(name: 'media_count', fromJson: _intFromJson)
  final int mediaCount;
  @JsonKey(name: 'is_liked_by_user')
  final bool isLiked;
  @JsonKey(name: 'bet_name')
  final String? betName;
  @JsonKey(name: 'bet_code')
  final String? betCode;
  @JsonKey(name: 'bet_status')
  final String? betStatus;
  final List<Map<String, dynamic>>? media;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.content,
    required this.type,
    required this.visibility,
    this.location,
    this.latitude,
    this.longitude,
    this.metadata,
    this.betId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.mediaCount,
    required this.isLiked,
    this.betName,
    this.betCode,
    this.betStatus,
    this.media,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
  }) {
    return Post(
      id: id,
      userId: userId,
      username: username,
      profileImageUrl: profileImageUrl,
      content: content,
      type: type,
      visibility: visibility,
      location: location,
      latitude: latitude,
      longitude: longitude,
      metadata: metadata,
      betId: betId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      mediaCount: mediaCount,
      isLiked: isLiked ?? this.isLiked,
      betName: betName,
      betCode: betCode,
      betStatus: betStatus,
      media: media,
    );
  }
}

@JsonSerializable()
class Comment {
  final String id;
  @JsonKey(name: 'post_id')
  final String postId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String username;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  final String content;
  @JsonKey(name: 'parent_id')
  final String? parentId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.content,
    this.parentId,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
