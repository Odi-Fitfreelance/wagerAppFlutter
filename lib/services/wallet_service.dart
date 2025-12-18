import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import 'api_client.dart';

class WalletService {
  final ApiClient _client;

  WalletService(this._client);

  Future<double> getBalance() async {
    final response = await _client.get('/wallet/balance');
    if (kDebugMode) {
      print('📦 Raw balance response: ${response.data}');
    }

    final balance = response.data['points_balance'];
    if (balance == null) {
      if (kDebugMode) {
        print('⚠️ Balance is null, returning 0.0');
      }
      return 0.0;
    }
    return balance is int ? balance.toDouble() : balance.toDouble();
  }

  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    final response = await _client.get('/wallet/transactions', queryParameters: {
      'limit': limit,
      'offset': (page - 1) * limit,
      if (type != null) 'type': type,
    });
    return (response.data['transactions'] as List)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  Future<WalletStats?> getStats() async {
    final response = await _client.get('/wallet/stats');
    if (kDebugMode) {
      print('📦 Raw stats response: ${response.data}');
    }

    if (response.data == null) {
      if (kDebugMode) {
        print('⚠️ Stats response is null, returning null');
      }
      return null;
    }
    return WalletStats.fromJson(response.data);
  }

  Future<void> purchasePoints({
    required String packageId,
    String? paymentMethodId,
  }) async {
    await _client.post('/wallet/purchase/points', data: {
      'packageId': packageId,
      if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
    });
  }

  Future<void> withdrawCash(double amount) async {
    await _client.post('/wallet/withdraw', data: {
      'amount': amount,
    });
  }
}
