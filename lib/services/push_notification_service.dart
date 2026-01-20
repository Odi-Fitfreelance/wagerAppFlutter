import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;
import 'api_client.dart';

/// Push Notification Service
/// Handles Firebase Cloud Messaging and local notifications
///
/// SETUP REQUIRED:
/// 1. Add google-services.json (Android) and GoogleService-Info.plist (iOS)
/// 2. Configure Firebase project at https://console.firebase.google.com
/// 3. Enable Cloud Messaging API
/// 4. Configure APNs (iOS) and FCM (Android)
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;
  Function(RemoteMessage)? _onMessageReceived;
  Function(String)? _onNotificationTapped;

  /// Initialize push notifications
  /// Call this once at app startup
  Future<void> initialize({
    Function(RemoteMessage)? onMessageReceived,
    Function(String)? onNotificationTapped,
  }) async {
    if (_initialized) {
      if (kDebugMode) print('📱 Push notifications already initialized');
      return;
    }

    try {
      _onMessageReceived = onMessageReceived;
      _onNotificationTapped = onNotificationTapped;

      // Request permission (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        if (kDebugMode) print('⚠️  Push notification permission denied');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) print('📱 FCM Token: $_fcmToken');

      // Register token with backend
      if (_fcmToken != null) {
        await _registerDeviceWithBackend(_fcmToken!);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _registerDeviceWithBackend(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Check if app was opened from a notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessageTap(initialMessage);
      }

      _initialized = true;
      if (kDebugMode) print('✅ Push notifications initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to initialize push notifications: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && _onNotificationTapped != null) {
          _onNotificationTapped!(details.payload!);
        }
      },
    );

    // Create notification channel (Android)
    const androidChannel = AndroidNotificationChannel(
      'betcha_notifications',
      'Betcha Notifications',
      description: 'Notifications for bet updates, KYC status, and more',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Register device token with backend
  Future<void> _registerDeviceWithBackend(String token) async {
    try {
      final apiClient = ApiClient();
      final deviceType = Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web';

      // Get app version from package info
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      await apiClient.post('/notifications/register', data: {
        'deviceToken': token,
        'deviceType': deviceType,
        'deviceName': Platform.operatingSystem,
        'appVersion': appVersion,
      });

      if (kDebugMode) print('✅ Device registered with backend');
    } catch (e) {
      if (kDebugMode) print('⚠️  Failed to register device: $e');
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📬 Foreground message received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Call custom handler
    if (_onMessageReceived != null) {
      _onMessageReceived!(message);
    }

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle background message tap
  void _handleBackgroundMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      print('🔔 Background notification tapped');
      print('Data: ${message.data}');
    }

    // Navigate based on notification type
    final action = message.data['action'] as String?;
    if (action != null && _onNotificationTapped != null) {
      _onNotificationTapped!(action);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'betcha_notifications',
      'Betcha Notifications',
      channelDescription: 'Notifications for bet updates, KYC status, and more',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data['action'] as String?,
    );
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Check if initialized
  bool get isInitialized => _initialized;

  /// Unregister device
  Future<void> unregisterDevice() async {
    if (_fcmToken == null) return;

    try {
      final apiClient = ApiClient();
      await apiClient.post('/notifications/unregister', data: {
        'deviceToken': _fcmToken,
      });

      if (kDebugMode) print('✅ Device unregistered');
    } catch (e) {
      if (kDebugMode) print('⚠️  Failed to unregister device: $e');
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Check notification permission status
  Future<bool> hasPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}

/// Background message handler (must be top-level function)
/// Configure in main.dart:
/// FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('🔔 Background message received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}
