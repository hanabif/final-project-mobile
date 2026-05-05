import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/notification_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  String _formatNotificationDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    return '${localDate.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final sl = GetIt.instance;
    return BlocProvider(
      create: (context) => sl<NotificationCubit>()..fetchNotifications(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            Builder(
              builder: (appBarContext) => IconButton(
                tooltip: 'Mark all as read',
                icon: const Icon(Icons.done_all),
                onPressed: () => appBarContext.read<NotificationCubit>().markAllAsRead(),
              ),
            ),
          ],
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading || state is NotificationInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              final notifications = state.notifications;
              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications yet.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        notif.isRead ? Icons.notifications_none : Icons.notifications,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notif.body),
                      trailing: Text(
                        _formatNotificationDate(notif.date),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
              );
            } else if (state is NotificationError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
