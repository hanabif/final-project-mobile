import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> registerDeviceToken(String token);
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAllAsRead();
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

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.dio.get('/notifications');
    final data = response.data;

    List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      final candidate = data['data'] ?? data['notifications'] ?? data['items'] ?? data['results'];
      rawList = candidate is List ? candidate : <dynamic>[];
    } else {
      rawList = <dynamic>[];
    }

    return rawList
        .whereType<Map>()
        .map((item) => NotificationModel.fromJson(item.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> markAllAsRead() async {
    await apiClient.dio.put('/notifications/read-all');
  }
}
