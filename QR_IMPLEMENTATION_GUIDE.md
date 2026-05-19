# QR Code Implementation Guide

## Overview
The QR scan feature is now integrated into the home screen. Users can scan QR codes to auto-fill complaint forms with:
- **Organization ID** - The department/utility to file the complaint against
- **Title** - Short problem description
- **Description** - Detailed problem description
- **Latitude/Longitude** (optional) - Fixed location from the QR code
- **Location Label** (optional) - Human-readable location name

## QR Code Data Format

### JSON Format (Recommended)
```json
{
  "organizationId": "ORG_123",
  "title": "Broken Street Light",
  "description": "The street light at the main gate has been non-functional for three days, creating safety hazards in the area.",
  "latitude": 9.0321,
  "longitude": 38.7468,
  "locationLabel": "Main Gate - Zone A"
}
```

### Simple Format (Colon-separated)
```
ORG_123:Broken Street Light:The street light at the main gate has been non-functional...
```

Or with location:
```
ORG_123:Broken Street Light:Detailed description:9.0321:38.7468:Main Gate
```

## Sample QR Code Data (for testing)

### Example 1: Water Utility Complaint
```json
{
  "organizationId": "water-utility-001",
  "title": "Water Pipe Burst",
  "description": "Main water supply pipe has burst near Addis Ababa Plaza, causing water wastage and flooding on the street.",
  "latitude": 9.0320,
  "longitude": 38.7469,
  "locationLabel": "Addis Ababa Plaza"
}
```

### Example 2: Electric Utility Complaint
```json
{
  "organizationId": "electric-utility-001",
  "title": "Power Outage",
  "description": "Entire neighborhood K-5 has been without electricity for 24 hours. Urgent restoration needed.",
  "latitude": 9.0355,
  "longitude": 38.7510,
  "locationLabel": "Neighborhood K-5"
}
```

### Example 3: Sewerage Complaint
```json
{
  "organizationId": "sewerage-001",
  "title": "Blocked Sewer Line",
  "description": "Sewer line on Bole Road is completely blocked, causing overflow and foul odors affecting nearby residents.",
  "latitude": 9.0280,
  "longitude": 38.7440,
  "locationLabel": "Bole Road"
}
```

## How to Generate QR Codes

### Using Online Tools:
1. Visit https://www.qr-code-generator.com/
2. Select "Text" as the type
3. Paste the JSON or colon-separated data
4. Generate and download the QR code
5. Print or display the QR code

### Example URLs:
- [Water Utility QR](https://www.qr-code-generator.com/?qr={"organizationId":"water-utility-001","title":"Water Pipe Burst","description":"Main water supply pipe burst","latitude":9.0320,"longitude":38.7469,"locationLabel":"Addis Ababa Plaza"})
- [Electric Utility QR](https://www.qr-code-generator.com/?qr={"organizationId":"electric-utility-001","title":"Power Outage","description":"24 hour outage in K-5","latitude":9.0355,"longitude":38.7510,"locationLabel":"Neighborhood K-5"})

### Using Code (Dart):
```dart
import 'package:complaint_resolution_app/core/utils/qr_complaint_parser.dart';

// Generate sample data
final jsonData = QRComplaintParser.generateSampleJson(
  organizationId: 'water-utility-001',
  title: 'Water Pipe Burst',
  description: 'Main water supply pipe has burst near plaza',
  latitude: 9.0320,
  longitude: 38.7469,
  locationLabel: 'Addis Ababa Plaza',
);

print('QR Content: $jsonData');
// Output: {"organizationId":"water-utility-001","title":"Water Pipe Burst",...}
```

## Integration Points

### Home Screen
- Added **QR Scan** button in the floating action button menu
- Users can now tap FAB → "Scan QR Code" to open the scanner

### New Files Created
- `lib/core/utils/qr_complaint_parser.dart` - QR data parsing and validation
- `lib/features/complaint/presentation/widgets/qr_scanner_modal.dart` - Scanner UI

### Modified Files
- `pubspec.yaml` - Added `mobile_scanner: ^3.5.0`
- `lib/features/complaint/presentation/screens/home_screen.dart` - Added QR menu
- `lib/core/routes/app_router.dart` - Updated to handle map arguments
- `lib/features/complaint/presentation/screens/complaint_form_screen.dart` - Added pre-fill support

## Usage Flow

1. User opens home screen
2. Taps the floating action button
3. Selects "Scan QR Code"
4. Scanner modal opens with camera overlay
5. User scans QR code
6. Form screen opens with auto-filled fields:
   - Organization already selected
   - Title field pre-populated
   - Description field pre-populated
   - Location set (if QR included coordinates)
7. User can edit any field and submit

## Error Handling

- **Invalid QR code**: If QR data is invalid, scanning will continue
- **Missing required fields**: If organizationId, title, or description are missing, the QR is ignored
- **Camera permission**: iOS and Android require camera permissions (already handled in app)

## Security Notes

- QR codes should not contain sensitive information
- Coordinates in QR codes help identify complaint locations
- Malformed QR data is safely ignored

## Testing Checklist

- [ ] Generate sample QR codes using the data above
- [ ] Scan QR with mobile app
- [ ] Verify form auto-fills correctly
- [ ] Verify location is set if provided in QR
- [ ] Test without location in QR (should use device location)
- [ ] Test editing pre-filled fields
- [ ] Test form submission with QR data
