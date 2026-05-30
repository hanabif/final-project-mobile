import 'dart:convert';

class QRComplaintData {
  final String organizationId;
  final String title;

  QRComplaintData({
    required this.organizationId,
    required this.title,
  });

  factory QRComplaintData.fromJson(Map<String, dynamic> json) {
    return QRComplaintData(
      organizationId:
          (json['organizationId'] ?? json['orgId'])?.toString() ?? '',
      title: (json['title'] ?? json['ttl'])?.toString() ?? '',
    );
  }
}

class QRComplaintParser {
  /// Parse QR code data and extract the organization and title only.
  /// QR code should contain JSON in the format:
  /// {
  ///   "organizationId": "ORG_123",
  ///   "title": "Problem title"
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

      if (orgId == null || title == null) {
        print("DEBUG: Parser failed - Missing required fields (orgId or title)");
        return null;
      }

      return QRComplaintData.fromJson(decoded);
    } catch (e) {
      print("DEBUG: JSON parsing failed - $e");
      // If JSON parsing fails, try simple key=value format
      // Format: orgId:TITLE:DESCRIPTION or orgId:TITLE:DESCRIPTION:LAT:LNG:LABEL
      try {
        final parts = qrContent.split(':');
        if (parts.length < 2) return null;

        final orgId = parts[0].trim();
        final title = parts[1].trim();

        if (orgId.isEmpty || title.isEmpty) {
          return null;
        }

        return QRComplaintData(
          organizationId: orgId,
          title: title,
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
  }) {
    final data = {
      'organizationId': organizationId,
      'title': title,
    };
    return jsonEncode(data);
  }
}
