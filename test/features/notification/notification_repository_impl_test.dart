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
    test('should register device token', () async {
      when(
        () => mockRemoteDataSource.registerDeviceToken(any()),
      ).thenAnswer((_) async => {});

      await repository.registerDeviceToken('token123');

      verify(
        () => mockRemoteDataSource.registerDeviceToken('token123'),
      ).called(1);
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
