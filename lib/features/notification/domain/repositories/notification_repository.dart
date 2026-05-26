import '../entities/notification_item.dart';

abstract class NotificationRepository {
  Future<void> registerDevice({
    required String fcmToken,
    required String deviceId,
    required String deviceName,
    required String devicePlatform,
    required String appVersion,
  });

  Future<void> unregisterDevice(String deviceId);
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
}
