import '../models/user.dart';
import '../models/leaderboard.dart';
import 'api_client.dart';

class SocialService {
  final ApiClient _client;

  SocialService(this._client);

  Future<void> followUser(String userId) async {
    await _client.post('/social/follow/$userId');
  }

  Future<void> unfollowUser(String userId) async {
    await _client.delete('/social/follow/$userId');
  }

  Future<List<User>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    final response = await _client.get('/social/followers/$userId', queryParameters: {
      'limit': limit,
      'offset': (page - 1) * limit,
    });
    return (response.data['followers'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<List<User>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    final response = await _client.get('/social/following/$userId', queryParameters: {
      'limit': limit,
      'offset': (page - 1) * limit,
    });
    return (response.data['following'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<bool> checkFollowing(String userId) async {
    final response = await _client.get('/social/following/$userId/check');
    return response.data['isFollowing'];
  }

  Future<List<dynamic>> getFeed({int page = 1, int limit = 20}) async {
    final response = await _client.get('/social/feed', queryParameters: {
      'limit': limit,
      'offset': (page - 1) * limit,
    });
    return response.data['feed'] as List;
  }

  Future<List<User>> getAllUsers({int page = 1, int limit = 20}) async {
    final response = await _client.get('/social/users', queryParameters: {
      'limit': limit,
      'offset': (page - 1) * limit,
    });
    return (response.data['users'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<List<User>> searchUsers(String query) async {
    final response = await _client.get('/social/users/search', queryParameters: {
      'q': query,
    });
    return (response.data['users'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<User> getUserProfile(String userId) async {
    final response = await _client.get('/social/users/$userId');
    return User.fromJson(response.data['user']);
  }

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int page = 1,
    int limit = 20,
    String period = 'all_time',
  }) async {
    final response = await _client.get('/social/leaderboard/global', queryParameters: {
      'timePeriod': period,
      'limit': limit,
    });
    return (response.data['leaderboard'] as List)
        .map((json) => LeaderboardEntry.fromJson(json))
        .toList();
  }

  Future<List<LeaderboardEntry>> getFriendsLeaderboard({
    int page = 1,
    int limit = 20,
    String period = 'all_time',
  }) async {
    final response = await _client.get('/social/leaderboard/friends', queryParameters: {
      'timePeriod': period,
    });
    return (response.data['leaderboard'] as List)
        .map((json) => LeaderboardEntry.fromJson(json))
        .toList();
  }
}
