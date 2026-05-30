import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification_item.dart';
import '../models/notification_model.dart';

const CACHED_NOTIFICATIONS = 'CACHED_NOTIFICATIONS';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  NotificationRepositoryImpl(
    this.remoteDataSource,
    this.sharedPreferences,
  );

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
      await sharedPreferences.setString(
        CACHED_NOTIFICATIONS,
        json.encode(models.map((model) => model.toJson()).toList()),
      );
      return models.cast<NotificationItem>();
    } catch (e) {
      final cached = await _getCachedNotifications();
      if (cached.isNotEmpty) {
        return cached;
      }
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

  Future<List<NotificationItem>> _getCachedNotifications() async {
    final jsonString = sharedPreferences.getString(CACHED_NOTIFICATIONS);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
