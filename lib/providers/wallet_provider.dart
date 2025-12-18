import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/api_client.dart';
import '../services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService;

  double _balance = 0.0;
  WalletStats? _stats;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  WalletProvider(ApiClient client) : _walletService = WalletService(client);

  double get balance => _balance;
  WalletStats? get stats => _stats;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBalance() async {
    try {
      _balance = await _walletService.getBalance();
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

  Future<void> purchasePoints({
    required String packageId,
    String? paymentMethodId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _walletService.purchasePoints(
        packageId: packageId,
        paymentMethodId: paymentMethodId,
      );
      await loadBalance();
      await loadTransactions();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> withdrawCash(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _walletService.withdrawCash(amount);
      await loadBalance();
      await loadTransactions();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
