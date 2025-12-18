import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(ApiClient client) : _authService = AuthService(client);

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if token exists in secure storage
      if (kDebugMode) {
        print('🔍 Checking for existing auth token...');
      }
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        if (kDebugMode) {
          print('🔑 Token found in storage');
        }

        // Try to get current user from cache
        final userData = await _secureStorage.read(key: 'user_data');
        if (userData != null) {
          try {
            _user = User.fromJson(jsonDecode(userData));
            _isAuthenticated = true;
            if (kDebugMode) {
              print('✅ User loaded from cache: ${_user?.username}');
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ Error parsing cached user data: $e');
            }
            // If we can't parse the cached data, clear auth
            await clearAuth();
            _isLoading = false;
            notifyListeners();
            return;
          }
        }

        // Try to refresh user data from server (non-blocking)
        // If this fails, we'll keep the cached data
        await refreshUser();
      } else {
        if (kDebugMode) {
          print('ℹ️ No token found in storage');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during init: $e');
      }
      // Only clear auth if there's an error reading from storage
      await clearAuth();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔐 Starting login...');
      }
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ Login response received: $result');
      }

      _user = result['user'];
      final token = result['token'];

      if (kDebugMode) {
        print('👤 User: ${_user?.username}, Token: ${token?.substring(0, 20)}...');
      }

      // Save to secure storage with error handling
      try {
        if (kDebugMode) {
          print('💾 Attempting to save token to secure storage...');
        }
        await _secureStorage.write(key: 'auth_token', value: token);
        if (kDebugMode) {
          print('✅ Token saved successfully');
        }

        if (kDebugMode) {
          print('💾 Attempting to save user data to secure storage...');
        }
        await _secureStorage.write(
          key: 'user_data',
          value: jsonEncode(_user!.toJson()),
        );
        if (kDebugMode) {
          print('✅ User data saved successfully');
        }
      } catch (storageError) {
        if (kDebugMode) {
          print('❌ CRITICAL: Secure storage write failed: $storageError');
        }
        throw Exception('Failed to save login credentials to secure storage. This may be a device security issue. Error: $storageError');
      }

      _isAuthenticated = true;
      _errorMessage = null;

      if (kDebugMode) {
        print('✨ Authentication successful! isAuthenticated: $_isAuthenticated');
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ API Exception: ${e.message}');
      }
      _errorMessage = e.message;
      _isAuthenticated = false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
        print('Stack trace: $stackTrace');
      }
      _errorMessage = 'An unexpected error occurred: $e';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      if (kDebugMode) {
        print('🔄 Notifying listeners... isAuthenticated: $_isAuthenticated');
      }
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required DateTime dateOfBirth,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        username: username,
        dateOfBirth: dateOfBirth,
      );

      _user = result['user'];
      final token = result['token'];

      // Save to secure storage
      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(
        key: 'user_data',
        value: jsonEncode(_user!.toJson()),
      );

      _isAuthenticated = true;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isAuthenticated = false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      await clearAuth();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      _user = await _authService.getCurrentUser();
      await _secureStorage.write(
        key: 'user_data',
        value: jsonEncode(_user!.toJson()),
      );
      notifyListeners();
    } catch (e) {
      // If refresh fails, just log the error but keep the cached user data
      // Don't clear auth - this prevents users from being logged out unexpectedly
      if (kDebugMode) {
        print('⚠️ Failed to refresh user data: $e');
        print('Keeping cached user data and authentication state');
      }
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await _secureStorage.write(
      key: 'user_data',
      value: jsonEncode(_user!.toJson()),
    );
    notifyListeners();
  }

  Future<void> clearAuth() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'user_data');
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
