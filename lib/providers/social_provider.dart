import 'package:flutter/foundation.dart';
import '../models/leaderboard.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/social_service.dart';

class SocialProvider with ChangeNotifier {
  final SocialService _socialService;

  List<LeaderboardEntry> _globalLeaderboard = [];
  List<LeaderboardEntry> _friendsLeaderboard = [];
  List<User> _allUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  SocialProvider(ApiClient client) : _socialService = SocialService(client);

  List<LeaderboardEntry> get globalLeaderboard => _globalLeaderboard;
  List<LeaderboardEntry> get friendsLeaderboard => _friendsLeaderboard;
  List<User> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadGlobalLeaderboard({String period = 'all_time'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _globalLeaderboard = await _socialService.getGlobalLeaderboard(
        period: period,
      );
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFriendsLeaderboard({String period = 'all_time'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _friendsLeaderboard = await _socialService.getFriendsLeaderboard(
        period: period,
      );
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allUsers = await _socialService.getAllUsers();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> followUser(String userId) async {
    try {
      await _socialService.followUser(userId);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      await _socialService.unfollowUser(userId);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
