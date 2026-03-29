import 'package:equatable/equatable.dart';

class Complaint extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String organizationId;
  final String status;
  final String category;
  final String priority;
  final String department;
  final DateTime createdAt;

  const Complaint({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.organizationId,
    required this.status,
    this.category = 'Auto',
    this.priority = 'Low',
    this.department = 'Auto',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        latitude,
        longitude,
        organizationId,
        status,
        category,
        priority,
        department,
        createdAt,
      ];
}
