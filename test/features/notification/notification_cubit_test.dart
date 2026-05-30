import 'package:bloc_test/bloc_test.dart';
import 'package:complaint_resolution_app/core/network/network_info.dart';
import 'package:complaint_resolution_app/features/notification/domain/entities/notification_item.dart';
import 'package:complaint_resolution_app/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:complaint_resolution_app/features/notification/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:complaint_resolution_app/features/notification/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:complaint_resolution_app/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNotificationsUseCase extends Mock
    implements GetNotificationsUseCase {}

class MockMarkAllNotificationsAsReadUseCase extends Mock
    implements MarkAllNotificationsAsReadUseCase {}

class MockMarkNotificationAsReadUseCase extends Mock
    implements MarkNotificationAsReadUseCase {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetNotificationsUseCase mockGetNotifications;
  late MockMarkAllNotificationsAsReadUseCase mockMarkAllAsRead;
  late MockMarkNotificationAsReadUseCase mockMarkAsRead;
  late MockNetworkInfo mockNetworkInfo;
  late NotificationCubit cubit;

  setUp(() {
    mockGetNotifications = MockGetNotificationsUseCase();
    mockMarkAllAsRead = MockMarkAllNotificationsAsReadUseCase();
    mockMarkAsRead = MockMarkNotificationAsReadUseCase();
    mockNetworkInfo = MockNetworkInfo();
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    cubit = NotificationCubit(
      mockGetNotifications,
      mockMarkAllAsRead,
      mockMarkAsRead,
      mockNetworkInfo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final tNotifications = [
    NotificationItem(
      id: '1',
      title: 'Title',
      body: 'Body',
      date: DateTime.now(),
      isRead: false,
    ),
  ];

  group('fetchNotifications', () {
    blocTest<NotificationCubit, NotificationState>(
      'emits [NotificationLoading, NotificationLoaded] when fetching succeeds',
      build: () {
        when(
          () => mockGetNotifications(),
        ).thenAnswer((_) async => tNotifications);
        return cubit;
      },
      act: (cubit) => cubit.fetchNotifications(),
      expect: () => [NotificationLoading(), NotificationLoaded(tNotifications)],
    );

    blocTest<NotificationCubit, NotificationState>(
      'emits [NotificationLoading, NotificationError] when fetching fails online',
      build: () {
        when(() => mockGetNotifications()).thenThrow(Exception('Error'));
        return cubit;
      },
      act: (cubit) => cubit.fetchNotifications(),
      expect: () => [
        NotificationLoading(),
        NotificationError('Unable to load notifications right now.'),
      ],
    );
  });

  group('markAsRead', () {
    blocTest<NotificationCubit, NotificationState>(
      'emits [NotificationLoaded] with updated item when marking as read succeeds',
      seed: () => NotificationLoaded(tNotifications),
      build: () {
        when(() => mockMarkAsRead(any())).thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) => cubit.markAsRead('1'),
      expect: () => [
        isA<NotificationLoaded>().having(
          (s) => s.notifications.first.isRead,
          'isRead',
          true,
        ),
      ],
    );
  });

  group('addNotification', () {
    blocTest<NotificationCubit, NotificationState>(
      'prepends a notification and removes duplicates by id when loaded',
      seed: () => NotificationLoaded(tNotifications),
      build: () => cubit,
      act: (cubit) => cubit.addNotification(
        const NotificationItem(
          id: '2',
          title: 'New Title',
          body: 'New Body',
          date: DateTime(2026, 5, 25),
          isRead: false,
        ),
      ),
      expect: () => [
        isA<NotificationLoaded>().having(
          (s) => s.notifications.first.id,
          'first notification id',
          '2',
        ),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'creates a loaded state when adding a notification from initial state',
      build: () => cubit,
      act: (cubit) => cubit.addNotification(
        const NotificationItem(
          id: '1',
          title: 'New Title',
          body: 'New Body',
          date: DateTime(2026, 5, 25),
          isRead: false,
        ),
      ),
      expect: () => [isA<NotificationLoaded>()],
    );
  });
}
