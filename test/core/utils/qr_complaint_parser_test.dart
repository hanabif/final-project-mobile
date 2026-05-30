import 'package:flutter_test/flutter_test.dart';
import 'package:complaint_resolution_app/core/utils/qr_complaint_parser.dart';

void main() {
  group('QRComplaintParser', () {
    test('should parse valid JSON QR content', () {
      const qrContent =
          '{"organizationId": "ORG123", "title": "Test Title", "description": "Test Desc"}';
      final result = QRComplaintParser.parse(qrContent);

      expect(result, isNotNull);
      expect(result!.organizationId, 'ORG123');
      expect(result.title, 'Test Title');
      expect(result.description, 'Test Desc');
    });

    test('should parse valid JSON with flexible keys (orgId, ttl, dsc)', () {
      const qrContent =
          '{"orgId": "ORG123", "ttl": "Test Title", "dsc": "Test Desc"}';
      final result = QRComplaintParser.parse(qrContent);

      expect(result, isNotNull);
      expect(result!.organizationId, 'ORG123');
      expect(result.title, 'Test Title');
      expect(result.description, 'Test Desc');
    });

    test('should parse valid colon-separated content', () {
      const qrContent = 'ORG123:Test Title:Test Desc';
      final result = QRComplaintParser.parse(qrContent);

      expect(result, isNotNull);
      expect(result!.organizationId, 'ORG123');
      expect(result.title, 'Test Title');
      expect(result.description, 'Test Desc');
    });

    test('should parse colon-separated content with coordinates', () {
      const qrContent = 'ORG123:Test Title:Test Desc:9.0:38.0';
      final result = QRComplaintParser.parse(qrContent);

      expect(result, isNotNull);
      expect(result!.latitude, 9.0);
      expect(result.longitude, 38.0);
    });

    test('should return null for invalid JSON missing fields', () {
      const qrContent = '{"some": "data"}';
      final result = QRComplaintParser.parse(qrContent);

      expect(result, isNull);
    });

    test('should return null for invalid format', () {
      const qrContent = 'just some text';
      final result = QRComplaintParser.parse(qrContent);

      expect(result, isNull);
    });
  });
}
