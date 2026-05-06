import 'package:equatable/equatable.dart';

class Complaint extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> images;
  final double latitude;
  final double longitude;
  final String organizationId;
  final String status;
  final String category;
  final String priority;
  final String department;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final List<StatusUpdate> history;

  const Complaint({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.images = const [],
    required this.latitude,
    required this.longitude,
    required this.organizationId,
    required this.status,
    this.category = 'Auto',
    this.priority = 'Low',
    this.department = 'Auto',
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.history = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        images,
        latitude,
        longitude,
        organizationId,
        status,
        category,
        priority,
        department,
        createdAt,
        updatedAt,
        resolvedAt,
        history,
      ];
}

class StatusUpdate extends Equatable {
  final String action;
  final String? comment;
  final String? by;
  final DateTime timestamp;

  const StatusUpdate({
    required this.action,
    this.comment,
    this.by,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [action, comment, by, timestamp];
}
