import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification_item.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> registerDevice({
    required String fcmToken,
    required String deviceId,
    required String deviceName,
    required String devicePlatform,
    required String appVersion,
  }) async {
    try {
      await remoteDataSource.registerDevice(
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceName: deviceName,
        devicePlatform: devicePlatform,
        appVersion: appVersion,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unregisterDevice(String deviceId) async {
    try {
      await remoteDataSource.unregisterDevice(deviceId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final models = await remoteDataSource.getNotifications();
      return models.cast<NotificationItem>();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
    } catch (e) {
      rethrow;
    }
  }
}
