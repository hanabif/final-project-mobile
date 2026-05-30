import 'package:bloc/bloc.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../domain/entities/notification_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final NetworkInfo networkInfo;

  NotificationCubit(
    this.getNotificationsUseCase,
    this.markAllNotificationsAsReadUseCase,
    this.markNotificationAsReadUseCase,
    this.networkInfo,
  ) : super(NotificationInitial());

  void addNotification(NotificationItem notification) {
    if (state is NotificationLoaded) {
      final currentNotifications = (state as NotificationLoaded).notifications;
      final updatedNotifications = <NotificationItem>[
        notification,
        ...currentNotifications.where((item) => item.id != notification.id),
      ];
      emit(NotificationLoaded(updatedNotifications));
      return;
    }

    emit(NotificationLoaded([notification]));
  }

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await getNotificationsUseCase();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        emit(NotificationOffline('No internet connection. Showing saved notifications when available.'));
        return;
      }

      emit(NotificationError('Unable to load notifications right now.'));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Optimistically update local state
      if (state is NotificationLoaded) {
        final currentNotifications =
            (state as NotificationLoaded).notifications;
        final updatedNotifications = currentNotifications.map((n) {
          return NotificationItem(
            id: n.id,
            title: n.title,
            body: n.body,
            date: n.date,
            isRead: true,
            complaintId: n.complaintId,
          );
        }).toList();
        emit(NotificationLoaded(updatedNotifications));
      }
      await markAllNotificationsAsReadUseCase();
    } catch (e) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        await fetchNotifications();
        return;
      }

      await fetchNotifications();
      emit(NotificationError('Unable to update notifications right now.'));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      // Optmistically update local state
      if (state is NotificationLoaded) {
        final currentNotifications =
            (state as NotificationLoaded).notifications;
        final updatedNotifications = currentNotifications.map((n) {
          if (n.id == id) {
            return NotificationItem(
              id: n.id,
              title: n.title,
              body: n.body,
              date: n.date,
              isRead: true,
              complaintId: n.complaintId,
            );
          }
          return n;
        }).toList();
        emit(NotificationLoaded(updatedNotifications));
      }

      await markNotificationAsReadUseCase(id);
      // No need to fetchNotifications() here as we already updated it locally
    } catch (e) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        await fetchNotifications();
        return;
      }

      print('DEBUG: Error marking notification as read: $e');
      await fetchNotifications();
      emit(NotificationError('Unable to update notification status right now.'));
    }
  }
}
