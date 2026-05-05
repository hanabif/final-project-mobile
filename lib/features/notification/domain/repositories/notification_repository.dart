import '../entities/notification_item.dart';

abstract class NotificationRepository {
  Future<void> registerDeviceToken(String token);
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAllAsRead();
}
