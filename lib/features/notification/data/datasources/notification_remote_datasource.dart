import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> registerDevice({
    required String fcmToken,
    required String deviceId,
    required String deviceName,
    required String devicePlatform,
    required String appVersion,
  });

  Future<void> unregisterDevice(String deviceId);
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> registerDevice({
    required String fcmToken,
    required String deviceId,
    required String deviceName,
    required String devicePlatform,
    required String appVersion,
  }) async {
    await apiClient.dio.post(
      '/notifications/register-device',
      data: {
        'fcmToken': fcmToken,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'devicePlatform': devicePlatform,
        'appVersion': appVersion,
      },
    );
  }

  @override
  Future<void> unregisterDevice(String deviceId) async {
    await apiClient.dio.delete(
      '/notifications/unregister-device',
      data: {'deviceId': deviceId},
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
      final candidate =
          data['data'] ??
          data['notifications'] ??
          data['items'] ??
          data['results'];
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

  @override
  Future<void> markAsRead(String id) async {
    await apiClient.dio.put('/notifications/$id/read');
  }
}
