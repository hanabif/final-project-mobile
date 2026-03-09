import '../../domain/entities/complaint.dart';

class ComplaintModel extends Complaint {
  const ComplaintModel({
    required super.id,
    required super.title,
    required super.description,
    super.imageUrl,
    required super.latitude,
    required super.longitude,
    required super.organizationId,
    required super.status,
    required super.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      organizationId: json['organizationId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'organizationId': organizationId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ComplaintModel.fromEntity(Complaint complaint) {
    return ComplaintModel(
      id: complaint.id,
      title: complaint.title,
      description: complaint.description,
      imageUrl: complaint.imageUrl,
      latitude: complaint.latitude,
      longitude: complaint.longitude,
      organizationId: complaint.organizationId,
      status: complaint.status,
      createdAt: complaint.createdAt,
    );
  }
}
