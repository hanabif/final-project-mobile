class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final String? complaintId;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.isRead,
    this.complaintId,
  });
}
