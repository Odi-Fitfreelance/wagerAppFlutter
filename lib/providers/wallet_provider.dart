import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/wallet_balance.dart';
import '../models/bundle.dart';
import '../services/api_client.dart';
import '../services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService;

  // Sweepstakes wallet state
  WalletBalance? _walletBalance;
  List<Bundle> _bundles = [];
  WalletStats? _stats;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Legacy field for backward compatibility
  @Deprecated('Use walletBalance.gcBalance instead')
  double _balance = 0.0;

  WalletProvider(ApiClient client) : _walletService = WalletService(client);

  // Sweepstakes getters
  WalletBalance? get walletBalance => _walletBalance;
  List<Bundle> get bundles => _bundles;
  WalletStats? get stats => _stats;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Legacy getter
  @Deprecated('Use walletBalance.gcBalance instead')
  double get balance => _balance;

  // Convenience getters
  int get gcBalance => _walletBalance?.gcBalance ?? 0;
  int get scBalance => _walletBalance?.scBalance ?? 0;
  int get redeemableSc => _walletBalance?.redeemableSc ?? 0;
  int get scPlaythroughRemaining => _walletBalance?.scPlaythroughRemaining ?? 0;
  bool get canRedeemSC => _walletBalance?.canRedeem ?? false;
  double get playthroughProgress => _walletBalance?.playthroughProgress ?? 0.0;

  /// Load wallet balance with GC/SC breakdown
  Future<void> loadBalance() async {
    try {
      _walletBalance = (await _walletService.getBalance()) as WalletBalance?;
      // Update legacy field for backward compatibility
      _balance = _walletBalance?.gcBalance.toDouble() ?? 0.0;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  /// Load available coin bundles
  Future<void> loadBundles() async {
    try {
      _bundles = await _walletService.getBundles();
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await _walletService.getStats();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> loadTransactions({String? type}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _walletService.getTransactions(type: type);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a payment intent for bundle purchase
  /// Returns client_secret for Stripe payment sheet
  Future<Map<String, dynamic>?> createPaymentIntent({
    required String bundleId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _walletService.createPaymentIntent(
        bundleId: bundleId,
      );
      _errorMessage = null;
      return result;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase a coin bundle (GC + bonus SC) - DEPRECATED
  /// Use createPaymentIntent instead for proper Stripe integration
  @deprecated
  Future<Map<String, dynamic>?> purchaseBundle({
    required String bundleId,
    String? paymentMethodId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _walletService.purchaseBundle(
        bundleId: bundleId,
        paymentMethodId: paymentMethodId,
      );
      await loadBalance();
      await loadTransactions();
      _errorMessage = null;
      return result;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Redeem Sweeps Coins for gift cards
  Future<Map<String, dynamic>?> redeemSC({
    required int scAmount,
    required String cardType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _walletService.redeemSC(
        scAmount: scAmount,
        cardType: cardType,
      );
      await loadBalance();
      await loadTransactions();
      _errorMessage = null;
      return result;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request free SC via AMOE (Alternative Method of Entry)
  Future<Map<String, dynamic>?> requestAMOE({
    required String requesterName,
    required String requesterAddress,
    String requestMethod = 'online_form',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _walletService.requestAMOE(
        requesterName: requesterName,
        requesterAddress: requesterAddress,
        requestMethod: requestMethod,
      );
      await loadBalance();
      await loadTransactions();
      _errorMessage = null;
      return result;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize wallet data (load balance, bundles, and transactions)
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([loadBalance(), loadBundles(), loadTransactions()]);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize wallet';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // DEPRECATED METHODS (backward compatibility)
  // ==========================================

  @deprecated
  Future<void> purchasePoints(
    String string, {
    required String packageId,
    String? paymentMethodId,
  }) async {
    throw UnimplementedError(
      'Use purchaseBundle() instead. Old point packages are deprecated.',
    );
  }

  @deprecated
  Future<void> withdrawCash(double amount) async {
    throw UnimplementedError(
      'Use redeemSC() instead. Cash withdrawals are no longer supported.',
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
