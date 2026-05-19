import 'dart:convert';

class QRComplaintData {
  final String organizationId;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;

  QRComplaintData({
    required this.organizationId,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    this.locationLabel,
  });

  factory QRComplaintData.fromJson(Map<String, dynamic> json) {
    return QRComplaintData(
      organizationId: (json['organizationId'] ?? json['orgId'])?.toString() ?? '',
      title: (json['title'] ?? json['ttl'])?.toString() ?? '',
      description: (json['description'] ?? json['dsc'])?.toString() ?? '',
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(json['longitude'] ?? json['lng']),
      locationLabel: (json['locationLabel'] ?? json['lbl'])?.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class QRComplaintParser {
  /// Parse QR code data and extract complaint information
  /// QR code should contain JSON in the format:
  /// {
  ///   "organizationId": "ORG_123",
  ///   "title": "Problem description",
  ///   "description": "Detailed problem description",
  ///   "latitude": 9.0321,
  ///   "longitude": 38.7468,
  ///   "locationLabel": "Main Gate"
  /// }
  static QRComplaintData? parse(String qrContent) {
    try {
      // Try parsing as JSON
      final decoded = jsonDecode(qrContent) as Map<String, dynamic>;
      
      // DEBUG: See what we actually got
    print("DEBUG: Scanned JSON: $decoded");

    // Use flexible keys (handles both 'organizationId' and 'orgId')
    final orgId = decoded['organizationId'] ?? decoded['orgId'];
    final title = decoded['title'] ?? decoded['ttl'];
    final desc  = decoded['description'] ?? decoded['dsc'];

    if (orgId == null || title == null || desc == null) {
      print("DEBUG: Parser failed - Missing required fields (orgId, title, or description)");
      return null;
    }

      return QRComplaintData.fromJson(decoded);
    } catch (e) {
      print("DEBUG: JSON parsing failed - $e");
      // If JSON parsing fails, try simple key=value format
      // Format: orgId:TITLE:DESCRIPTION or orgId:TITLE:DESCRIPTION:LAT:LNG:LABEL
      try {
        final parts = qrContent.split(':');
        if (parts.length < 3) return null;

        final orgId = parts[0].trim();
        final title = parts[1].trim();
        final description = parts[2].trim();
        double? lat;
        double? lng;
        String? label;

        if (parts.length > 3) {
          lat = double.tryParse(parts[3].trim());
          lng = double.tryParse(parts[4].trim());
        }
        if (parts.length > 5) {
          label = parts[5].trim();
        }

        if (orgId.isEmpty || title.isEmpty || description.isEmpty) {
          return null;
        }

        return QRComplaintData(
          organizationId: orgId,
          title: title,
          description: description,
          latitude: lat,
          longitude: lng,
          locationLabel: label,
        );
      } catch (_) {
        return null;
      }
    }
  }

  /// Generate sample QR code data for testing
  static String generateSampleJson({
    required String organizationId,
    required String title,
    required String description,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) {
    final data = {
      'organizationId': organizationId,
      'title': title,
      'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationLabel != null) 'locationLabel': locationLabel,
    };
    return jsonEncode(data);
  }
}
