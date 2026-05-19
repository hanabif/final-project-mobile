# QR Code Testing Quick Reference

## Generate Sample QR Codes Using Dart

```dart
import 'package:complaint_resolution_app/core/utils/qr_complaint_parser.dart';

void main() {
  // Example 1: Water utility complaint
  final waterQR = QRComplaintParser.generateSampleJson(
    organizationId: 'water-utility-001',
    title: 'Water Pipe Burst',
    description: 'Main water supply pipe has burst near Addis Ababa Plaza, causing water wastage and flooding on the street.',
    latitude: 9.0320,
    longitude: 38.7469,
    locationLabel: 'Addis Ababa Plaza',
  );
  print('Water QR Data: $waterQR');

  // Example 2: Electric utility
  final electricQR = QRComplaintParser.generateSampleJson(
    organizationId: 'electric-utility-001',
    title: 'Power Outage',
    description: 'Entire neighborhood K-5 has been without electricity for 24 hours. Urgent restoration needed.',
    latitude: 9.0355,
    longitude: 38.7510,
  );
  print('Electric QR Data: $electricQR');

  // Example 3: Sewerage complaint
  final sewerQR = QRComplaintParser.generateSampleJson(
    organizationId: 'sewerage-001',
    title: 'Blocked Sewer Line',
    description: 'Sewer line on Bole Road is completely blocked, causing overflow and foul odors affecting nearby residents.',
    latitude: 9.0280,
    longitude: 38.7440,
    locationLabel: 'Bole Road',
  );
  print('Sewer QR Data: $sewerQR');
}
```

## Generate QR Codes Online

### Step-by-Step Process:

1. **Go to**: https://www.qr-code-generator.com/
2. **Select**: "Text" as content type
3. **Paste** the JSON from above
4. **Click**: Generate
5. **Download** or print the QR code

### Quick Links with Pre-filled Data:

**Water Utility (with location):**
```
https://www.qr-code-generator.com/?qr={"organizationId":"water-utility-001","title":"Water Pipe Burst","description":"Main water supply pipe burst near plaza","latitude":9.0320,"longitude":38.7469,"locationLabel":"Addis Ababa Plaza"}
```

**Electric Utility:**
```
https://www.qr-code-generator.com/?qr={"organizationId":"electric-utility-001","title":"Power Outage","description":"24 hour outage affecting entire K-5 neighborhood","latitude":9.0355,"longitude":38.7510}
```

**Sewerage:**
```
https://www.qr-code-generator.com/?qr={"organizationId":"sewerage-001","title":"Blocked Sewer","description":"Sewer line blocked on Bole Road","latitude":9.0280,"longitude":38.7440,"locationLabel":"Bole Road"}
```

## Test Data Summary

### Test Case 1: Full QR Data
- **Organization**: Water Utility
- **Title**: Water Pipe Burst
- **Description**: Main water supply pipe burst
- **Location**: 9.0320, 38.7469 (Addis Ababa Plaza)
- **Expected Result**: All fields pre-filled, location fixed to QR coordinates

### Test Case 2: QR Without Location
- **Organization**: Electric Utility
- **Title**: Power Outage
- **Description**: No electricity for 24 hours
- **Location**: Not in QR (uses device GPS)
- **Expected Result**: Org, title, description pre-filled; form fetches device location

### Test Case 3: Invalid QR
- **Content**: `invalid:qr:data` or malformed JSON
- **Expected Result**: QR scanning continues, user can retry

### Test Case 4: Missing Required Fields
- **Content**: `{"organizationId":"water-001"}` (missing title and description)
- **Expected Result**: QR is ignored, form opens empty

## Parsing Validation

The parser accepts two formats:

### Format 1: JSON (Recommended)
```json
{
  "organizationId": "string",
  "title": "string",
  "description": "string",
  "latitude": 9.0320,
  "longitude": 38.7469,
  "locationLabel": "optional string"
}
```

### Format 2: Colon-Separated
```
organizationId:title:description:latitude:longitude:locationLabel
```

Example: `water-001:Water Burst:Pipe burst near plaza:9.0320:38.7469:Main Gate`

## Debugging

### Enable Debug Output
```dart
// In qr_complaint_parser.dart, add logging:
debugPrint('Parsed QR: ${qrData.organizationId}, ${qrData.title}');
```

### Test Parsing
```dart
final testData = '{"organizationId":"water-001","title":"Burst","description":"Pipe burst"}';
final parsed = QRComplaintParser.parse(testData);
print('Valid: ${parsed != null}');
print('Org: ${parsed?.organizationId}');
```

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| QR not scanning | Camera permission denied | Grant camera permission in settings |
| Form not pre-filling | Invalid QR format | Ensure JSON is valid and has required fields |
| Location not fixed | QR without coordinates | Device GPS will be used instead |
| Scanned but ignored | Missing required field | Include organizationId, title, and description |

## Performance Notes

- Scanner uses hardware acceleration on both iOS/Android
- QR parsing is < 100ms for typical payloads
- JSON parsing fallback is automatic
- No network calls until form submission

## Security Best Practices

- ❌ Don't include sensitive data in QR codes
- ✅ Use IDs, not full names or credentials
- ✅ Keep descriptions under 500 characters
- ✅ Include location for better tracking
- ✅ Use HTTPS when sharing QR code URLs

## Batch Testing

For testing multiple QR codes:

1. Generate 5-10 different QR codes
2. Print them on paper or display on screen
3. Scan each one and verify:
   - Form pre-fills correctly
   - Location is captured
   - Organization is pre-selected
   - Can submit without errors
