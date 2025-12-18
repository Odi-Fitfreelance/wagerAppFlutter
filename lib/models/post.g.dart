// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  username: json['username'] as String,
  profileImageUrl: json['profile_image_url'] as String?,
  content: json['content'] as String,
  type: $enumDecode(_$PostTypeEnumMap, json['type']),
  visibility: $enumDecode(_$PostVisibilityEnumMap, json['visibility']),
  location: json['location'] as String?,
  latitude: _numFromJsonNullable(json['latitude']),
  longitude: _numFromJsonNullable(json['longitude']),
  metadata: json['metadata'] as Map<String, dynamic>?,
  betId: json['bet_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  likesCount: _intFromJson(json['likes_count']),
  commentsCount: _intFromJson(json['comments_count']),
  mediaCount: _intFromJson(json['media_count']),
  isLiked: json['is_liked_by_user'] as bool,
  betName: json['bet_name'] as String?,
  betCode: json['bet_code'] as String?,
  betStatus: json['bet_status'] as String?,
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'username': instance.username,
  'profile_image_url': instance.profileImageUrl,
  'content': instance.content,
  'type': _$PostTypeEnumMap[instance.type]!,
  'visibility': _$PostVisibilityEnumMap[instance.visibility]!,
  'location': instance.location,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'metadata': instance.metadata,
  'bet_id': instance.betId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'likes_count': instance.likesCount,
  'comments_count': instance.commentsCount,
  'media_count': instance.mediaCount,
  'is_liked_by_user': instance.isLiked,
  'bet_name': instance.betName,
  'bet_code': instance.betCode,
  'bet_status': instance.betStatus,
  'media': instance.media,
};

const _$PostTypeEnumMap = {
  PostType.general: 'general',
  PostType.betUpdate: 'bet_update',
  PostType.betResult: 'bet_result',
  PostType.achievement: 'achievement',
};

const _$PostVisibilityEnumMap = {
  PostVisibility.public: 'public',
  PostVisibility.followers: 'followers',
  PostVisibility.private: 'private',
};

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  userId: json['user_id'] as String,
  username: json['username'] as String,
  profileImageUrl: json['profile_image_url'] as String?,
  content: json['content'] as String,
  parentId: json['parent_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'post_id': instance.postId,
  'user_id': instance.userId,
  'username': instance.username,
  'profile_image_url': instance.profileImageUrl,
  'content': instance.content,
  'parent_id': instance.parentId,
  'created_at': instance.createdAt.toIso8601String(),
};
