import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification_item.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> registerDeviceToken(String token) async {
    try {
      await remoteDataSource.registerDeviceToken(token);
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
