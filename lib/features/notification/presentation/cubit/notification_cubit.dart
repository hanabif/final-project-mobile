import 'package:bloc/bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../domain/entities/notification_item.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;

  NotificationCubit(
    this.getNotificationsUseCase,
    this.markAllNotificationsAsReadUseCase,
  ) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await getNotificationsUseCase();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Failed to load notifications'));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await markAllNotificationsAsReadUseCase();
      await fetchNotifications();
    } catch (e) {
      emit(NotificationError('Failed to update notifications'));
    }
  }
}
