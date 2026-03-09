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
        createdAt,
      ];
}
