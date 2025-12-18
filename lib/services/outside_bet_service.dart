import '../models/outside_bet.dart';
import 'api_client.dart';

class OutsideBetService {
  final ApiClient _client;

  OutsideBetService(this._client);

  Future<OutsideBet> placeOutsideBet({
    required String betId,
    required String participantId,
    required double amount,
  }) async {
    final response = await _client.post('/outside-bets/bets/$betId/back', data: {
      'participantId': participantId,
      'amount': amount,
    });
    return OutsideBet.fromJson(response.data['outside_bet']);
  }

  Future<List<OutsideBet>> getMyOutsideBets({String? status}) async {
    final response = await _client.get('/outside-bets/my-bets', queryParameters: {
      if (status != null) 'status': status,
    });
    return (response.data['outside_bets'] as List)
        .map((json) => OutsideBet.fromJson(json))
        .toList();
  }

  Future<List<OutsideBet>> getOutsideBetsForBet(String betId) async {
    final response = await _client.get('/outside-bets/bets/$betId');
    return (response.data['outside_bets'] as List)
        .map((json) => OutsideBet.fromJson(json))
        .toList();
  }
}
