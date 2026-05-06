import '../../domain/entities/complaint.dart';

class ComplaintModel extends Complaint {
  const ComplaintModel({
    required super.id,
    required super.title,
    required super.description,
    super.imageUrl,
    super.images = const [],
    required super.latitude,
    required super.longitude,
    required super.organizationId,
    required super.status,
    super.category,
    super.priority,
    super.department,
    required super.createdAt,
    super.updatedAt,
    super.resolvedAt,
    super.history = const [],
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    // Handle location object if present, otherwise default to 0.0
    double lat = 0.0;
    double lng = 0.0;
    
    if (json['location'] != null && json['location'] is Map) {
      final loc = json['location'] as Map<String, dynamic>;
      // Check for 'latitude'/'longitude' directly
      if (loc['latitude'] != null && loc['longitude'] != null) {
        lat = (loc['latitude'] as num).toDouble();
        lng = (loc['longitude'] as num).toDouble();
      } 
      // Check for GeoJSON 'coordinates' [lng, lat]
      else if (loc['coordinates'] != null && loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
        lng = (loc['coordinates'][0] as num).toDouble();
        lat = (loc['coordinates'][1] as num).toDouble();
      }
    } else if (json['latitude'] != null && json['longitude'] != null) {
      lat = (json['latitude'] as num).toDouble();
      lng = (json['longitude'] as num).toDouble();
    }

    String extractId(dynamic val) {
      if (val == null) return '';
      if (val is String) return val;
      if (val is Map) return val['id']?.toString() ?? val['_id']?.toString() ?? '';
      return val.toString();
    }

    // Parse images from 'attachments' list (each has a 'url' key)
    // or fall back to a plain 'images' string list
    List<String> imagesList = [];
    if (json['attachments'] != null && json['attachments'] is List) {
      imagesList = (json['attachments'] as List<dynamic>)
          .map((a) {
            if (a is Map<String, dynamic>) return a['url']?.toString() ?? '';
            return a.toString();
          })
          .where((url) => url.isNotEmpty)
          .toList();
    } else if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List<dynamic>).map((e) => e.toString()).toList();
    }

    // 'organization' may be a name string or an object; prefer 'organizationId'
    String orgId = '';
    if (json['organizationId'] != null) {
      orgId = extractId(json['organizationId']);
    } else if (json['organization'] != null) {
      orgId = extractId(json['organization']);
    }

    return ComplaintModel(
      id: extractId(json['id'] ?? json['_id']),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      images: imagesList,
      latitude: lat,
      longitude: lng,
      organizationId: orgId,
      status: json['status'] as String? ?? 'Pending',
      category: json['category'] as String? ?? 'Auto',
      priority: json['priority'] as String? ?? 'Low',
      department: extractId(json['department'] ?? 'Auto'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      history: (json['history'] as List<dynamic>?)?.map((e) {
        final map = e as Map<String, dynamic>;
        return StatusUpdate(
          action: map['action'] ?? 'Updated',
          comment: map['comment'],
          by: map['by'],
          timestamp: map['timestamp'] != null
              ? DateTime.parse(map['timestamp'] as String)
              : DateTime.now(),
        );
      }).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
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
      images: complaint.images,
      latitude: complaint.latitude,
      longitude: complaint.longitude,
      organizationId: complaint.organizationId,
      status: complaint.status,
      category: complaint.category,
      priority: complaint.priority,
      department: complaint.department,
      createdAt: complaint.createdAt,
      updatedAt: complaint.updatedAt,
      resolvedAt: complaint.resolvedAt,
    );
  }
}
