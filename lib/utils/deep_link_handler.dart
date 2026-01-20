import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kyc_provider.dart';

/// Handles deep links / app links for KYC verification callbacks
class DeepLinkHandler {
  final _appLinks = AppLinks(); // ← new main class
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link listener
  /// Best called in main.dart or very early (e.g. after MaterialApp is built)
  Future<void> init(BuildContext context) async {
    debugPrint('🔗 Initializing app_links handler...');

    // 1. Handle link when app is already running (stream)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('🔗 App link received (app running): $uri');
        _handleDeepLink(context, uri);
      },
      onError: (err) {
        debugPrint('❌ App link stream error: $err');
      },
    );

    // 2. Handle link that opened the app (cold start / terminated)
    await _handleInitialLink(context);

    // Optional: on iOS & Android, you can also get the latest link
    // (sometimes useful after hot restart / in some edge cases)
    // Note: the 'app_links' package does not provide a getLatestAppLink() method.
    // We already handle the initial app link (getInitialAppLink) and live updates
    // via uriLinkStream above, so avoid calling an undefined API here.
    // If you need a "latest" pending link, implement platform-specific logic or
    // use a different plugin that exposes that capability.
  }

  Future<void> _handleInitialLink(BuildContext context) async {
    try {
      // Use the stream to attempt to read a single initial link event with a short timeout.
      Uri? initialUri;
      try {
        initialUri = await _appLinks.uriLinkStream.first.timeout(
          const Duration(milliseconds: 500),
        );
      } on TimeoutException {
        initialUri = null;
      }

      if (initialUri != null) {
        debugPrint('🔗 Initial app link (cold start): $initialUri');
        _handleDeepLink(context, initialUri);
      } else {
        debugPrint('🔗 No initial app link');
      }
    } catch (e) {
      debugPrint('❌ Failed to get initial app link: $e');
    }
  }

  void _handleDeepLink(BuildContext context, Uri uri) {
    debugPrint('🔗 Processing: $uri');
    debugPrint('   Scheme: ${uri.scheme}');
    debugPrint('   Host: ${uri.host}');
    debugPrint('   Path: ${uri.path}');

    // Your expected format: friendlywager://kyc/result?session_id=xxx&status=xxx
    if (uri.scheme == 'friendlywager' &&
        uri.host == 'kyc' &&
        uri.path == '/result') {
      final sessionId = uri.queryParameters['session_id'];
      final status = uri.queryParameters['status'];

      debugPrint('✅ KYC callback detected!');
      debugPrint('   Session ID: $sessionId');
      debugPrint('   Status: $status');

      // Refresh status
      context.read<KYCProvider>().loadStatus();

      // Navigation - be careful with context!
      // This can be called very early → Navigator might not be ready
      // Better patterns: use global navigator key or go_router redirect
      try {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/kyc/status', (route) => route.isFirst);

        _showStatusMessage(context, status);
      } catch (e) {
        debugPrint('Navigation failed (context not ready?): $e');
        // Fallback: maybe store the deep link and handle later
      }
    } else {
      debugPrint('⚠️ Unknown app link: $uri');
    }
  }

  // Optional: helper to avoid processing same link multiple times
  void _showStatusMessage(BuildContext context, String? status) {
    if (status == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    late SnackBar snackBar;

    switch (status.toLowerCase()) {
      case 'completed':
        snackBar = const SnackBar(
          content: Text(
            '✅ Verification completed! We will review your documents within 24-48 hours.',
          ),
          backgroundColor: Colors.green,
        );
        break;
      case 'cancelled':
        snackBar = const SnackBar(
          content: Text('⚠️ Verification was cancelled. Try again anytime.'),
          backgroundColor: Colors.orange,
        );
        break;
      case 'expired':
        snackBar = const SnackBar(
          content: Text('⏰ Session expired. Please start a new verification.'),
          backgroundColor: Colors.red,
        );
        break;
      default:
        snackBar = SnackBar(content: Text('Status: $status'));
    }

    scaffoldMessenger.showSnackBar(snackBar);
  }

  void dispose() {
    debugPrint('🔗 Disposing app_links handler');
    _linkSubscription?.cancel();
  }
}
