# API Payload Structure - QR Scanned Complaints

When a user scans a QR code and submits a complaint form, here's the exact JSON that will be sent to the `/complaints` endpoint:

## Example 1: QR with Full Data (including location)

**QR Code Content:**
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

**API Request Payload (sent to POST /complaints):**
```json
{
  "id": "uuid-generated",
  "title": "Water Pipe Burst",
  "description": "Main water supply pipe has burst near Addis Ababa Plaza, causing water wastage and flooding on the street.",
  "imageUrl": "https://server.com/uploads/image-1.jpg",
  "images": [
    "https://server.com/uploads/image-1.jpg",
    "https://server.com/uploads/image-2.jpg"
  ],
  "latitude": 9.0320,
  "longitude": 38.7469,
  "organizationId": "water-utility-001",
  "organization": "water-utility-001",
  "status": "Submitted",
  "category": "Auto",
  "priority": "Low",
  "department": "water-utility-001",
  "createdAt": "2026-05-17T10:15:30.000Z",
  "updatedAt": null,
  "resolvedAt": null,
  "location": {
    "latitude": 9.0320,
    "longitude": 38.7469
  },
  "attachments": [
    {
      "url": "https://server.com/uploads/image-1.jpg",
      "filename": "image"
    },
    {
      "url": "https://server.com/uploads/image-2.jpg",
      "filename": "image"
    }
  ],
  "history": []
}
```

## Example 2: QR Without Location (uses device GPS)

**QR Code Content:**
```json
{
  "organizationId": "electric-utility-001",
  "title": "Power Outage",
  "description": "Entire neighborhood K-5 has been without electricity for 24 hours. Urgent restoration needed."
}
```

**API Request Payload:**
```json
{
  "id": "uuid-generated",
  "title": "Power Outage",
  "description": "Entire neighborhood K-5 has been without electricity for 24 hours. Urgent restoration needed.",
  "imageUrl": null,
  "images": [],
  "latitude": 9.0355,
  "longitude": 38.7510,
  "organizationId": "electric-utility-001",
  "organization": "electric-utility-001",
  "status": "Submitted",
  "category": "Auto",
  "priority": "Low",
  "department": "electric-utility-001",
  "createdAt": "2026-05-17T10:20:45.000Z",
  "updatedAt": null,
  "resolvedAt": null,
  "location": {
    "latitude": 9.0355,
    "longitude": 38.7510
  },
  "attachments": [],
  "history": []
}
```

## Key Differences Between QR and Manual Submissions

| Field | QR Scanned | Manual Form |
|-------|-----------|------------|
| **title** | Pre-filled from QR | User enters |
| **description** | Pre-filled from QR | User enters |
| **organizationId** | Pre-filled from QR | User selects from dropdown |
| **latitude/longitude** | From QR (if provided) OR device GPS if not | Always from device GPS |
| **images** | User can add more | User adds |
| **status** | Always "Submitted" | Always "Submitted" |
| **category** | Always "Auto" | Always "Auto" |
| **priority** | Always "Low" | Always "Low" |

## Processing Flow in Backend

1. **Receive** QR-prefilled complaint at `/complaints` endpoint
2. **Validate** required fields (organizationId, title, description, location)
3. **Store** the complaint record
4. **Trigger** automated moderation if configured
5. **Return** complaint ID to mobile app
6. **Display** success screen with ticket reference

## Important Notes

- **Location Override**: If QR includes latitude/longitude, these are used instead of device GPS
- **Organization Pre-selection**: Eliminates user confusion and speeds up submission
- **Pre-filled Description**: Users can still edit before submission
- **Image Upload**: Images are uploaded first (to `/uploads` endpoint), then URLs are included in complaint

## Error Scenarios

### Invalid QR Code
```json
// If QR cannot be parsed or lacks required fields,
// scanning continues without match
```

### Missing Required Fields
- If `organizationId` is empty or missing → QR ignored
- If `title` is empty or missing → QR ignored  
- If `description` is empty or missing → QR ignored
- Complaint form opens without pre-fill, requiring user to enter manually

### Network Issues During Upload
- Images fail to upload → Error shown to user
- User can retry or remove problematic image
- Form data remains intact for resubmission

## Backend Validation Checklist

Ensure your backend API validates:
- [ ] `organizationId` exists in system
- [ ] `title` is at least 5 characters
- [ ] `description` is at least 20 characters
- [ ] `latitude` and `longitude` are valid coordinates (or null)
- [ ] `status` is one of: Submitted, Pending, In-Progress, Resolved
- [ ] All image URLs are valid and accessible
