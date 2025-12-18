import 'package:flutter/foundation.dart';
import '../models/bet.dart';
import '../models/score.dart';
import 'api_client.dart';

class BetService {
  final ApiClient _client;

  BetService(this._client);

  Future<Bet> createBet({
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
    final response = await _client.post('/bets', data: {
      'name': name,
      if (description != null) 'description': description,
      'betType': betType,
      'stakeAmount': stakeAmount,
      if (stakeCurrency != null) 'stakeCurrency': stakeCurrency,
      if (maxPlayers != null) 'maxPlayers': maxPlayers,
      if (location != null) 'location': location,
      if (courseName != null) 'courseName': courseName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (scheduledStartTime != null) 'scheduledStartTime': scheduledStartTime.toIso8601String(),
      if (isPublic != null) 'isPublic': isPublic,
      if (allowOutsideBackers != null) 'allowOutsideBackers': allowOutsideBackers,
      if (settings != null) 'settings': settings,
    });
    return Bet.fromJson(response.data['bet']);
  }

  Future<List<Bet>> getPublicBets({int page = 1, int limit = 20}) async {
    if (kDebugMode) {
      print('📡 Fetching public bets from API...');
    }
    final response = await _client.get('/bets/public/list', queryParameters: {
      'limit': limit,
      'offset': (page - 1) * limit,
    });
    if (kDebugMode) {
      print('📦 Raw bets response: ${response.data}');
    }

    if (response.data['bets'] != null && (response.data['bets'] as List).isNotEmpty) {
      if (kDebugMode) {
        print('📦 First bet sample: ${(response.data['bets'] as List).first}');
      }
    }

    return (response.data['bets'] as List)
        .map((json) => Bet.fromJson(json))
        .toList();
  }

  Future<List<Bet>> getMyBets({String? status}) async {
    final response = await _client.get('/bets/user/my-bets', queryParameters: {
      if (status != null) 'status': status,
    });
    return (response.data['bets'] as List)
        .map((json) => Bet.fromJson(json))
        .toList();
  }

  Future<Bet> getBet(String betId) async {
    final response = await _client.get('/bets/$betId');
    return Bet.fromJson(response.data['bet']);
  }

  Future<Bet> getBetByCode(String code) async {
    final response = await _client.get('/bets/code/$code');
    return Bet.fromJson(response.data['bet']);
  }

  Future<void> joinBet(String betId) async {
    await _client.post('/bets/$betId/join');
  }

  Future<void> leaveBet(String betId) async {
    await _client.post('/bets/$betId/leave');
  }

  Future<void> updateReadyStatus(String betId, bool isReady) async {
    await _client.post('/bets/$betId/ready', data: {
      'isReady': isReady,
    });
  }

  Future<void> startBet(String betId) async {
    await _client.post('/bets/$betId/start');
  }

  Future<void> submitScore({
    required String betId,
    required int holeNumber,
    required int strokes,
    int? par,  // Optional - backend looks it up from course if not provided
  }) async {
    if (kDebugMode) {
      print('🎯 Sending score data: hole_number=$holeNumber, score=$strokes, par=$par');
    }
    await _client.post('/bets/$betId/scores', data: {
      'hole_number': holeNumber,  // Backend expects snake_case
      'score': strokes,
      if (par != null) 'par': par,  // Optional - backend looks up from course
    });
  }

  Future<List<Score>> getScores(String betId) async {
    final response = await _client.get('/bets/$betId/scores');
    if (kDebugMode) {
      print('📦 Raw scores response: ${response.data}');
    }

    final scoresList = response.data['scores'] as List;
    if (scoresList.isNotEmpty) {
      if (kDebugMode) {
        print('📦 First score sample: ${scoresList.first}');
      }
    }

    return scoresList
        .map((json) {
          try {
            return Score.fromJson(json);
          } catch (e) {
            if (kDebugMode) {
              print('❌ Error parsing score: $e');
              print('   Score data: $json');
            }
            rethrow;
          }
        })
        .toList();
  }

  Future<List<BetParticipant>> getParticipants(String betId) async {
    final response = await _client.get('/bets/$betId/participants');
    return (response.data['participants'] as List)
        .map((json) => BetParticipant.fromJson(json))
        .toList();
  }

  Future<void> completeBet(String betId) async {
    await _client.post('/bets/$betId/complete');
  }

  Future<void> cancelBet(String betId) async {
    await _client.post('/bets/$betId/cancel');
  }

  Future<List<BetOdds>> getOdds(String betId) async {
    final response = await _client.get('/bets/$betId/odds');
    return (response.data['odds'] as List)
        .map((json) => BetOdds.fromJson(json))
        .toList();
  }

  Future<void> recalculateOdds(String betId) async {
    await _client.post('/bets/$betId/recalculate-odds');
  }

  Future<Course> getBetCourse(String betId) async {
    final response = await _client.get('/bets/$betId/course');
    return Course.fromJson(response.data['course']);
  }

  Future<List<Course>> getCourses({String? search}) async {
    final response = await _client.get('/courses', queryParameters: {
      if (search != null) 'search': search,
    });
    return (response.data['courses'] as List)
        .map((json) => Course.fromJson(json))
        .toList();
  }

  Future<Course> getCourseDetails(String courseId) async {
    final response = await _client.get('/courses/$courseId');
    return Course.fromJson(response.data['course']);
  }
}
