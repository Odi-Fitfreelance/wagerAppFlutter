import 'package:flutter/foundation.dart';
import '../models/wallet_balance.dart';
import '../models/bundle.dart';
import '../models/transaction.dart';
import 'api_client.dart';

class WalletService {
  final ApiClient _client;

  WalletService(this._client);

  /// Get wallet balance with GC/SC breakdown
  Future<WalletBalance> getBalance() async {
    final response = await _client.get('/wallet/balance');
    if (kDebugMode) {
      print('📦 Raw balance response: ${response.data}');
    }
    return WalletBalance.fromJson(response.data);
  }

  /// Get available coin bundles
  Future<List<Bundle>> getBundles() async {
    final response = await _client.get('/wallet/bundles');
    if (kDebugMode) {
      print('📦 Bundles response: ${response.data}');
    }
    return (response.data['bundles'] as List)
        .map((json) => Bundle.fromJson(json))
        .toList();
  }

  /// Create a payment intent for bundle purchase
  /// Returns client_secret for Stripe payment sheet
  Future<Map<String, dynamic>> createPaymentIntent({
    required String bundleId,
  }) async {
    final response = await _client.post(
      '/wallet/purchase/create-payment-intent',
      data: {'bundleId': bundleId},
    );
    if (kDebugMode) {
      print('✅ Payment intent created: ${response.data}');
    }
    return response.data;
  }

  /// Purchase a coin bundle (GC + bonus SC) - DEPRECATED
  /// Use createPaymentIntent instead for proper Stripe integration
  @deprecated
  Future<Map<String, dynamic>> purchaseBundle({
    required String bundleId,
    String? paymentMethodId,
  }) async {
    final response = await _client.post(
      '/wallet/purchase/bundle',
      data: {
        'bundleId': bundleId,
        if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
      },
    );
    if (kDebugMode) {
      print('✅ Bundle purchase response: ${response.data}');
    }
    return response.data;
  }

  /// Redeem Sweeps Coins for gift cards
  Future<Map<String, dynamic>> redeemSC({
    required int scAmount,
    required String cardType,
  }) async {
    if (scAmount < 50) {
      throw ApiException(
        message: 'Minimum redemption is 50 SC (\$50 USD value)',
      );
    }

    final response = await _client.post(
      '/wallet/redeem',
      data: {'scAmount': scAmount, 'cardType': cardType},
    );

    if (kDebugMode) {
      print('✅ Redemption response: ${response.data}');
    }
    return response.data;
  }

  /// Request free SC via AMOE (Alternative Method of Entry)
  Future<Map<String, dynamic>> requestAMOE({
    required String requesterName,
    required String requesterAddress,
    String requestMethod = 'online_form',
  }) async {
    final response = await _client.post(
      '/wallet/amoe/request',
      data: {
        'requester_name': requesterName,
        'requester_address': requesterAddress,
        'request_method': requestMethod,
      },
    );

    if (kDebugMode) {
      print('✅ AMOE request response: ${response.data}');
    }
    return response.data;
  }

  /// Get transaction history
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    final response = await _client.get(
      '/wallet/transactions',
      queryParameters: {
        'limit': limit,
        'offset': (page - 1) * limit,
        if (type != null) 'type': type,
      },
    );
    return (response.data['transactions'] as List)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  /// Get wallet statistics
  Future<WalletStats?> getStats() async {
    final response = await _client.get('/wallet/stats');
    if (kDebugMode) {
      print('📦 Stats response: ${response.data}');
    }

    if (response.data == null) {
      return null;
    }
    return WalletStats.fromJson(response.data);
  }

  // ==========================================
  // DEPRECATED (Keep for backward compatibility)
  // ==========================================

  @deprecated
  Future<double> getBalanceOld() async {
    final balance = await getBalance();
    return balance.gcBalance.toDouble(); // Return GC as "points"
  }

  @deprecated
  Future<void> purchasePoints({
    required String packageId,
    String? paymentMethodId,
  }) async {
    // Map old package IDs to new bundle IDs
    // This would need actual bundle IDs from your backend
    throw UnimplementedError(
      'Use purchaseBundle() instead. Old point packages are deprecated.',
    );
  }

  @deprecated
  Future<void> withdrawCash(double amount) async {
    throw UnimplementedError(
      'Use redeemSC() instead. Cash withdrawals are no longer supported. Use gift card redemptions.',
    );
  }
}

/// Extension to format currency amounts
extension CurrencyFormat on int {
  /// Format as Gold Coins (e.g., "10,000 GC")
  String get asGC {
    return '${toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} GC';
  }

  /// Format as Sweeps Coins (e.g., "50 SC")
  String get asSC {
    return '$this SC';
  }

  /// Format as USD (e.g., "\$50.00")
  String get asUSD {
    return '\$${toDouble().toStringAsFixed(2)}';
  }
}
