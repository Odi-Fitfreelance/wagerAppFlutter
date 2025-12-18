import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';
import 'services/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/bet_provider.dart';
import 'providers/post_provider.dart';
import 'providers/social_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

class BetchaApp extends StatelessWidget {
  const BetchaApp({super.key});

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
      ],
      child: MaterialApp(
        title: 'Betcha!',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (kDebugMode) {
          print('🏠 AuthWrapper rebuilding - isAuthenticated: ${authProvider.isAuthenticated}, isLoading: ${authProvider.isLoading}');
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
