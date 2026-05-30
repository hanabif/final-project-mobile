import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class ComplaintSuccessScreen extends StatelessWidget {
  final String? complaintId;
  final String? message;
  final bool isQueued;

  const ComplaintSuccessScreen({
    super.key,
    this.complaintId,
    this.message,
    this.isQueued = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.success),
        automaticallyImplyLeading: false, // Prevent going back to form
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isQueued ? Icons.cloud_upload_outlined : Icons.check_circle,
                color: isQueued ? Colors.orange : Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                message ??
                    (isQueued
                        ? 'No internet connection. Your complaint was saved and will be submitted automatically when you are back online.'
                        : l10n.complaintSubmittedSuccessfully),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                isQueued ? 'Waiting to sync' : l10n.statusSubmitted,
                style: TextStyle(
                  fontSize: 16,
                  color: isQueued ? Colors.orange : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (complaintId != null && complaintId!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${l10n.complaintId} $complaintId',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Pop until we reach the dashboard (assuming dashboard is at root or specific route)
                  // For now, we'll just pop twice to simulate going back to dashboard,
                  // or use pushAndRemoveUntil if route is named.
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: Text(l10n.returnToDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
