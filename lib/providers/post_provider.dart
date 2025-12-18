import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_client.dart';
import '../services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService;

  List<Post> _feed = [];
  Post? _currentPost;
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  PostProvider(ApiClient client) : _postService = PostService(client);

  List<Post> get feed => _feed;
  Post? get currentPost => _currentPost;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFeed({String? filter}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('📰 Loading feed posts...');
      }
      _feed = await _postService.getFeed(filter: filter);
      if (kDebugMode) {
        print('✅ Loaded ${_feed.length} posts');
      }
      _errorMessage = null;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ API Exception loading feed: ${e.message}');
      }
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error loading feed: $e');
        print('Stack trace: $stackTrace');
      }
      _errorMessage = 'Failed to load feed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPost(String postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPost = await _postService.getPost(postId);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadComments(String postId) async {
    try {
      _comments = await _postService.getComments(postId);
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<Post?> createPost({
    required String content,
    required String type,
    required String visibility,
    List<String>? mediaUrls,
    String? betId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final post = await _postService.createPost(
        content: content,
        type: type,
        visibility: visibility,
        mediaUrls: mediaUrls,
        betId: betId,
      );
      _feed.insert(0, post);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return post;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _postService.likePost(postId);

      // Update local state
      final index = _feed.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _feed[index] = _feed[index].copyWith(
          likesCount: _feed[index].likesCount + 1,
          isLiked: true,
        );
      }
      if (_currentPost?.id == postId) {
        _currentPost = _currentPost!.copyWith(
          likesCount: _currentPost!.likesCount + 1,
          isLiked: true,
        );
      }
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _postService.unlikePost(postId);

      // Update local state
      final index = _feed.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _feed[index] = _feed[index].copyWith(
          likesCount: _feed[index].likesCount - 1,
          isLiked: false,
        );
      }
      if (_currentPost?.id == postId) {
        _currentPost = _currentPost!.copyWith(
          likesCount: _currentPost!.likesCount - 1,
          isLiked: false,
        );
      }
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> createComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      final comment = await _postService.createComment(
        postId: postId,
        content: content,
        parentId: parentId,
      );
      _comments.add(comment);

      // Update comment count
      final index = _feed.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _feed[index] = _feed[index].copyWith(
          commentsCount: _feed[index].commentsCount + 1,
        );
      }
      if (_currentPost?.id == postId) {
        _currentPost = _currentPost!.copyWith(
          commentsCount: _currentPost!.commentsCount + 1,
        );
      }
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
