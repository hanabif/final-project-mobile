import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> registerDeviceToken(String token) async {
    try {
      await remoteDataSource.registerDeviceToken(token);
    } catch (e) {
      // Re-throw or handle specific exceptions if needed
      rethrow;
    }
  }
}
