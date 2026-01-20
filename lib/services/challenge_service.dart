import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// Challenge Service
/// Handles video challenge operations including creation, listing, and betting
class ChallengeService {
  final ApiClient _client;

  ChallengeService(this._client);

  /// Upload video and create challenge
  Future<Map<String, dynamic>> createChallenge({
    required String title,
    required String description,
    required String challengeType, // 'fail_land' or 'head_to_head'
    required String videoPath,
    int stakeAmount = 50, // default value to satisfy backend > 0 check
    String stakeCurrency = 'gc',
    int? maxPlayers, // optional – send only if backend supports it
  }) async {
    try {
      if (kDebugMode) {
        print('''
  📹 Creating video challenge:
    Title: $title
    Type: $challengeType
    Stake: $stakeAmount $stakeCurrency
    Max players: ${maxPlayers ?? 'not set'}
    Video: $videoPath
        ''');
      }

      final response = await _client.uploadFile(
        '/videos/challenges',
        'video', // this matches multer.single('video') in your backend route
        videoPath,
        fields: {
          'title': title.trim(),
          'description': description.trim(),
          'challengeType': challengeType,
          'stakeAmount': stakeAmount.toString(),
          'stakeCurrency': stakeCurrency,
          if (maxPlayers != null) 'maxPlayers': maxPlayers.toString(),
        },
        onSendProgress: (sent, total) {
          if (kDebugMode && total > 0) {
            final progress = (sent / total * 100).toStringAsFixed(1);
            print('📤 Upload progress: $progress% ($sent / $total bytes)');
          }
        },
      );

      if (kDebugMode) {
        print('''
  ✅ Challenge created successfully
    Status: ${response.statusCode}
    Response: ${response.data}
        ''');
      }

      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('''
  ❌ Failed to create challenge
    Error: $e
    Stack: $stackTrace
        ''');
      }

      // You can add more specific error handling here if needed
      if (e.toString().contains('max_players')) {
        throw Exception('Max players must be between 2 and 20');
      }
      if (e.toString().contains('stake_amount')) {
        throw Exception('Stake amount must be greater than 0');
      }

      rethrow;
    }
  }

  /// Get list of challenges
  Future<List<Map<String, dynamic>>> getChallenges({
    String? type, // 'fail_land' or 'head_to_head'
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (kDebugMode) {
        print('📋 Fetching challenges (page: $page, type: $type)');
      }

      final response = await _client.get(
        '/videos/challenges',
        queryParameters: {
          if (type != null) 'type': type,
          'page': page,
          'limit': limit,
        },
      );

      final challenges = (response.data['challenges'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      if (kDebugMode) {
        print('✅ Fetched ${challenges.length} challenges');
      }

      return challenges;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to fetch challenges: $e');
      }
      rethrow;
    }
  }

  /// Get challenge details by ID
  Future<Map<String, dynamic>> getChallengeById(String challengeId) async {
    try {
      if (kDebugMode) {
        print('📄 Fetching challenge details: $challengeId');
      }

      final response = await _client.get('/videos/challenges/$challengeId');

      if (kDebugMode) {
        print('✅ Challenge details fetched');
        print('   Full response: ${response.data}');

        final challenge = response.data['challenge'];
        if (challenge != null) {
          print('   Challenge ID: ${challenge['id']}');
          print('   Title: ${challenge['title']}');
          print('   Type: ${challenge['type']}');
          print('   Status: ${challenge['status']}');
          print('   Creator ID: ${challenge['creatorId']}');
          print('   Creator: ${challenge['creator']}');
          print('   Video URL: ${challenge['videoUrl']}');
          print('   Thumbnail URL: ${challenge['thumbnailUrl']}');
          print('   Total Pot: ${challenge['totalPot']}');
          print('   Participants: ${challenge['participants']}');
          print('   Betting Stats: ${challenge['bettingStats']}');
        }
      }

      return response.data['challenge'] as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to fetch challenge details: $e');
      }
      rethrow;
    }
  }

  /// Place bet on a challenge
  Future<Map<String, dynamic>> placeBet({
    required String challengeId,
    required int amount,
    required String coinType, // 'gc' or 'sc'
    String? prediction, // 'fail' or 'land' for fail_land type
  }) async {
    try {
      if (kDebugMode) {
        print('💰 Placing bet: $amount $coinType on challenge $challengeId');
      }

      final response = await _client.post(
        '/videos/challenges/$challengeId/bet',
        data: {
          'amount': amount,
          'coinType': coinType,
          if (prediction != null) 'prediction': prediction,
        },
      );

      if (kDebugMode) {
        print('✅ Bet placed successfully');
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to place bet: $e');
      }
      rethrow;
    }
  }

  /// Get participants for a challenge
  Future<List<Map<String, dynamic>>> getChallengeParticipants(String challengeId) async {
    try {
      if (kDebugMode) {
        print('👥 Fetching participants for challenge: $challengeId');
      }

      final response = await _client.get('/videos/challenges/$challengeId/participants');

      final participants = (response.data['participants'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      if (kDebugMode) {
        print('✅ Fetched ${participants.length} participants');
      }

      return participants;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to fetch participants: $e');
      }
      rethrow;
    }
  }

  /// Close challenge and declare outcome (creator only)
  /// For fail_land: provide outcome ('fail' or 'land')
  /// For head_to_head: provide winnerId
  Future<Map<String, dynamic>> closeChallenge({
    required String challengeId,
    String? outcome, // 'fail' or 'land' for fail_land type
    String? winnerId, // winner user ID for head_to_head type
  }) async {
    try {
      if (kDebugMode) {
        print('🏁 Closing challenge $challengeId');
        if (outcome != null) print('   Outcome: $outcome');
        if (winnerId != null) print('   Winner ID: $winnerId');
      }

      final response = await _client.post(
        '/videos/challenges/$challengeId/close',
        data: {
          if (outcome != null) 'outcome': outcome,
          if (winnerId != null) 'winnerId': winnerId,
        },
      );

      if (kDebugMode) {
        print('✅ Challenge closed successfully');
        print('   Winners: ${response.data['winners']}');
        print('   Losers: ${response.data['losers']}');
        print('   Total pot: ${response.data['totalPot']}');
        print('   Platform fee: ${response.data['platformFee']}');
        print('   Payout pool: ${response.data['payoutPool']}');
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to close challenge: $e');
      }
      rethrow;
    }
  }
}
