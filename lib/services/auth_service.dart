import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required DateTime dateOfBirth,
  }) async {
    final response = await _client.post('/auth/register', data: {
      'email': email,
      'password': password,
      'username': username,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    });

    return {
      'user': User.fromJson(response.data['user']),
      'token': response.data['token'],
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('📡 Calling /auth/login API...');
    }
    final response = await _client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (kDebugMode) {
      print('📦 Raw response data: ${response.data}');
      print('📦 Response type: ${response.data.runtimeType}');
      print('🔑 Token: ${response.data['token']}');
      print('👥 User data: ${response.data['user']}');
    }

    return {
      'user': User.fromJson(response.data['user']),
      'token': response.data['token'],
    };
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<User> getCurrentUser() async {
    final response = await _client.get('/auth/me');
    return User.fromJson(response.data['user']);
  }

  Future<String> refreshToken() async {
    final response = await _client.post('/auth/refresh-token');
    return response.data['token'];
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.post('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    await _client.post('/auth/change-email', data: {
      'newEmail': newEmail,
      'password': password,
    });
  }

  Future<void> forgotPassword(String email) async {
    await _client.post('/auth/forgot-password', data: {
      'email': email,
    });
  }

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await _client.post('/auth/verify-reset-code', data: {
      'email': email,
      'code': code,
    });
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _client.post('/auth/reset-password', data: {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }
}
