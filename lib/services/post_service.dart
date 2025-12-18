import 'package:flutter/foundation.dart';
import '../models/post.dart';
import 'api_client.dart';

class PostService {
  final ApiClient _client;

  PostService(this._client);

  Future<Post> createPost({
    required String content,
    required String type,
    required String visibility,
    List<String>? mediaUrls,
    String? betId,
  }) async {
    final response = await _client.post('/posts', data: {
      'content': content,
      'type': type,
      'visibility': visibility,
      if (mediaUrls != null) 'media_urls': mediaUrls,
      if (betId != null) 'bet_id': betId,
    });
    return Post.fromJson(response.data['post']);
  }

  Future<String> uploadMedia(String filePath,
      {void Function(int, int)? onProgress}) async {
    final response = await _client.uploadFile(
      '/posts/upload',
      'media',
      filePath,
      onSendProgress: onProgress != null
          ? (sent, total) => onProgress(sent, total)
          : null,
    );
    return response.data['media_url'];
  }

  Future<List<Post>> getFeed({
    int page = 1,
    int limit = 20,
    String? filter,
  }) async {
    if (kDebugMode) {
      print('📡 Fetching feed from API...');
    }
    final response = await _client.get('/posts/feed', queryParameters: {
      'page': page,
      'limit': limit,
      if (filter != null) 'filter': filter,
    });
    if (kDebugMode) {
      print('📦 Raw feed response: ${response.data}');
    }

    if (response.data['posts'] != null && (response.data['posts'] as List).isNotEmpty) {
      if (kDebugMode) {
        print('📦 First post sample: ${(response.data['posts'] as List).first}');
      }
    }

    return (response.data['posts'] as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }

  Future<Post> getPost(String postId) async {
    final response = await _client.get('/posts/$postId');
    return Post.fromJson(response.data['post']);
  }

  Future<List<Post>> getUserPosts(String userId,
      {int page = 1, int limit = 20}) async {
    final response = await _client.get('/posts/user/$userId', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return (response.data['posts'] as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }

  Future<List<Post>> getBetPosts(String betId,
      {int page = 1, int limit = 20}) async {
    final response = await _client.get('/posts/bet/$betId', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return (response.data['posts'] as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }

  Future<Post> updatePost({
    required String postId,
    String? content,
    String? visibility,
  }) async {
    final response = await _client.put('/posts/$postId', data: {
      if (content != null) 'content': content,
      if (visibility != null) 'visibility': visibility,
    });
    return Post.fromJson(response.data['post']);
  }

  Future<void> deletePost(String postId) async {
    await _client.delete('/posts/$postId');
  }

  Future<void> likePost(String postId) async {
    await _client.post('/posts/$postId/like');
  }

  Future<void> unlikePost(String postId) async {
    await _client.delete('/posts/$postId/like');
  }

  Future<List<Comment>> getComments(String postId,
      {int page = 1, int limit = 20}) async {
    final response = await _client.get('/posts/$postId/comments', queryParameters: {
      'limit': limit,
      'offset': (page - 1) * limit,
    });
    return (response.data['comments'] as List)
        .map((json) => Comment.fromJson(json))
        .toList();
  }

  Future<Comment> createComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    final response = await _client.post('/posts/$postId/comments', data: {
      'content': content,
      if (parentId != null) 'parentCommentId': parentId,
    });
    return Comment.fromJson(response.data['comment']);
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _client.delete('/posts/$postId/comments/$commentId');
  }
}
