  import 'dart:async';

  import 'package:firebase_core/firebase_core.dart';
  import 'package:firebase_messaging/firebase_messaging.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/foundation.dart';
  import 'package:get_it/get_it.dart';
  import 'package:package_info_plus/package_info_plus.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:uuid/uuid.dart';
  import '../cubit/notification_cubit.dart';
  import '../../domain/entities/notification_item.dart';
  import '../../domain/repositories/notification_repository.dart';
  import '../../../../core/utils/navigator_key.dart';
  import '../../../../core/routes/route_names.dart';

  class FirebaseNotificationService {
    static const String _deviceIdKey = 'notification_device_id';
    StreamSubscription<String>? _tokenRefreshSubscription;
    OverlayEntry? _activeNotificationOverlay;
    Timer? _notificationPopupTimer;

    FirebaseMessaging? get _fcm {
      try {
        if (Firebase.apps.isNotEmpty) {
          return FirebaseMessaging.instance;
        }
      } catch (_) {}
      return null;
    }

    final NotificationRepository _repository;
    final SharedPreferences _sharedPreferences;

    FirebaseNotificationService(this._repository, this._sharedPreferences);

    NotificationCubit? get _notificationCubit {
      try {
        return GetIt.instance<NotificationCubit>();
      } catch (_) {
        return null;
      }
    }

    Future<bool> _areNotificationsEnabled() async {
      // Check if notifications are enabled in settings
      // Default to true if not set (for backwards compatibility)
      return _sharedPreferences.getBool('isNotificationsEnabled') ?? true;
    }

    Future<String> _getOrCreateDeviceId() async {
      final existingDeviceId = _sharedPreferences.getString(_deviceIdKey);
      if (existingDeviceId != null && existingDeviceId.isNotEmpty) {
        return existingDeviceId;
      }

      final deviceId = const Uuid().v4();
      await _sharedPreferences.setString(_deviceIdKey, deviceId);
      return deviceId;
    }

    String _getDevicePlatform() {
      if (kIsWeb) {
        return 'web';
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'android';
        case TargetPlatform.iOS:
          return 'ios';
        case TargetPlatform.macOS:
          return 'macos';
        case TargetPlatform.windows:
          return 'windows';
        case TargetPlatform.linux:
          return 'linux';
        case TargetPlatform.fuchsia:
          return 'fuchsia';
      }
    }

    String _getDeviceName() {
      if (kIsWeb) {
        return 'Web';
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'Android device';
        case TargetPlatform.iOS:
          return 'iOS device';
        case TargetPlatform.macOS:
          return 'macOS device';
        case TargetPlatform.windows:
          return 'Windows device';
        case TargetPlatform.linux:
          return 'Linux device';
        case TargetPlatform.fuchsia:
          return 'Fuchsia device';
      }
    }

    Future<String> _getAppVersion() async {
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        if (packageInfo.buildNumber.isNotEmpty) {
          return '${packageInfo.version}+${packageInfo.buildNumber}';
        }
        return packageInfo.version;
      } catch (e) {
        debugPrint(
          '⚠️ [FirebaseNotificationService] Unable to read app version: $e',
        );
        return 'unknown';
      }
    }

    Future<void> registerDevice(String fcmToken) async {
      if (fcmToken.isEmpty) {
        return;
      }

      final notificationsEnabled = await _areNotificationsEnabled();
      if (!notificationsEnabled) {
        debugPrint(
          '⚠️ [FirebaseNotificationService] Notifications are disabled. Skipping device registration.',
        );
        return;
      }

      final deviceId = await _getOrCreateDeviceId();
      final appVersion = await _getAppVersion();

      await _repository.registerDevice(
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceName: _getDeviceName(),
        devicePlatform: _getDevicePlatform(),
        appVersion: appVersion,
      );
    }

    Future<void> unregisterDevice() async {
      final deviceId = _sharedPreferences.getString(_deviceIdKey);
      if (deviceId == null || deviceId.isEmpty) {
        return;
      }

      await _repository.unregisterDevice(deviceId);
    }

    Future<void> initialize() async {
      if (Firebase.apps.isEmpty) {
        debugPrint(
          '⚠️ [FirebaseNotificationService] Firebase not initialized. Skipping setup.',
        );
        return;
      }

      // Check if notifications are disabled by user
      final notificationsEnabled = await _areNotificationsEnabled();
      if (!notificationsEnabled) {
        debugPrint(
          '⚠️ [FirebaseNotificationService] Notifications are disabled by user. Skipping initialization.',
        );
        await unregisterDevice();
        return;
      }

      debugPrint(
        '🔔 [FirebaseNotificationService] Initializing notifications...',
      );
      // Request permission
      NotificationSettings? settings = await _fcm?.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings?.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings?.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }

      // Handle foreground messages
      // Guard static properties for Web safety
      try {
        await _tokenRefreshSubscription?.cancel();
        _tokenRefreshSubscription = _fcm?.onTokenRefresh.listen((token) async {
          try {
            if (await _areNotificationsEnabled()) {
              await registerDevice(token);
            }
          } catch (e) {
            debugPrint(
              '⚠️ [FirebaseNotificationService] Failed to sync refreshed token: $e',
            );
          }
        });

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint(
              'Message also contained a notification: ${message.notification}',
            );
            _syncNotificationState(message);
            _showNotificationPopup(message);
          }
        });

        // Handle background messages (handler registered as a top-level function)
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // Get initial message if app was opened from a terminated state
        RemoteMessage? initialMessage = await _fcm?.getInitialMessage();
        if (initialMessage != null) {
          _handleMessage(initialMessage);
        }

        // Handle when app is in background but opened via notification
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      } catch (e) {
        debugPrint('FirebaseMessaging static listeners failed to initialize: $e');
      }
    }

    Future<String?> getDeviceToken() async {
      try {
        String? token = await _fcm?.getToken();
        debugPrint(
          "------------------------------------------------------------------",
        );
        debugPrint("🚀 [FirebaseNotificationService] FCM DEVICE TOKEN:");
        debugPrint("$token");
        debugPrint(
          "------------------------------------------------------------------",
        );

        if (token != null) {
          await registerDevice(token);
          debugPrint("FCM Token registered with backend successfully");
        }

        return token;
      } catch (e) {
        debugPrint("Error getting or registering FCM token: $e");
        return null;
      }
    }

    void _handleMessage(RemoteMessage message) {
      debugPrint("Handling notification message: ${message.messageId}");

      _syncNotificationState(message);

      final String? complaintId = message.data['complaintId'];

      if (complaintId != null && navigatorKey.currentState != null) {
        debugPrint("Navigating to complaint status with ID: $complaintId");
        navigatorKey.currentState!.pushNamed(
          RouteNames.complaintStatus,
          arguments: complaintId,
        );
      }
    }

    void _showNotificationPopup(RemoteMessage message) {
      final overlay = navigatorKey.currentState?.overlay;
      if (overlay == null) return;

      final String title = message.notification?.title ?? 'New Notification';
      final String body = message.notification?.body ?? '';
      final String popupKey =
          message.messageId ??
          '${title.hashCode}-${body.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

      _dismissNotificationPopup();

      _activeNotificationOverlay = OverlayEntry(
        builder: (context) {
          final topInset = MediaQuery.of(context).padding.top + 12;
          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final popupBackground = colorScheme.surface;
          final popupForeground = colorScheme.onSurface;
          final popupBorder = isDark
              ? Colors.white.withValues(alpha: 0.08)
              : colorScheme.primary.withValues(alpha: 0.12);
          final accentColor = colorScheme.primary;

          return Positioned(
            top: topInset,
            left: 16,
            right: 16,
            child: Dismissible(
              key: ValueKey<String>(popupKey),
              direction: DismissDirection.startToEnd,
              onDismissed: (_) => _dismissNotificationPopup(),
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: popupBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: popupBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.18 : 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: accentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: popupForeground,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: popupForeground.withValues(alpha: 0.75),
                                fontSize: 12,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _dismissNotificationPopup();
                          navigatorKey.currentState?.pushNamed(RouteNames.notifications);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSecondary,
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(_activeNotificationOverlay!);
      _notificationPopupTimer?.cancel();
      _notificationPopupTimer = Timer(const Duration(seconds: 5), _dismissNotificationPopup);
    }

    void _dismissNotificationPopup() {
      _notificationPopupTimer?.cancel();
      _notificationPopupTimer = null;
      _activeNotificationOverlay?.remove();
      _activeNotificationOverlay = null;
    }

    void _syncNotificationState(RemoteMessage message) {
      final cubit = _notificationCubit;
      if (cubit == null) return;

      final title =
          message.notification?.title ??
          message.data['title']?.toString() ??
          'New Notification';
      final body =
          message.notification?.body ?? message.data['body']?.toString() ?? '';
      final complaintId = message.data['complaintId']?.toString();
      final notificationId = message.messageId ?? const Uuid().v4();

      cubit.addNotification(
        NotificationItem(
          id: notificationId,
          title: title,
          body: body,
          date: DateTime.now(),
          isRead: false,
          complaintId: complaintId,
        ),
      );
    }
  }

  // Top-level function for background message handling
  @pragma('vm:entry-point')
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint("Handling a background message: ${message.messageId}");
  }
