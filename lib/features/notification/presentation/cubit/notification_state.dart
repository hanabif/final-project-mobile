part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationItem> notifications;
  NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
