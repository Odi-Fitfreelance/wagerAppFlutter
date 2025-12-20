import 'package:flutter/foundation.dart';
import '../models/bet.dart';
import '../models/score.dart';
import '../services/api_client.dart';
import '../services/bet_service.dart';

class BetProvider with ChangeNotifier {
  final BetService _betService;

  List<Bet> _publicBets = [];
  List<Bet> _myBets = [];
  Bet? _currentBet;
  List<BetParticipant> _participants = [];
  List<BetOdds> _odds = [];
  List<Score> _scores = [];
  bool _isLoading = false;
  String? _errorMessage;

  BetProvider(ApiClient client) : _betService = BetService(client);

  List<Bet> get publicBets => _publicBets;
  List<Bet> get myBets => _myBets;
  Bet? get currentBet => _currentBet;
  List<BetParticipant> get participants => _participants;
  List<BetOdds> get odds => _odds;
  List<Score> get scores => _scores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPublicBets() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('📊 Loading public bets...');
      }
      _publicBets = await _betService.getPublicBets();
      if (kDebugMode) {
        print('✅ Loaded ${_publicBets.length} public bets');
      }
      _errorMessage = null;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ API Exception loading public bets: ${e.message}');
      }
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error loading public bets: $e');
        print('Stack trace: $stackTrace');
      }
      _errorMessage = 'Failed to load public bets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyBets({String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _myBets = await _betService.getMyBets(status: status);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBet(String betId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentBet = await _betService.getBet(betId);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadParticipants(String betId) async {
    try {
      if (kDebugMode) {
        print('👥 Loading participants for bet $betId...');
      }
      _participants = await _betService.getParticipants(betId);
      if (kDebugMode) {
        print('✅ Loaded ${_participants.length} participants');
        for (var p in _participants) {
          print('  - ${p.username}: score=${p.currentScore}, toPar=${p.toPar}');
        }
      }
      notifyListeners();
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ Error loading participants: ${e.message}');
      }
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> loadOdds(String betId) async {
    try {
      _odds = await _betService.getOdds(betId);
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> loadScores(String betId) async {
    try {
      if (kDebugMode) {
        print('📊 Loading scores for bet $betId...');
      }
      _scores = await _betService.getScores(betId);
      if (kDebugMode) {
        print('✅ Loaded ${_scores.length} scores');
        for (var score in _scores) {
          print(
            '  - Hole ${score.holeNumber}: ${score.strokes} strokes (user: ${score.userId})',
          );
        }
      }
      notifyListeners();
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ Error loading scores: ${e.message}');
      }
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<Bet?> createBet({
    required String name,
    String? description,
    required String betType,
    required double stakeAmount,
    String? stakeCurrency,
    int? maxPlayers,
    String? location,
    String? courseName,
    double? latitude,
    double? longitude,
    DateTime? scheduledStartTime,
    bool? isPublic,
    bool? allowOutsideBackers,
    Map<String, dynamic>? settings,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bet = await _betService.createBet(
        name: name,
        description: description,
        betType: betType,
        stakeAmount: stakeAmount,
        stakeCurrency: stakeCurrency,
        maxPlayers: maxPlayers,
        location: location,
        courseName: courseName,
        latitude: latitude,
        longitude: longitude,
        scheduledStartTime: scheduledStartTime,
        isPublic: isPublic,
        allowOutsideBackers: allowOutsideBackers,
        settings: settings,
      );
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return bet;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> joinBet(String betId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _betService.joinBet(betId);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReadyStatus(String betId, bool isReady) async {
    try {
      await _betService.updateReadyStatus(betId, isReady);
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> startBet(String betId) async {
    try {
      await _betService.startBet(betId);
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> submitScore({
    required String betId,
    required int holeNumber,
    required int strokes,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '📝 Submitting score: betId=$betId, hole=$holeNumber, strokes=$strokes',
        );
      }
      await _betService.submitScore(
        betId: betId,
        holeNumber: holeNumber,
        strokes: strokes,
      );
      if (kDebugMode) {
        print('✅ Score submitted successfully');
      }
      await loadScores(betId);
      _errorMessage = null;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ Error submitting score: ${e.message}');
      }
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> loadBetOdds(String betId) async {
    try {
      _odds = await _betService.getOdds(betId);
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
