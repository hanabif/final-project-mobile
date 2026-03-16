import '../../../../core/network/api_client.dart';

abstract class NotificationRemoteDataSource {
  Future<void> registerDeviceToken(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> registerDeviceToken(String token) async {
    await apiClient.dio.post(
      '/notifications/register-token',
      data: {
        "token": token,
      },
    );
  }
}
