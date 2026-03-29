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
    super.category,
    super.priority,
    super.department,
    required super.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    // Handle location object if present, otherwise default to 0.0
    double lat = 0.0;
    double lng = 0.0;
    if (json['location'] != null && json['location'] is Map) {
      lat = (json['location']['latitude'] as num).toDouble();
      lng = (json['location']['longitude'] as num).toDouble();
    } else if (json['latitude'] != null && json['longitude'] != null) {
      lat = (json['latitude'] as num).toDouble();
      lng = (json['longitude'] as num).toDouble();
    }

    return ComplaintModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      latitude: lat,
      longitude: lng,
      organizationId: json['organizationId'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      category: json['category'] as String? ?? 'Auto',
      priority: json['priority'] as String? ?? 'Low',
      department: json['department'] as String? ?? 'Auto',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'organizationId': organizationId,
      'status': status,
      'category': category,
      'priority': priority,
      'department': department,
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
      category: complaint.category,
      priority: complaint.priority,
      department: complaint.department,
      createdAt: complaint.createdAt,
    );
  }
}
