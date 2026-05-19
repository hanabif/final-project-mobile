import 'package:complaint_resolution_app/core/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/utils/qr_complaint_parser.dart';

class QRScannerModal extends StatefulWidget {

  const QRScannerModal({
    super.key,
  });

  @override
  State<QRScannerModal> createState() => _QRScannerModalState();
}

class _QRScannerModalState extends State<QRScannerModal> {
  late MobileScannerController _controller;
  bool _isScanComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) async {
    if (_isScanComplete) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final qrData = QRComplaintParser.parse(barcode.rawValue!);
        if (qrData != null) {
          _isScanComplete = true;
           // FIX: Stop the camera hardware first
        await _controller.stop(); 
        
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RouteNames.complaintForm,
            arguments: {
              'organizationId': qrData.organizationId,
              'title': qrData.title,
              'description': qrData.description,
              'latitude': qrData.latitude,
              'longitude': qrData.longitude,
              'locationLabel': qrData.locationLabel,
            },
          );
        }
        return;
        }
        else {
           debugPrint('QR Format invalid for Parser');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF005C45),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text('Scan QR Code'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _handleDetection,
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Text(
                      'Unable to access camera: ${error.errorCode}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
                placeholderBuilder: (context, child) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF005C45),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(64),
                child: CustomPaint(
                  painter: ScannerOverlayPainter(),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    const scanAreaSize = 250.0;

    final scanAreaLeft = (width - scanAreaSize) / 2;
    final scanAreaTop = (height - scanAreaSize) / 2;

    // Darken the area outside the scan zone
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, scanAreaTop),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, scanAreaTop + scanAreaSize, width, height - scanAreaTop - scanAreaSize),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, scanAreaTop, scanAreaLeft, scanAreaSize),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    canvas.drawRect(
      Rect.fromLTWH(scanAreaLeft + scanAreaSize, scanAreaTop, width - scanAreaLeft - scanAreaSize, scanAreaSize),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );

    // Draw the border of the scan area
    canvas.drawRect(
      Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize),
      Paint()
        ..color = const Color(0xFF005C45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Draw corner brackets
    const cornerSize = 30.0;
    const cornerWidth = 4.0;
    final paint = Paint()
      ..color = const Color(0xFF005C45)
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke;

    // Top-left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + cornerSize),
      Offset(scanAreaLeft, scanAreaTop),
      paint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerSize, scanAreaTop),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      paint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerSize),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerSize),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      paint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerSize, scanAreaTop + scanAreaSize),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      paint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize - cornerSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) => false;
}
