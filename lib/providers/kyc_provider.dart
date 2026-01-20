import 'package:flutter/foundation.dart';
import '../models/kyc_session.dart';
import '../services/api_client.dart';
import '../services/kyc_service.dart';

class KYCProvider with ChangeNotifier {
  final KYCService _kycService;

  KYCSession? _session;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationUrl; // Store the Didit verification URL

  KYCProvider(ApiClient client) : _kycService = KYCService(client);

  KYCSession? get session => _session;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get verificationUrl => _verificationUrl;

  // Convenience getters
  bool get isApproved => _session?.isApproved ?? false;
  bool get isPending => _session?.isPending ?? false;
  bool get isRejected => _session?.isRejected ?? false;
  bool get canRetry => _session?.canRetry ?? false;
  KYCStatus get status => _session?.status ?? KYCStatus.notSubmitted;
  String get statusText => _session?.statusText ?? 'Not Submitted';

  /// Load current KYC session status
  Future<void> loadStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _session = await _kycService.getKYCStatus();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit KYC verification request and get verification URL
  Future<bool> submitKYC(KYCSubmissionRequest request) async {
    // Validate submission first
    final validationError = _kycService.validateSubmission(request);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _kycService.submitKYC(request);

      // Check if verification URL was provided
      if (response.verificationUrl == null || response.verificationUrl!.isEmpty) {
        _errorMessage = 'Verification URL not provided by identity verification service';
        notifyListeners();
        return false;
      }

      // Store the verification URL
      _verificationUrl = response.verificationUrl;

      // Update session status to pending
      _session = KYCSession(
        sessionId: response.sessionId,
        status: KYCStatus.pending,
        message: response.message,
        estimatedReviewTime: response.estimatedReviewTime,
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Open verification URL in browser
  Future<bool> openVerification() async {
    if (_verificationUrl == null) {
      _errorMessage = 'No verification URL available';
      notifyListeners();
      return false;
    }

    try {
      final success = await _kycService.openVerificationUrl(_verificationUrl!);
      if (!success) {
        _errorMessage = 'Failed to open verification page';
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error opening verification: $e';
      notifyListeners();
      return false;
    }
  }

  /// Retry KYC verification (if previously rejected)
  Future<bool> retryKYC(KYCSubmissionRequest request) async {
    if (!canRetry) {
      _errorMessage = 'Cannot retry KYC at this time';
      notifyListeners();
      return false;
    }

    // Validate submission first
    final validationError = _kycService.validateSubmission(request);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _kycService.retryKYC(request);

      // Store the new verification URL
      _verificationUrl = response.verificationUrl;

      // Update session
      _session = KYCSession(
        sessionId: response.sessionId,
        status: KYCStatus.pending,
        message: response.message,
        estimatedReviewTime: response.estimatedReviewTime,
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user needs KYC for specific action
  bool requiresKYCForAction(String action) {
    if (_session == null) return true;
    return _kycService.requiresKYCForAction(action, _session!);
  }

  /// Get formatted status message for user display
  String getStatusMessage() {
    if (_session == null) {
      return 'Complete identity verification to unlock Sweeps Coins features';
    }
    return _kycService.formatStatusMessage(_session!);
  }

  /// Get estimated review time
  String getEstimatedReviewTime() {
    if (_session == null) return 'N/A';
    return _kycService.getEstimatedReviewTime(_session!);
  }

  /// Check if date of birth meets age requirement
  bool isEligibleAge(DateTime dateOfBirth) {
    return _kycService.isEligibleAge(dateOfBirth);
  }

  /// Check if state is restricted
  bool isRestrictedState(String? stateCode) {
    return _kycService.isRestrictedState(stateCode);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _session = null;
    _isLoading = false;
    _errorMessage = null;
    _verificationUrl = null;
    notifyListeners();
  }
}
