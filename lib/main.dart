import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'config/app_theme.dart';
import 'services/push_notification_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';
import 'screens/wallet/bundle_purchase_screen.dart';
import 'screens/wallet/redeem_screen.dart';
import 'screens/wallet/amoe_screen.dart';
import 'screens/kyc/kyc_submission_screen.dart';
import 'screens/kyc/kyc_status_screen.dart';
import 'services/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/bet_provider.dart';
import 'providers/post_provider.dart';
import 'providers/social_provider.dart';
import 'providers/kyc_provider.dart';
import 'utils/deep_link_handler.dart'; // 🆕 Add deep link handler

/// Background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('🔔 Background message received: ${message.notification?.title}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    if (kDebugMode) print('✅ Firebase initialized');
  } catch (e) {
    if (kDebugMode) print('⚠️  Firebase initialization failed: $e');
  }

  // Initialize Stripe
  try {
    Stripe.publishableKey =
        'pk_test_51SrOScRjEkZhce3z0O4WJ75JkkN59OPbgJp96fhbc9HJ5qCamHgMmaCKynijozdHpnkQ51V3nOMmo0Ac6q9fLQmX0053lNysKn';
    Stripe.merchantIdentifier = 'merchant.com.friendlywager.betcha';
    await Stripe.instance.applySettings();
    if (kDebugMode) print('✅ Stripe initialized');
  } catch (e) {
    if (kDebugMode) print('⚠️  Stripe initialization failed: $e');
  }

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Set system UI overlay style for status bar
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.deepNavy,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BetchaApp());
}

class BetchaApp extends StatefulWidget {
  // 🆕 Changed to StatefulWidget for deep link handler
  const BetchaApp({super.key});

  @override
  State<BetchaApp> createState() => _BetchaAppState();
}

class _BetchaAppState extends State<BetchaApp> {
  // 🆕 Create instance of deep link handler
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();

  @override
  void initState() {
    super.initState();

    // 🆕 Initialize deep link handling after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkHandler.init(context);
      if (kDebugMode) print('🔗 Deep link handler initialized');
    });
  }

  @override
  void dispose() {
    // 🆕 Clean up deep link handler
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize API client (shared instance)
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => WalletProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => BetProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => PostProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SocialProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => KYCProvider(apiClient)),
      ],
      child: MaterialApp(
        title: 'Betcha!',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        routes: {
          '/wallet/bundles': (context) => const BundlePurchaseScreen(),
          '/wallet/redeem': (context) => const RedeemScreen(),
          '/wallet/amoe': (context) => const AMOEScreen(),
          '/kyc/submit': (context) => const KYCSubmissionScreen(),
          '/kyc/status': (context) =>
              const KYCStatusScreen(), // Deep link navigates here
        },
      ),
    );
  }
}

/// Wrapper to check authentication status
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth provider and check for existing session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().init();

      // Initialize push notifications after authentication
      _initializePushNotifications();
    });
  }

  Future<void> _initializePushNotifications() async {
    try {
      final pushService = PushNotificationService();
      await pushService.initialize(
        onMessageReceived: (message) {
          if (kDebugMode) {
            print('📬 Notification received: ${message.notification?.title}');
          }
          // Handle notification based on type
          _handleNotification(message.data);
        },
        onNotificationTapped: (action) {
          if (kDebugMode) print('🔔 Notification tapped: $action');
          // Navigate based on action
          _navigateToScreen(action);
        },
      );
    } catch (e) {
      if (kDebugMode) print('⚠️  Push notification initialization failed: $e');
    }
  }

  void _handleNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == null) return;

    // Refresh relevant data based on notification type
    switch (type) {
      case 'kyc_approved':
      case 'kyc_rejected':
        context.read<KYCProvider>().loadStatus();
        break;
      case 'bundle_purchase':
      case 'redemption_processed':
        context.read<WalletProvider>().loadBalance();
        break;
      case 'bet_won':
      case 'bet_lost':
        context.read<WalletProvider>().loadBalance();
        break;
    }
  }

  void _navigateToScreen(String action) {
    switch (action) {
      case 'open_wallet':
        // Navigate to wallet tab (index 2)
        // This will be handled by MainNavigation
        break;
      case 'open_kyc_status':
        Navigator.of(context).pushNamed('/kyc/status');
        break;
      case 'open_bet_details':
        // Navigate to bets tab (index 1)
        break;
      case 'open_transactions':
        // Navigate to wallet tab, transactions section
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (kDebugMode) {
          print(
            '🏠 AuthWrapper rebuilding - isAuthenticated: ${authProvider.isAuthenticated}, isLoading: ${authProvider.isLoading}',
          );
        }

        // Show loading while checking auth
        if (authProvider.isLoading) {
          if (kDebugMode) {
            print('⏳ Showing loading screen');
          }
          return Scaffold(
            backgroundColor: AppTheme.deepNavy,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.hotPink),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(color: AppTheme.neonBlue),
                  ),
                ],
              ),
            ),
          );
        }

        // Navigate based on auth state
        if (authProvider.isAuthenticated) {
          if (kDebugMode) {
            print('✅ User authenticated - showing MainNavigation');
          }
          return const MainNavigation();
        } else {
          if (kDebugMode) {
            print('❌ User not authenticated - showing LoginScreen');
          }
          return const LoginScreen();
        }
      },
    );
  }
}
