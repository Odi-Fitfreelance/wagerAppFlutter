import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kyc_session.dart';
import 'api_client.dart';

class KYCService {
  final ApiClient _client;

  KYCService(this._client);

  /// Get current KYC session status
  Future<KYCSession> getKYCStatus() async {
    final response = await _client.get('/kyc/status');
    if (kDebugMode) {
      print('📋 KYC Status response: ${response.data}');
    }
    return KYCSession.fromJson(response.data);
  }

  /// Submit KYC verification request - Returns session with verification URL
  Future<KYCSessionResponse> submitKYC(KYCSubmissionRequest request) async {
    final response = await _client.post('/kyc/submit', data: request.toJson());

    if (kDebugMode) {
      print('✅ KYC submission response: ${response.data}');
    }

    return KYCSessionResponse.fromJson(response.data);
  }

  /// Open Didit verification URL in browser/webview
  Future<bool> openVerificationUrl(String verificationUrl) async {
    try {
      final uri = Uri.parse(verificationUrl);

      if (await canLaunchUrl(uri)) {
        // Launch in external browser or in-app browser
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // or LaunchMode.inAppWebView
        );
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Could not launch URL: $verificationUrl');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error launching URL: $e');
      }
      return false;
    }
  }

  /// Retry KYC verification (if previously rejected)
  Future<KYCSessionResponse> retryKYC(KYCSubmissionRequest request) async {
    // Mark old session as superseded
    await _client.post('/kyc/retry');

    // Submit new KYC
    return submitKYC(request);
  }

  /// Get session details by session ID
  Future<Map<String, dynamic>> getSessionDetails(String sessionId) async {
    final response = await _client.get('/kyc/session/$sessionId');
    return response.data;
  }

  /// Check if user meets minimum age requirement (18+)
  bool isEligibleAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      return age - 1 >= 18;
    }
    return age >= 18;
  }

  /// Check if state is restricted for sweepstakes
  bool isRestrictedState(String? stateCode) {
    if (stateCode == null) return false;
    const restrictedStates = ['WA', 'ID', 'NV', 'MT'];
    return restrictedStates.contains(stateCode.toUpperCase());
  }

  /// Validate KYC submission data before sending
  String? validateSubmission(KYCSubmissionRequest request) {
    // Check required fields
    if (request.firstName.isEmpty) {
      return 'First name is required';
    }
    if (request.lastName.isEmpty) {
      return 'Last name is required';
    }
    if (request.email.isEmpty) {
      return 'Email is required';
    }
    if (request.address.isEmpty) {
      return 'Address is required';
    }
    if (request.city.isEmpty) {
      return 'City is required';
    }
    if (request.state.isEmpty) {
      return 'State is required';
    }
    if (request.zipCode.isEmpty) {
      return 'ZIP code is required';
    }

    // Check age requirement
    try {
      final dob = DateTime.parse(request.dateOfBirth);
      if (!isEligibleAge(dob)) {
        return 'You must be at least 18 years old to verify your account';
      }
    } catch (e) {
      return 'Invalid date of birth format';
    }

    // Check restricted state
    if (isRestrictedState(request.state)) {
      return 'Sweepstakes verification is not available in ${request.state}. Restricted states: WA, ID, NV, MT';
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(request.email)) {
      return 'Invalid email format';
    }

    // ZIP code validation (US)
    final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
    if (!zipRegex.hasMatch(request.zipCode)) {
      return 'Invalid ZIP code format';
    }

    return null; // All validations passed
  }

  /// Get estimated KYC review time based on current session
  String getEstimatedReviewTime(KYCSession session) {
    if (session.estimatedReviewTime != null) {
      return session.estimatedReviewTime!;
    }

    // Default estimates
    switch (session.status) {
      case KYCStatus.pending:
        return '1-2 business days';
      case KYCStatus.manualReview:
        return '3-5 business days';
      default:
        return 'N/A';
    }
  }

  /// Format KYC status for user display
  String formatStatusMessage(KYCSession session) {
    switch (session.status) {
      case KYCStatus.notSubmitted:
        return 'Complete identity verification to unlock Sweeps Coins redemption';
      case KYCStatus.pending:
        return 'Your verification is being reviewed. This typically takes 1-2 business days.';
      case KYCStatus.manualReview:
        return 'Your verification requires additional review. This may take 3-5 business days.';
      case KYCStatus.approved:
        return 'Your identity has been verified! You can now bet with Sweeps Coins and redeem for prizes.';
      case KYCStatus.rejected:
        return session.rejectionReason ??
            'Your verification was unsuccessful. Please review the requirements and try again.';
      case KYCStatus.completed:
        return 'Verification complete and pending final approval.';
    }
  }

  /// Check if user needs to complete KYC for SC features
  bool requiresKYCForAction(String action, KYCSession session) {
    switch (action) {
      case 'bet_sc':
        return session.status != KYCStatus.approved;
      case 'redeem_sc':
        return session.status != KYCStatus.approved;
      case 'purchase_bundle':
        return false; // No KYC required for purchases
      default:
        return false;
    }
  }
}

/// Response from KYC submission including verification URL
class KYCSessionResponse {
  final bool success;
  final String sessionId;
  final String? verificationUrl;
  final String status;
  final String? estimatedReviewTime;
  final String? message;

  KYCSessionResponse({
    required this.success,
    required this.sessionId,
    this.verificationUrl,
    required this.status,
    this.estimatedReviewTime,
    this.message,
  });

  factory KYCSessionResponse.fromJson(Map<String, dynamic> json) {
    return KYCSessionResponse(
      success: json['success'] ?? true,
      sessionId: json['sessionId'] as String,
      verificationUrl: json['verificationUrl'] as String?,
      status: json['status'] as String,
      estimatedReviewTime: json['estimatedReviewTime'] as String?,
      message: json['message'] as String?,
    );
  }
}
