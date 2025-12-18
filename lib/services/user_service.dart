import '../models/user.dart';
import '../models/achievement.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _client;

  UserService(this._client);

  Future<User> getProfile() async {
    final response = await _client.get('/users/profile');
    return User.fromJson(response.data['user']);
  }

  Future<User> updateProfile({
    String? bio,
    double? handicap,
    String? favoriteCourse,
  }) async {
    final response = await _client.patch('/users/profile', data: {
      if (bio != null) 'bio': bio,
      if (handicap != null) 'handicap': handicap,
      if (favoriteCourse != null) 'favoriteCourse': favoriteCourse,
    });
    return User.fromJson(response.data['user']);
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _client.get('/users/stats');
    return response.data['stats'];
  }

  Future<List<Achievement>> getAchievements() async {
    final response = await _client.get('/users/achievements');
    return (response.data['achievements'] as List)
        .map((json) => Achievement.fromJson(json))
        .toList();
  }

  Future<String> uploadProfileImage(String filePath) async {
    final response = await _client.uploadFile(
      '/users/profile/image',
      'image',
      filePath,
    );
    return response.data['image_url'];
  }

  Future<void> deleteProfileImage() async {
    await _client.delete('/users/profile/image');
  }

  Future<void> deleteAccount(String password) async {
    await _client.delete('/users/account', data: {
      'password': password,
    });
  }
}
