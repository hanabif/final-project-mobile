import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:complaint_resolution_app/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:complaint_resolution_app/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:complaint_resolution_app/features/notification/domain/entities/notification_item.dart';
import 'package:complaint_resolution_app/features/notification/data/models/notification_model.dart';

class MockRemoteDataSource extends Mock
    implements NotificationRemoteDataSource {}

void main() {
  late NotificationRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    repository = NotificationRepositoryImpl(mockRemoteDataSource);
  });

  group('NotificationRepository', () {
    test('should register device', () async {
      when(
        () => mockRemoteDataSource.registerDevice(
          fcmToken: any(named: 'fcmToken'),
          deviceId: any(named: 'deviceId'),
          deviceName: any(named: 'deviceName'),
          devicePlatform: any(named: 'devicePlatform'),
          appVersion: any(named: 'appVersion'),
        ),
      ).thenAnswer((_) async => {});

      await repository.registerDevice(
        fcmToken: 'token123',
        deviceId: 'device-1',
        deviceName: 'Android device',
        devicePlatform: 'android',
        appVersion: '1.0.0+1',
      );

      verify(
        () => mockRemoteDataSource.registerDevice(
          fcmToken: 'token123',
          deviceId: 'device-1',
          deviceName: 'Android device',
          devicePlatform: 'android',
          appVersion: '1.0.0+1',
        ),
      ).called(1);
    });

    test('should unregister device', () async {
      when(() => mockRemoteDataSource.unregisterDevice(any()))
          .thenAnswer((_) async => {});

      await repository.unregisterDevice('device-1');

      verify(() => mockRemoteDataSource.unregisterDevice('device-1'))
          .called(1);
    });

    test('should get notifications', () async {
      final List<NotificationModel> tNotifications = [
        NotificationModel(
          id: '1',
          title: 'Title',
          body: 'Body',
          date: DateTime.now(),
          isRead: false,
        ),
      ];
      when(
        () => mockRemoteDataSource.getNotifications(),
      ).thenAnswer((_) async => tNotifications);

      final result = await repository.getNotifications();

      expect(result, tNotifications);
      verify(() => mockRemoteDataSource.getNotifications()).called(1);
    });

    test('should mark all as read', () async {
      when(
        () => mockRemoteDataSource.markAllAsRead(),
      ).thenAnswer((_) async => {});

      await repository.markAllAsRead();

      verify(() => mockRemoteDataSource.markAllAsRead()).called(1);
    });

    test('should mark as read by id', () async {
      when(
        () => mockRemoteDataSource.markAsRead(any()),
      ).thenAnswer((_) async => {});

      await repository.markAsRead('1');

      verify(() => mockRemoteDataSource.markAsRead('1')).called(1);
    });
  });
}
