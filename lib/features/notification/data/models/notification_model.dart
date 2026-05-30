import '../../domain/entities/notification_item.dart';

class NotificationModel extends NotificationItem {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.date,
    required super.isRead,
    super.complaintId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value, [String fallback = '']) {
      if (value == null) return fallback;
      if (value is String) return value;
      if (value is num || value is bool) return value.toString();
      if (value is Map) {
        final map = value.cast<String, dynamic>();
        return extractString(map['id'] ?? map['_id'] ?? map['title'] ?? map['name'], fallback);
      }
      return value.toString();
    }

    DateTime extractDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    bool extractBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        return normalized == 'true' || normalized == '1' || normalized == 'read';
      }
      return false;
    }

    final id = extractString(json['id'] ?? json['_id']);
    final title = extractString(json['title'] ?? json['subject'] ?? json['name'], 'Notification');
    final body = extractString(json['body'] ?? json['message'] ?? json['description'], '');
    final date = extractDate(json['date'] ?? json['createdAt'] ?? json['timestamp']);
    final isRead = extractBool(json['isRead'] ?? json['read'] ?? json['is_read']);
    final complaintId = json['complaintId']?.toString() ?? json['complaint_id']?.toString();

    return NotificationModel(
      id: id.isEmpty ? '${title}_${date.millisecondsSinceEpoch}' : id,
      title: title,
      body: body,
      date: date,
      isRead: isRead,
      complaintId: complaintId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'complaintId': complaintId,
    };
  }
}
