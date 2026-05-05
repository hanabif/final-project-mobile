import '../entities/notification_item.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationItem>> call() {
    return repository.getNotifications();
  }
}
